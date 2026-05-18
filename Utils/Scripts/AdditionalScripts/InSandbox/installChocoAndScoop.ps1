#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Scoop - sandbox runs as admin, so -RunAsAdmin is required or Scoop refuses to install
try {
    Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    if (-not (Test-Path "$HOME\scoop\shims\scoop.cmd")) {
        Write-Error "Scoop install completed but shim not found at expected path"
    }
} catch {
    Write-Error "Error during Scoop install: $($_.Exception.Message)"
}

# Git - required for `scoop bucket add` to clone bucket repos. Scoop ships
# without it, so any tool-pack script that adds the extras bucket would fail on a fresh install
try {
    $env:PATH = "$HOME\scoop\shims;$env:PATH"
    scoop install --global git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git install completed but command not resolvable"
    }
} catch {
    Write-Error "Error during git install: $($_.Exception.Message)"
}


# Chocolatey
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    if (-not (Test-Path "$env:ProgramData\chocolatey\bin\choco.exe")) {
        Write-Error "Chocolatey install completed but choco.exe not found at expected path"
    }
} catch {
    Write-Error "Error during Chocolatey install: $($_.Exception.Message)"
}
