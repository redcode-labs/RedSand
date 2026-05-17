#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Anchor paths to the script location so this works regardless of caller PWD
$toolkits = Join-Path $PSScriptRoot '..\..\..\Toolkits'
New-Item -ItemType Directory -Path $toolkits -Force | Out-Null

$zip = Join-Path $toolkits 'SysinternalsSuite.zip'
$extracted = Join-Path $toolkits 'SysinternalsSuite'

Start-BitsTransfer -Source 'https://download.sysinternals.com/files/SysinternalsSuite.zip' -Destination $zip
Expand-Archive -Path $zip -DestinationPath $extracted -Force
Remove-Item $zip -Force
