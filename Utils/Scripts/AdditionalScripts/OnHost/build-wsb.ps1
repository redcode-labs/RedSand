#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Interactive .wsb builder. Walks through each Windows Sandbox setting,
# prompts for a value, then writes a configuration file. Output path can
# be anywhere - typing an absolute path works too.
#
# Run from anywhere:
#   powershell.exe -ExecutionPolicy Bypass -File .\Utils\Scripts\AdditionalScripts\OnHost\build-wsb.ps1


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

function Escape-Xml {
    param([string]$Text)
    return ($Text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;')
}


# -------- flow --------

Write-Host ""
Write-Host "=== RedSand .wsb builder ===" -ForegroundColor Green
Write-Host "Press Enter at any prompt to accept the default (marked with *)."
Write-Host ""

# Output (any path works - absolute, relative, ~/whatever)
$outFile = Read-WithDefault -Prompt 'Output path' -Default 'profiles\custom.wsb'

# Isolation knobs - defaults match the RedSand "default" profile
$ternary = @('Default', 'Enable', 'Disable')
$binary  = @('Default', 'Disable')

$networking      = Read-Option 'Networking?'                                      $binary  0
$protectedClient = Read-Option 'ProtectedClient (AppContainer isolation)?'        $ternary 1   # Enable
$clipboard       = Read-Option 'ClipboardRedirection?'                            $ternary 2   # Disable
$audio           = Read-Option 'AudioInput (microphone)?'                         $ternary 0
$video           = Read-Option 'VideoInput (camera)?'                             $ternary 0
$printer         = Read-Option 'PrinterRedirection?'                              $ternary 0
$vgpu            = Read-Option 'VGpu (virtualized GPU)?'                          $ternary 0

Write-Host ""
$memory = Read-WithDefault -Prompt 'Memory (MB)' -Default '4096'
if ([int]::TryParse($memory, [ref]$null) -and [int]$memory -lt 2048) {
    Write-Host "  Note: values below 2048 MB will be auto-raised by Sandbox." -ForegroundColor Yellow
}

# Mapped folders
$mappedFolders = @()
Write-Host ""
Write-Host "--- Mapped folders (paths are relative to the .wsb's location) ---" -ForegroundColor Cyan

if (Read-YesNo -Prompt 'Add standard RedSand mappings (..\Utils\ read-only, ..\Files\ read-write)?' -Default $true) {
    $mappedFolders += @{ Host = '..\Utils\'; ReadOnly = $true;  Sandbox = $null }
    $mappedFolders += @{ Host = '..\Files\'; ReadOnly = $false; Sandbox = $null }
}

while (Read-YesNo -Prompt 'Add another mapped folder?' -Default $false) {
    $hostPath = Read-Host '  Host path (any: ..\Input\, or absolute like D:\Tools\Binja)'
    if ([string]::IsNullOrWhiteSpace($hostPath)) { continue }
    $ro = Read-YesNo -Prompt '  Read-only?' -Default $true
    $sandboxPath = $null
    if (Read-YesNo -Prompt '  Map to a specific path inside the sandbox (defaults to Desktop\<folder name>)?' -Default $false) {
        $sandboxPath = Read-Host '    Sandbox path (e.g. C:\BinaryNinja)'
        if ([string]::IsNullOrWhiteSpace($sandboxPath)) { $sandboxPath = $null }
    }
    $mappedFolders += @{ Host = $hostPath; ReadOnly = $ro; Sandbox = $sandboxPath }
}

# Logon command - three-way
$logonChoice = Read-Option 'Logon command?' @(
    'Auto-run RedSand setup.ps1',
    'Custom command',
    'None'
) 0
$useSetup    = ($logonChoice -eq 'Auto-run RedSand setup.ps1')
$customLogon = $null
if ($logonChoice -eq 'Custom command') {
    $customLogon = Read-Host '  Full command (e.g. powershell.exe -File C:\...)'
}

# Summary + confirm
$resolvedOut = if (Test-Path -IsValid $outFile) { [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $outFile)) } else { $outFile }

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "Output:               $outFile"
Write-Host "  (full path)         $resolvedOut"
Write-Host "Networking:           $networking"
Write-Host "ProtectedClient:      $protectedClient"
Write-Host "ClipboardRedirection: $clipboard"
Write-Host "AudioInput:           $audio"
Write-Host "VideoInput:           $video"
Write-Host "PrinterRedirection:   $printer"
Write-Host "VGpu:                 $vgpu"
Write-Host "MemoryInMB:           $memory"
if ($mappedFolders.Count -gt 0) {
    Write-Host "Mapped folders:"
    foreach ($mf in $mappedFolders) {
        $mode = if ($mf.ReadOnly) { 'read-only' } else { 'read-write' }
        $dest = if ($mf.Sandbox) { " -> $($mf.Sandbox)" } else { '' }
        Write-Host ("  - {0}{1} ({2})" -f $mf.Host, $dest, $mode)
    }
}
Write-Host "LogonCommand:         $logonChoice"
if ($customLogon) { Write-Host "  (command)           $customLogon" }
Write-Host ""

if (-not (Read-YesNo -Prompt 'Write this file?' -Default $true)) {
    Write-Host "Aborted." -ForegroundColor Yellow
    return
}

# Build XML
$lines = @()
$lines += '<?xml version="1.0" encoding="UTF-8"?>'
$lines += '<Configuration>'
$lines += "<VGpu>$vgpu</VGpu>"
$lines += "<Networking>$networking</Networking>"
$lines += "<ProtectedClient>$protectedClient</ProtectedClient>"
$lines += "<ClipboardRedirection>$clipboard</ClipboardRedirection>"
$lines += "<AudioInput>$audio</AudioInput>"
$lines += "<VideoInput>$video</VideoInput>"
$lines += "<PrinterRedirection>$printer</PrinterRedirection>"
$lines += "<MemoryInMB>$memory</MemoryInMB>"

if ($mappedFolders.Count -gt 0) {
    $lines += '<MappedFolders>'
    foreach ($mf in $mappedFolders) {
        $lines += '   <MappedFolder>'
        $lines += "     <HostFolder>$(Escape-Xml $mf.Host)</HostFolder>"
        if ($mf.Sandbox) {
            $lines += "     <SandboxFolder>$(Escape-Xml $mf.Sandbox)</SandboxFolder>"
        }
        $lines += "     <ReadOnly>$($mf.ReadOnly.ToString().ToLower())</ReadOnly>"
        $lines += '   </MappedFolder>'
    }
    $lines += '</MappedFolders>'
}

if ($useSetup -or $customLogon) {
    $lines += '<LogonCommand>'
    if ($useSetup) {
        $lines += '   <Command>powershell.exe -ExecutionPolicy Bypass -File C:\users\WDAGUtilityAccount\Desktop\Utils\Scripts\DefaultScripts\setup.ps1</Command>'
    } elseif ($customLogon) {
        $lines += "   <Command>$(Escape-Xml $customLogon)</Command>"
    }
    $lines += '</LogonCommand>'
}

$lines += '</Configuration>'

# Ensure parent dir exists, then write
$outDir = Split-Path -Parent $outFile
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
Set-Content -Path $outFile -Value ($lines -join [Environment]::NewLine) -Encoding UTF8

Write-Host ""
Write-Host "Wrote $outFile" -ForegroundColor Green
Write-Host "  (full path) $resolvedOut"
Write-Host "Double-click it in Explorer to launch your custom sandbox."
