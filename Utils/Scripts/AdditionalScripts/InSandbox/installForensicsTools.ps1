#Requires -Version 5.1
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Narrow forensics tool pack via scoop. Eric Zimmerman's tools and Sysinternals
# are pre-staged on the host via the OnHost downloader scripts - this adds the
# small set that complements them.
#
# Needs internet. Flip <Networking> in the Forensics wsb to Default for first
# boot, install, then close. Installed state lives inside the sandbox VM so
# it evaporates on shutdown - you'll re-run this each session.

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
    'exiftool'
)

foreach ($tool in $tools) {
    Write-Host "Installing $tool..." -ForegroundColor Cyan
    scoop install --global $tool
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "scoop returned exit code $LASTEXITCODE installing $tool"
    }
}

Write-Host "Forensics tools installed." -ForegroundColor Green
