# if you're wondering why this is in 'InSandbox' directory, lemme explain real quick
# REtoolkit will add some options to Context Menu, hence I think it makes more sense to download it within the Sandbox and then install it
# + also this is a nice example of what you can add in customScript.ps1 ))
# (since 2026.04 the release ships as a .7z containing the setup.exe — we extract first, then run it)

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Resolve the latest release dynamically so a hardcoded version doesn't rot
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/mentebinaria/retoolkit/releases/latest"
$asset = $release.assets | Where-Object { $_.name -like '*.7z' } | Select-Object -First 1
if (-not $asset) { throw "Could not find a .7z asset in the latest retoolkit release" }

$desktop = "C:\users\WDAGUtilityAccount\Desktop"
$archive = Join-Path $desktop $asset.name
$extractDir = Join-Path $desktop 'retoolkit_extracted'
$sevenZr = Join-Path $desktop '7zr.exe'

# Start-BitsTransfer streams to disk instead of buffering in memory like Invoke-WebRequest
Start-BitsTransfer -Source $asset.browser_download_url -Destination $archive

# Standalone 7-Zip extractor — no install needed, can extract .7z
Start-BitsTransfer -Source 'https://www.7-zip.org/a/7zr.exe' -Destination $sevenZr

try {
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    & $sevenZr x $archive "-o$extractDir" -y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "7zr.exe exited with code $LASTEXITCODE" }

    $installer = Get-ChildItem -Path $extractDir -Recurse -Filter '*_setup.exe' | Select-Object -First 1
    if (-not $installer) { throw "No *_setup.exe found inside $($asset.name)" }

    & $installer.FullName /verysilent /suppressmsgboxes | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "retoolkit installer exited with code $LASTEXITCODE" }
} finally {
    Remove-Item $archive -Force -ErrorAction SilentlyContinue
    Remove-Item $sevenZr -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
}
