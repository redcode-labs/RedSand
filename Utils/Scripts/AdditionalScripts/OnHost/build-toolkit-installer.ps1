#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Interactive builder for scoop-based tool-pack installers. Prompts for
# output path, install scope, buckets, and tool list - then writes a script
# that you can run inside a Windows Sandbox (global / admin install) OR
# from any local PowerShell session (per-user install).
#
# Output path is freeform - relative or absolute, anywhere on disk.


# -------- prompt helpers --------

function Read-Option {
    param([string]$Prompt, [string[]]$Options, [int]$DefaultIdx = 0)
    Write-Host ""
    Write-Host $Prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $marker = if ($i -eq $DefaultIdx) { '*' } else { ' ' }
        Write-Host ("  {0} {1}) {2}" -f $marker, ($i + 1), $Options[$i])
    }
    while ($true) {
        $resp = Read-Host "Choice [$($DefaultIdx + 1)]"
        if ([string]::IsNullOrWhiteSpace($resp)) { return $Options[$DefaultIdx] }
        $parsed = 0
        if ([int]::TryParse($resp, [ref]$parsed)) {
            $idx = $parsed - 1
            if ($idx -ge 0 -and $idx -lt $Options.Count) { return $Options[$idx] }
        }
        Write-Host "  Invalid choice; try again." -ForegroundColor Yellow
    }
}

function Read-WithDefault {
    param([string]$Prompt, [string]$Default)
    $val = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($val)) { return $Default }
    return $val
}

function Read-YesNo {
    param([string]$Prompt, [bool]$Default = $true)
    $hint = if ($Default) { '[Y/n]' } else { '[y/N]' }
    while ($true) {
        $resp = Read-Host "$Prompt $hint"
        if ([string]::IsNullOrWhiteSpace($resp)) { return $Default }
        switch -Regex ($resp.Trim().ToLower()) {
            '^y(es)?$' { return $true }
            '^n(o)?$'  { return $false }
            default    { Write-Host "  Please answer y or n." -ForegroundColor Yellow }
        }
    }
}


# -------- flow --------

Write-Host ""
Write-Host "=== RedSand custom toolkit installer builder ===" -ForegroundColor Green
Write-Host "Generates a scoop-based installer .ps1 with your chosen tool list."
Write-Host ""

# Output (any path works - absolute, relative)
$outFile = Read-WithDefault -Prompt 'Output path' -Default 'Utils\Scripts\AdditionalScripts\InSandbox\installCustomTools.ps1'
if ($outFile -notlike '*.ps1') { $outFile = "$outFile.ps1" }

$description = Read-WithDefault -Prompt 'One-line description (for the script header)' -Default 'Custom scoop tool pack'

# Install scope determines --global usage + admin requirement in the emitted script
$scope = Read-Option 'Install scope?' @(
    'Global (sandbox / any admin install)',
    'Per-user (local non-admin install)'
) 0
$useGlobal = ($scope -like 'Global*')
$globalFlag = if ($useGlobal) { ' --global' } else { '' }

# Buckets
$buckets = @()
Write-Host ""
Write-Host "--- Buckets ---" -ForegroundColor Cyan
Write-Host "Scoop's 'main' bucket is always available; add others as needed."

if (Read-YesNo -Prompt "Add 'extras' bucket?" -Default $true) { $buckets += 'extras' }
foreach ($candidate in 'nirsoft', 'versions', 'java') {
    if (Read-YesNo -Prompt "Add '$candidate' bucket?" -Default $false) { $buckets += $candidate }
}
while (Read-YesNo -Prompt 'Add another custom bucket?' -Default $false) {
    $name = Read-Host "  Bucket name (or 'name <git-url>' for a custom feed)"
    if (-not [string]::IsNullOrWhiteSpace($name)) { $buckets += $name.Trim() }
}

# Tools
$tools = @()
Write-Host ""
Write-Host "--- Tools ---" -ForegroundColor Cyan
Write-Host "Enter tool names, comma- or space-separated. Example: hxd, dnspy, x64dbg"
$first = Read-Host 'Tools'
if (-not [string]::IsNullOrWhiteSpace($first)) {
    $tools += @($first -split '[,\s]+' | Where-Object { $_ })
}
while (Read-YesNo -Prompt 'Add more (one at a time)?' -Default $false) {
    $name = Read-Host '  Tool name'
    if (-not [string]::IsNullOrWhiteSpace($name)) { $tools += $name.Trim() }
}

if ($tools.Count -eq 0) {
    Write-Host "No tools listed; aborting." -ForegroundColor Yellow
    return
}

# Summary + confirm
$resolvedOut = if (Test-Path -IsValid $outFile) { [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $outFile)) } else { $outFile }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "Output:       $outFile"
Write-Host "  (full path) $resolvedOut"
Write-Host "Description:  $description"
Write-Host "Scope:        $scope"
Write-Host "Buckets:      $(if ($buckets.Count) { $buckets -join ', ' } else { '(none beyond main)' })"
Write-Host "Tools ($($tools.Count)):"
foreach ($t in $tools) { Write-Host "  - $t" }
Write-Host ""

if (-not (Read-YesNo -Prompt 'Write this file?' -Default $true)) {
    Write-Host "Aborted." -ForegroundColor Yellow
    return
}


# -------- emit the installer script --------

$lines = @()
$lines += '#Requires -Version 5.1'
if ($useGlobal) {
    $lines += '#Requires -RunAsAdministrator'
}
$lines += "`$ErrorActionPreference = 'Stop'"
$lines += ''
$lines += "# $description"
$lines += '# Generated by build-toolkit-installer.ps1'
$lines += '#'
if ($useGlobal) {
    $lines += '# Global / admin install. Run installChocoAndScoop.ps1 first inside the'
    $lines += '# sandbox, or install scoop manually with -RunAsAdmin.'
} else {
    $lines += '# Per-user install. Requires scoop already installed (https://scoop.sh).'
}
$lines += ''
$lines += 'if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {'
$lines += '    throw "scoop not found - install scoop first (https://scoop.sh)"'
$lines += '}'
$lines += ''
$lines += '# Scoop needs git to clone bucket repos; install it if missing'
$lines += 'if (-not (Get-Command git -ErrorAction SilentlyContinue)) {'
$lines += '    Write-Host "Installing git (required for scoop buckets)..." -ForegroundColor Cyan'
$lines += "    scoop install$globalFlag git"
$lines += '}'
$lines += ''
foreach ($b in $buckets) {
    $lines += "scoop bucket add $b"
}
if ($buckets.Count -gt 0) { $lines += '' }

$lines += "`$tools = @("
for ($i = 0; $i -lt $tools.Count; $i++) {
    $sep = if ($i -eq $tools.Count - 1) { '' } else { ',' }
    $lines += "    '$($tools[$i])'$sep"
}
$lines += ')'
$lines += ''
$lines += 'foreach ($tool in $tools) {'
$lines += '    Write-Host "Installing $tool..." -ForegroundColor Cyan'
$lines += "    scoop install$globalFlag `$tool"
$lines += '    if ($LASTEXITCODE -ne 0) {'
$lines += '        Write-Warning "scoop returned exit code $LASTEXITCODE installing $tool"'
$lines += '    }'
$lines += '}'
$lines += ''
$lines += 'Write-Host "Tools installed." -ForegroundColor Green'

# Write
$parentDir = Split-Path -Parent $outFile
if ($parentDir -and -not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}
Set-Content -Path $outFile -Value ($lines -join [Environment]::NewLine) -Encoding UTF8

Write-Host ""
Write-Host "Wrote $outFile" -ForegroundColor Green
Write-Host "  (full path) $resolvedOut"
Write-Host ""
if ($useGlobal) {
    Write-Host "Run inside the sandbox (after installChocoAndScoop.ps1):" -ForegroundColor Cyan
} else {
    Write-Host "Run from any PowerShell session (scoop must be installed):" -ForegroundColor Cyan
}
Write-Host "  powershell.exe -ExecutionPolicy Bypass -File `"$resolvedOut`""
