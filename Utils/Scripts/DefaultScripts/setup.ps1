#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Runs on logon via every profile's <LogonCommand>. Writes progress to
# Desktop\setup.log so a failed/missing run is debuggable post-mortem:
#   - file missing  --> LogonCommand never invoked this script
#   - file partial  --> script ran but failed at the last logged step

$logFile = 'C:\users\WDAGUtilityAccount\Desktop\setup.log'

function Write-SetupLog {
    param([string]$Message)
    "$(Get-Date -Format 'HH:mm:ss')  $Message" | Add-Content -Path $logFile -ErrorAction SilentlyContinue
}

try {
    Write-SetupLog "setup.ps1 start (user=$env:USERNAME, pwd=$PWD)"
    $policySet = $false
    foreach ($scope in 'LocalMachine', 'CurrentUser') {
        try {
            Set-ExecutionPolicy Unrestricted -Scope $scope -Force -ErrorAction Stop
            Write-SetupLog "ExecutionPolicy set to Unrestricted ($scope)"
            $policySet = $true
            break
        } catch {
            Write-SetupLog "ExecutionPolicy ${scope}: blocked ($($_.Exception.Message))"
        }
    }
    if (-not $policySet) {
        Write-SetupLog "WARN: ExecutionPolicy unchanged; scripts will need -ExecutionPolicy Bypass on invocation"
    }

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1
    Write-SetupLog "AllowDevelopmentWithoutDevLicense=1"

    $Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty $Theme AppsUseLightTheme -Value 0
    Set-ItemProperty $Theme SystemUsesLightTheme -Value 0
    Write-SetupLog "Dark theme registry keys written"

    $Wallpaper = "C:\users\WDAGUtilityAccount\Desktop\Utils\Scripts\DefaultScripts\RedSandWallpaper.png"
    if (-not (Test-Path $Wallpaper)) {
        Write-SetupLog "WARN: Wallpaper not found at $Wallpaper - Utils/ may not be mapped yet"
        return
    }

    $code = @'
using System.Runtime.InteropServices;
namespace Win32 {
    public class Wallpaper {
        [DllImport("user32.dll", CharSet=CharSet.Auto)]
        static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        public static void SetWallpaper(string thePath) {
            SystemParametersInfo(20, 0, thePath, 3);
        }
    }
}
'@

    Add-Type $code
    [Win32.Wallpaper]::SetWallpaper($Wallpaper)
    Write-SetupLog "Wallpaper applied"

    # Restart explorer so the dark theme actually takes effect; writing the
    # registry keys alone doesn't propagate to the running shell.
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
        Start-Process explorer.exe
    }
    Write-SetupLog "Explorer restarted"

    Write-SetupLog "setup.ps1 completed OK"
} catch {
    Write-SetupLog "ERROR: $($_.Exception.Message)"
    Write-SetupLog "ERROR at: $($_.ScriptStackTrace)"
}
