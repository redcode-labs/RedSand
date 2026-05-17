#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# LocalMachine scope so subsequent manual script runs inside the sandbox work without -ExecutionPolicy Bypass
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1

$Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty $Theme AppsUseLightTheme -Value 0
Set-ItemProperty $Theme SystemUsesLightTheme -Value 0

$Wallpaper = "C:\users\WDAGUtilityAccount\Desktop\Utils\Scripts\DefaultScripts\RedSandWallpaper.png"
if (-not (Test-Path $Wallpaper)) {
    Write-Warning "Wallpaper not found at $Wallpaper; skipping"
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
