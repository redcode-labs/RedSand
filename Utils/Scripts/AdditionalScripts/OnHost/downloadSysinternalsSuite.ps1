$url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"

$dest = "..\..\..\Toolkits\SysinternalsSuite.zip"

# TIL: Invoke-WebRequest is slower because it has to buffer the file in memory first before writing it to a disk
Start-BitsTransfer -Source $url -Destination $dest

Expand-Archive -Path "..\..\..\Toolkits\SysinternalsSuite.zip" -DestinationPath "..\..\..\Toolkits\SysinternalsSuite"