# Security policy

## Reporting a vulnerability

Please report security issues privately via [GitHub Security Advisories](https://github.com/redcode-labs/RedSand/security/advisories/new) rather than a public issue.

Include:
- A description of the issue and its impact
- Steps to reproduce
- Affected files / commit hash if known

You can expect an initial response within a week.

## Scope

In scope:
- The `.wsb` configuration shipping with this repo (insecure defaults, isolation gaps)
- Scripts under `Utils/Scripts/` (command injection, unsafe downloads, privilege issues)
- The CI workflows in `.github/workflows/`

Out of scope:
- Vulnerabilities in tools this project downloads or installs (REtoolkit, Sysinternals, Get-ZimmermanTools, Chocolatey, Scoop, 7-Zip). Report those to their respective maintainers.
- Generic limitations of Windows Sandbox itself. Report those to Microsoft.

## Threat model — what RedSand is and isn't

RedSand is a convenience layer on top of Windows Sandbox aimed at cybersecurity enthusiasts. It assumes:

- The host machine is trusted.
- The sandbox VM is **disposable** — state inside it evaporates on close.
- The `Files/` and `Utils/Toolkits/` directories are mapped from the host. Anything written to `Files/` from inside the sandbox **persists on the host** after shutdown.
- Networking is enabled by default. Adjust `<Networking>` in the `.wsb` if your work requires isolation from the internet.

RedSand is **not** a research-grade malware analysis platform. For analyzing live malware that may attempt sandbox escape or host fingerprinting, use a dedicated, network-isolated environment (e.g. REMnux, FLARE-VM on dedicated hardware, or commercial sandbox products).
