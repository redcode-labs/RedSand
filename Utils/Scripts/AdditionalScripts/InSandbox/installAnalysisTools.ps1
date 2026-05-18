#Requires -Version 5.1
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Lightweight RE / analysis tool pack via scoop.
# Assumes installChocoAndScoop.ps1 ran first.
#
# Needs internet. If running inside the Analysis profile (which is network-off
# by default), flip <Networking> to Default in the wsb for the first boot,
# install, then disable networking again for actual analysis work.

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw "scoop not found - run installChocoAndScoop.ps1 first"
}

# Scoop needs git to clone bucket repos; install it if missing
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing git (required for scoop buckets)..." -ForegroundColor Cyan
    scoop install --global git
}

scoop bucket add extras

$tools = @(
    'hxd',
    'dnspy',
    'pe-bear',
    'detect-it-easy',
    'x64dbg',
    'systeminformer',
    'wireshark'
)

foreach ($tool in $tools) {
    Write-Host "Installing $tool..." -ForegroundColor Cyan
    scoop install --global $tool
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "scoop returned exit code $LASTEXITCODE installing $tool"
    }
}

Write-Host "Analysis tools installed." -ForegroundColor Green
