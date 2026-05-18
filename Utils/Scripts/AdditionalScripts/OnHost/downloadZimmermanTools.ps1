#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Anchor paths to the script location so this works regardless of caller PWD
$toolkits = Join-Path $PSScriptRoot '..\..\..\Toolkits'
$dir = Join-Path $toolkits 'Zimmerman'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

# Fetch Get-ZimmermanTools.ps1 directly from GitHub - the .zip on backblaze is
# stale (April 2025) and hardcodes a manifest URL Eric reorganized away. The
# GitHub-hosted copy is the source of truth and currently points at
# https://tools.ericzimmermanstools.com.
$script = Join-Path $dir 'Get-ZimmermanTools.ps1'
Start-BitsTransfer -Source 'https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1' -Destination $script
Unblock-File -Path $script

# Get-ZimmermanTools.ps1 writes downloads to $PWD, not to its own script root -
# push to the Zimmerman dir before invoking so tools land in Utils/Toolkits/Zimmerman/
Push-Location $dir
try {
    & $script
} finally {
    Pop-Location
}
