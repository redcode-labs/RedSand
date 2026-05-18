#Requires -Version 5.1
param(
    [switch]$Sysinternals,
    [switch]$Zimmerman,
    [switch]$All
)

$ErrorActionPreference = 'Stop'

# One-shot host prep - verifies the Windows Sandbox feature is enabled and
# orchestrates the OnHost downloader scripts so you can launch any profile
# afterward without missing tools.
#
# Usage:
#   .\prepareForRedSand.ps1               # interactive prompt
#   .\prepareForRedSand.ps1 -All          # download everything, no prompt
#   .\prepareForRedSand.ps1 -Sysinternals -Zimmerman   # cherry-pick

# Verify Windows Sandbox feature state
Write-Host "Checking Windows Sandbox feature..." -ForegroundColor Cyan
try {
    $feature = Get-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -Online -ErrorAction Stop
    if ($feature.State -eq 'Enabled') {
        Write-Host "  Windows Sandbox is enabled." -ForegroundColor Green
    } else {
        Write-Warning "Windows Sandbox is NOT enabled. Run as admin: .\enableSandboxFeature.ps1"
        Write-Warning "Reboot if prompted, then re-run this script."
        return
    }
} catch {
    Write-Warning "Couldn't query sandbox feature state ($($_.Exception.Message)). Continuing anyway."
}

# Resolve which toolkits to download
if ($All) {
    $Sysinternals = $true
    $Zimmerman = $true
}

if (-not ($Sysinternals -or $Zimmerman)) {
    $choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new('&Both', 'Sysinternals + Eric Zimmerman tools'),
        [System.Management.Automation.Host.ChoiceDescription]::new('&Sysinternals only', 'Just the Sysinternals Suite'),
        [System.Management.Automation.Host.ChoiceDescription]::new('&Zimmerman only', 'Just the Eric Zimmerman tools'),
        [System.Management.Automation.Host.ChoiceDescription]::new('&None', 'Skip downloads, exit')
    )
    $idx = $Host.UI.PromptForChoice('Pre-stage tools', 'Which toolkits do you want available inside the sandbox?', $choices, 0)
    switch ($idx) {
        0 { $Sysinternals = $true; $Zimmerman = $true }
        1 { $Sysinternals = $true }
        2 { $Zimmerman = $true }
        3 { return }
    }
}

$here = $PSScriptRoot

if ($Sysinternals) {
    Write-Host ""
    Write-Host "[1] Downloading Sysinternals Suite..." -ForegroundColor Cyan
    & (Join-Path $here 'downloadSysinternalsSuite.ps1')
}

if ($Zimmerman) {
    Write-Host ""
    Write-Host "[2] Downloading Eric Zimmerman's tools..." -ForegroundColor Cyan
    & (Join-Path $here 'downloadZimmermanTools.ps1')
}

Write-Host ""
Write-Host "Host prep complete. Launch a profile from profiles/." -ForegroundColor Green
