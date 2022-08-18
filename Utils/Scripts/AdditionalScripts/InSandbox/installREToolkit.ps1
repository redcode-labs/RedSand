# if you're wondering why this is in 'InSandbox' directory, lemme explain real quick
# REtoolkit will add some options to Context Menu, hence I think it makes more sense to download it within the Sandbox and then install it
# + also this is a nice example of what you can add in customScript.ps1 ))

$url = "https://github.com/mentebinaria/retoolkit/releases/download/2022.04/retoolkit_2022.04_setup.exe"

$dest = "C:\users\WDAGUtilityAccount\Desktop\setup.exe"

# TIL: Invoke-WebRequest is slower because it has to buffer the file in memory first before writing it to a disk
Start-BitsTransfer -Source $url -Destination $dest

C:\users\WDAGUtilityAccount\Desktop\setup.exe /verysilent /suppressmsgboxes