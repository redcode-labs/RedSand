# Scoop
try {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    # add Scoop to PATH
    $env:PATH += ";$($HOME)\scoop\shims"
} catch {
    Write-Error "Error occured during installation of Scoop $($_.Exception.Message)"
    return
}
# Chocolatey
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} catch {
    Write-Error "Error occured during installation of Chocolatey: $($_.Exception.Message)"
}