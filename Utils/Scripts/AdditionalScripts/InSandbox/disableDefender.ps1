#Requires -Version 5.1
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Disables Windows Defender INSIDE the sandbox only. The sandbox runs as
# WDAGUtilityAccount (admin) with its own Defender instance - this does NOT
# touch Defender on your host. The setting evaporates with the sandbox.
#
# Use this when analyzing samples that Defender would otherwise quarantine.
# For a softer touch (keep real-time scanning on, just whitelist Input/),
# use excludeInputFromDefender.ps1 instead.

try {
    Set-MpPreference -DisableRealtimeMonitoring   $true     -ErrorAction Stop
    Set-MpPreference -DisableBehaviorMonitoring   $true     -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBlockAtFirstSeen     $true     -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection       $true     -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning       $true     -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting               Disabled  -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent        NeverSend -ErrorAction SilentlyContinue
    Write-Host "Defender (sandbox-local) disabled. Host Defender is unaffected." -ForegroundColor Yellow
} catch {
    Write-Warning "Could not fully disable Defender - Tamper Protection may be active."
    Write-Warning "Error: $($_.Exception.Message)"
    Write-Warning "If Tamper Protection is on, disable it via Windows Security UI inside the sandbox, then re-run."
}
