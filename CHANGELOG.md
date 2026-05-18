# Changelog

All notable changes to RedSand are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Note: the artifacts here are Windows Sandbox configs and PowerShell scripts rather than a versioned API, so semver is followed loosely — minor version bumps reflect meaningful additions to the user-facing surface.

## [2.0]

### Added
- **Profiles** — `profiles/RedSand-Analysis.wsb` (max-isolation RE / dynamic + static analysis) and `profiles/RedSand-Forensics.wsb` (evidence triage), alongside the existing default. Both default to network off, audio/video/printer/clipboard disabled, ProtectedClient on, and read-only `Input/` + read-write `Output/` host mappings. `profiles/RedSand-Pentest.wsb` is stashed in `.drafts/` pending demand.
- **`Input/` (read-only)** and **`Output/` (read-write)** host directories. Mapped by Analysis and Forensics profiles; the `Output/` `MappedFolder` block in each wsb is marked for trivial removal if you want zero writable host mappings.
- **`disableDefender.ps1`** — disables sandbox-local Defender (host untouched). Tamper-Protection aware.
- **`excludeInputFromDefender.ps1`** — softer alternative; whitelists `Input/` only.
- **`installAnalysisTools.ps1`** — lightweight scoop pack: HxD, dnSpy, PE-bear, Detect It Easy, x64dbg, System Informer, Wireshark.
- **`installForensicsTools.ps1`** — narrow scoop pack: HxD, ExifTool.
- **`prepareForRedSand.ps1`** — host-side orchestrator. Checks the sandbox feature is enabled, then runs the OnHost downloader scripts (interactive prompt, or `-All` / `-Sysinternals` / `-Zimmerman` flags).

### Changed
- Default `RedSand.wsb` moved from repo root to `profiles/RedSand.wsb`. Mapped folder paths updated to `..\Utils\` / `..\Files\`.

## [1.1] — 2026-05-17

### Added
- Project hygiene: `CONTRIBUTING.md`, `SECURITY.md`, issue/PR templates, Dependabot for GitHub Actions.
- CI: PSScriptAnalyzer linting, PowerShell syntax parsing, and `.wsb` XML validation (`.github/workflows/ci.yml`).
- Weekly URL liveness check for upstream installer URLs (`.github/workflows/url-liveness.yml`).
- `.wsb` hardening defaults: `ProtectedClient` enabled, `ClipboardRedirection` disabled, explicit `MemoryInMB`.
- README rewritten from the GitHub wiki contents, with CI badge and threat-model / WSL caveats section.

### Changed
- `installREToolkit.ps1` no longer pins the `2022.04` release — fetches latest from the GitHub releases API and handles the `.7z`-wrapped installer introduced in `2026.04`.
- OnHost downloader scripts anchor paths with `$PSScriptRoot` so they work regardless of caller PWD.
- `installChocoAndScoop.ps1` passes `-RunAsAdmin` to Scoop (required since the sandbox runs as admin) and verifies install via on-disk file existence rather than PATH.
- All PowerShell scripts declare `#Requires -Version 5.1` and set `$ErrorActionPreference = 'Stop'`.
- README footer correctly identifies the license as ISC (was mislabeled MIT briefly).

### Fixed
- Scoop install silently failed inside the admin sandbox — now correctly invoked with `-RunAsAdmin`.
- `Expand-Archive` re-run failures in OnHost downloaders (added `-Force`).

## [1.0] — 2022-08-18

### Added
- Initial `RedSand.wsb` sandbox config with mapped `Utils/` (read-only) and `Files/` (read-write) folders.
- `setup.ps1` — runs on logon: dark theme, dev mode unlock, RedSand wallpaper, ExecutionPolicy unrestricted.
- OnHost downloaders for the Sysinternals Suite and Eric Zimmerman's forensics tools.
- `enableSandboxFeature.ps1` host helper.
- In-sandbox scripts: `godMode.ps1`, `customScript.ps1`, `installChocoAndScoop.ps1`, `installREToolkit.ps1` (pinned to retoolkit 2022.04 at the time).
- ISC license.

[Unreleased]: https://github.com/redcode-labs/RedSand/compare/v.1.1...HEAD
[1.1.0]: https://github.com/redcode-labs/RedSand/compare/v.1.0...v.1.1
[1.0.0]: https://github.com/redcode-labs/RedSand/releases/tag/v.1.0
