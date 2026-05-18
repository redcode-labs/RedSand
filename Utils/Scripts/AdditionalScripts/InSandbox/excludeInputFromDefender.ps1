#Requires -Version 5.1
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Adds the mapped Input/ folder to Defender's exclusion list INSIDE the sandbox.
# Real-time scanning stays on for everywhere else - only files under Input/ are
# unscanned. Use this when you want Defender protecting the rest of the sandbox
# while letting you handle samples in Input/. For a full disable, see
# disableDefender.ps1.
#
# Host Defender is untouched.

$inputPath = 'C:\users\WDAGUtilityAccount\Desktop\Input'

if (-not (Test-Path $inputPath)) {
    Write-Warning "Input folder not found at $inputPath - is the profile mapping it?"
}

try {
    Add-MpPreference -ExclusionPath $inputPath -ErrorAction Stop
    Write-Host "Added Defender exclusion for $inputPath (sandbox-local)." -ForegroundColor Yellow
} catch {
    Write-Warning "Could not add Defender exclusion - Tamper Protection may be active."
    Write-Warning "Error: $($_.Exception.Message)"
}
