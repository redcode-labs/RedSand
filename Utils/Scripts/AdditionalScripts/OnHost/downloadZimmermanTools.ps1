#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Anchor paths to the script location so this works regardless of caller PWD
$toolkits = Join-Path $PSScriptRoot '..\..\..\Toolkits'
$dir = Join-Path $toolkits 'Zimmerman'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$zip = Join-Path $dir 'Get-ZimmermanTools.zip'
$extracted = Join-Path $dir 'Get-ZimmermanTools'

# Start-BitsTransfer streams to disk instead of buffering in memory like Invoke-WebRequest
Start-BitsTransfer -Source 'https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip' -Destination $zip

Expand-Archive -Path $zip -DestinationPath $extracted -Force
Remove-Item $zip -Force

& (Join-Path $extracted 'Get-ZimmermanTools.ps1')
