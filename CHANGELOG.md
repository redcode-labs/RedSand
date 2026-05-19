# Changelog

All notable changes to RedSand are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Note: the artifacts here are Windows Sandbox configs and PowerShell scripts rather than a versioned API, so semver is followed loosely — minor version bumps reflect meaningful additions to the user-facing surface.

## [2.1] — 2026-05-19

### Added
- **`build-wsb.ps1`** — interactive `.wsb` builder. Walks every Windows Sandbox setting (isolation knobs, mapped folders, logon command) and writes a configuration file. Output path is freeform (relative or absolute).
- **`build-toolkit-installer.ps1`** — interactive generator for scoop-based tool-pack installers. Pick buckets and tools, choose global (sandbox / admin) or per-user scope; emits an installer that adapts to the chosen scope (drops `--global` and the admin requirement for per-user).

### Fixed
- **Encoding sweep across every authored script.** Comments contained em-dashes (`—`) and one arrow (`→`). Windows PowerShell 5 reads files as Windows-1252 by default; the third byte of those UTF-8 sequences decodes as a smart-quote, which the parser treats as a string delimiter — producing cascading parse errors hundreds of lines below the offender. All occurrences replaced with ASCII equivalents.
- `Set-ExecutionPolicy -Scope LocalMachine` erroring under newer sandbox builds' Group Policy lockout — `setup.ps1` now falls back through scopes and never aborts the rest of the script.

## [2.0] — 2026-05-18

### Added
- **Profiles** — `profiles/RedSand-Analysis.wsb` (max-isolation RE / dynamic + static analysis) and `profiles/RedSand-Forensics.wsb` (evidence triage), alongside the existing default. Both default to network off, audio/video/printer/clipboard disabled, ProtectedClient on, and read-only `Input/` + read-write `Output/` host mappings. `profiles/RedSand-Pentest.wsb` is stashed in `.drafts/` pending demand.
- **`Input/` (read-only)** and **`Output/` (read-write)** host directories. Mapped by Analysis and Forensics profiles; the `Output/` `MappedFolder` block in each wsb is marked for trivial removal if you want zero writable host mappings.
- **`disableDefender.ps1`** — disables sandbox-local Defender (host untouched). Tamper-Protection aware.
- **`excludeInputFromDefender.ps1`** — softer alternative; whitelists `Input/` only.
- **`installAnalysisTools.ps1`** — lightweight scoop pack: HxD, dnSpy, PE-bear, Detect It Easy, x64dbg, System Informer, Wireshark.
- **`installForensicsTools.ps1`** — narrow scoop pack: HxD, ExifTool.
- **`prepareForRedSand.ps1`** — host-side orchestrator. Checks the sandbox feature is enabled, then runs the OnHost downloader scripts (interactive prompt, or `-All` / `-Sysinternals` / `-Zimmerman` flags).
- Gallery section in the README.
- Recursive `.gitignore` entries for macOS clutter (`**/.DS_Store`, `**/._DS_Store`).

### Changed
- `setup.ps1` now writes a timestamped log to `Desktop\setup.log` for post-mortem diagnostics, falls back gracefully when `Set-ExecutionPolicy -Scope LocalMachine` is blocked by Group Policy (tries `CurrentUser`, then logs and continues regardless), and restarts `explorer.exe` at the end so the dark-theme registry change actually takes effect on the running shell.
- `installChocoAndScoop.ps1` now also installs `git` via scoop (required for `scoop bucket add` to clone bucket repos).
- `installAnalysisTools.ps1` and `installForensicsTools.ps1` self-heal by installing `git` if missing before adding the `extras` bucket.
- `downloadZimmermanTools.ps1` fetches the latest `Get-ZimmermanTools.ps1` directly from Eric Zimmerman's GitHub repo — the backblaze `.zip` shipped a stale copy hardcoded to an `index.md` path that has since 404'd. Also `Push-Location`s into the destination so downloads land in `Utils/Toolkits/Zimmerman/` regardless of caller PWD, and `Unblock-File`s the extracted script to skip PowerShell's Mark-of-the-Web prompt.
- URL liveness CI updated to the new Zimmerman endpoints (`tools.ericzimmermanstools.com` and the GitHub-hosted script).

## [1.1] — 2026-05-17

### Added
- Project hygiene: `CONTRIBUTING.md`, `SECURITY.md`, issue/PR templates, Dependabot for GitHub Actions.
- CI: PSScriptAnalyzer linting, PowerShell syntax parsing, and `.wsb` XML validation (`.github/workflows/ci.yml`).
- Weekly URL liveness check for upstream installer URLs (`.github/workflows/url-liveness.yml`).
- `.wsb` hardening defaults: `ProtectedClient` enabled, `ClipboardRedirection` disabled, explicit `MemoryInMB`.
- README rewritten from the GitHub wiki contents, with CI badge and threat-model / WSL caveats section.

### Changed
- Default `RedSand.wsb` moved from repo root to `profiles/RedSand.wsb`. Mapped folder paths updated to `..\Utils\` / `..\Files\`.
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
