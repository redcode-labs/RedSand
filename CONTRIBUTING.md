# Contributing to RedSand

Thanks for your interest! New scripts, `.wsb` profiles, and doc improvements are all welcome.

## Before you start

- For non-trivial changes, open an issue first to discuss the approach.
- Keep changes scoped: one PR per logical change.

## Development setup

There's nothing to install — everything is `.ps1` and `.wsb`. To test your changes properly you need a host that already has Windows Sandbox enabled (see `enableSandboxFeature.ps1`).

## Style

- Prefer full cmdlet names over aliases (`Invoke-RestMethod`, not `irm`).
- New scripts should start with `#Requires -Version 5.1` and `$ErrorActionPreference = 'Stop'`.
- Use `$PSScriptRoot` for paths in scripts that depend on their own location — avoid relative paths that break depending on the caller's PWD.
- If a script downloads a release asset, resolve "latest" dynamically via the project's release API rather than pinning a version.
- Avoid `Write-Host` unless you genuinely need formatted user-facing output — otherwise prefer pipeline output.

## Adding a new script

1. Put it in the appropriate directory:
   - `Utils/Scripts/AdditionalScripts/OnHost/` — runs on the host
   - `Utils/Scripts/AdditionalScripts/InSandbox/` — runs inside the sandbox
2. Add a row to the **Scripts reference** table in `README.md`.
3. If it pulls from a new upstream URL, add that URL to `.github/workflows/url-liveness.yml`.

## CI

PRs run PSScriptAnalyzer, parse every `.ps1`, and validate the `.wsb` XML on `ubuntu-latest`. Make sure CI is green before requesting review.

Sandbox-level behavior can't be tested in CI (GitHub-hosted Windows runners don't support nested virtualization). For any code change, confirm manually that it works inside a real sandbox and note that in the PR description.

## Security

Don't open public issues for security vulnerabilities — see [SECURITY.md](SECURITY.md).
