New-Item -Path "..\..\..\Toolkits" -Name "Zimmerman" -ItemType "directory"
Set-Location -Path "..\..\..\Toolkits\Zimmerman"

$url = "https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip"

$dest = ".\Get-ZimmermanTools.zip"

# TIL: Invoke-WebRequest is slower because it has to buffer the file in memory first before writing it to a disk
Start-BitsTransfer -Source $url -Destination $dest

Expand-Archive -Path ".\Get-ZimmermanTools.zip" -DestinationPath ".\Get-ZimmermanTools"

.\Get-ZimmermanTools\Get-ZimmermanTools.ps1