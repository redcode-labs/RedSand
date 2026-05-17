#Requires -Version 5.1
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Windows Sandbox requires Windows 10/11 Pro, Enterprise, or Education
$result = Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart
if ($result.RestartNeeded) {
    Write-Host "Windows Sandbox enabled. A restart is required to complete activation." -ForegroundColor Yellow
} else {
    Write-Host "Windows Sandbox enabled." -ForegroundColor Green
}
