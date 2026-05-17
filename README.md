<h1 align="center">RedSand</h1>
<div align="center">
  <img src="RedSandLogo.png" alt="RedSand logo"><br>
  Windows Sandbox environment for cybersecurity enthusiasts<br><br>
  <a href="https://github.com/redcode-labs/RedSand/actions/workflows/ci.yml"><img src="https://github.com/redcode-labs/RedSand/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/redcode-labs/RedSand/releases">Releases</a>
</div>

## About

RedSand is a pre-made `.wsb` that spins up a Windows Sandbox tailored for security work — just double-click the file. It maps a read-only `Utils/` folder (scripts, toolkits) and a read-write `Files/` folder (your working files) into the VM, then runs a setup script on logon.

Modify the `.wsb` and `.ps1` files freely to match your workflow. Contributions of all kinds — new scripts, `.wsb` tweaks, documentation — are welcome.

## Quick start

1. Enable the Windows Sandbox feature (one-time, requires Windows 10/11 Pro / Enterprise / Education):
   ```powershell
   # Run as Administrator
   .\Utils\Scripts\AdditionalScripts\OnHost\enableSandboxFeature.ps1
   ```
   Reboot if prompted.
2. Double-click `profiles\RedSand.wsb` in File Explorer.
3. The sandbox boots, `setup.ps1` runs automatically, and you land on a desktop ready to work.

## What you get

The default `RedSand.wsb` enables a hardened baseline suitable for analysis work:

| Setting | Value | Why |
|---|---|---|
| `ProtectedClient` | Enable | Stricter RDP security inside the sandbox |
| `ClipboardRedirection` | Disable | Host clipboard can't leak into / out of the VM |
| `MemoryInMB` | 4096 | Comfortable for most tooling |
| `Networking` | Default | Internet on — adjust to taste |

On logon, `setup.ps1` also:

- Sets ExecutionPolicy to `Unrestricted` (sandbox-local, throwaway)
- Enables developer mode (`AllowDevelopmentWithoutDevLicense`)
- Switches to dark theme
- Applies the RedSand wallpaper

Loosen the wsb defaults if your workload needs the host clipboard or more RAM.

## Directory layout

```
RedSand/
├── profiles/
│   └── RedSand.wsb             # Sandbox config — double-click to launch
├── Files/                      # Read-write; drop samples / payloads here
├── Utils/
│   ├── Toolkits/               # Tools downloaded by OnHost scripts land here
│   └── Scripts/
│       ├── DefaultScripts/     # Run automatically on logon
│       │   └── setup.ps1
│       └── AdditionalScripts/
│           ├── OnHost/         # Run these on your host before launching
│           └── InSandbox/      # Run these inside the sandbox (manual or via wsb)
```

`Utils/` is mapped read-only; `Files/` read-write. Anything you download on the host into `Utils/Toolkits/` (via the OnHost scripts) becomes available inside the sandbox at `C:\users\WDAGUtilityAccount\Desktop\Utils\Toolkits\`.

## Scripts reference

### On-host (run before launching the sandbox, from your normal Windows session)

| Script | What it does |
|---|---|
| `enableSandboxFeature.ps1` | Enables the Windows Sandbox optional feature. Requires admin; may need a reboot. |
| `downloadSysinternalsSuite.ps1` | Downloads SysinternalsSuite into `Utils/Toolkits/SysinternalsSuite/`. |
| `downloadZimmermanTools.ps1` | Fetches Eric Zimmerman's forensics tools into `Utils/Toolkits/Zimmerman/`. |

### In-sandbox (run inside the VM, manually or by wiring into `RedSand.wsb`)

| Script | What it does |
|---|---|
| `installChocoAndScoop.ps1` | Installs both [Scoop](https://scoop.sh) and [Chocolatey](https://chocolatey.org). |
| `installREToolkit.ps1` | Downloads the latest [REtoolkit](https://github.com/mentebinaria/retoolkit) release and runs the silent installer. |
| `godMode.ps1` | Creates a "God Mode" control-panel folder on the desktop. |
| `customScript.ps1` | Empty hook — drop whatever you want auto-run here. |

To auto-run any in-sandbox script on logon, uncomment the matching line in `RedSand.wsb`:

```xml
<Command>powershell.exe -ExecutionPolicy Bypass -File C:\users\WDAGUtilityAccount\Desktop\Utils\Scripts\AdditionalScripts\InSandbox\installREToolkit.ps1</Command>
```

## Customization

The `.wsb` schema is documented by Microsoft: [Windows Sandbox configuration](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file).

Common tweaks:

- **More RAM** — bump `<MemoryInMB>`
- **Re-enable clipboard** — set `<ClipboardRedirection>Enable</ClipboardRedirection>` (handy for paste-in samples, but breaks the isolation guarantee)
- **GPU passthrough** — already `Default`; change to `Disable` if you want strict CPU-only execution
- **Extra logon commands** — add more `<Command>` entries in `<LogonCommand>`

For one-off in-sandbox setup, edit `customScript.ps1` and uncomment its `<Command>` line in the wsb — keeps your customizations out of the always-run `setup.ps1`.

## Security notes

A few things worth knowing before you drop sensitive material into the sandbox:

- **`Files/` persists on the host.** The sandbox VM is destroyed on shutdown, but anything written to `C:\users\WDAGUtilityAccount\Desktop\Files\` from inside is the same bytes as `./Files/` on your host. Treat that folder as host filesystem, not sandbox memory — don't put credentials there, and be careful about what malware artifacts you drop into it.
- **Don't analyze live evasive malware here.** Windows Sandbox is a convenience VM, not a research-grade analysis environment. Samples that fingerprint sandboxes, attempt escape via shared kernel surface, or rely on Hyper-V tricks may behave unexpectedly. Use REMnux / FLARE-VM on dedicated hardware for that.
- **Defaults are a baseline, not a guarantee.** RedSand ships with `ProtectedClient`, clipboard disabled, and a fixed memory cap, but networking is on by default. Tighten the `.wsb` further if your threat model requires it.
- **Bootstrap scripts run remote code.** `installChocoAndScoop.ps1` and `installREToolkit.ps1` execute code fetched from upstream over HTTPS — this is the documented install pattern for those projects, but it does mean a compromised upstream becomes a compromised sandbox. The sandbox's disposability is your main mitigation.
- **WSL doesn't work inside Windows Sandbox.** WSL2 needs nested virtualization, and the `.wsb` schema doesn't expose a knob to enable it. If you need Linux tooling inside the sandbox, look at Cygwin / MSYS2, or run scripted tools via portable Python / Node installed through scoop / choco.

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). New `.ps1` scripts, `.wsb` tweaks, and doc improvements all welcome. CI runs PSScriptAnalyzer, parses every script, and validates the `.wsb` XML — please make sure it goes green.

## Credits

Heavily influenced by and reusing concepts from:

- [Sandbox](https://github.com/firefart/sandbox) by [@firefart](https://github.com/firefart)
- [Customize Windows Sandbox](https://techcommunity.microsoft.com/t5/itops-talk-blog/customize-windows-sandbox/ba-p/2301354) by Thomas Maurer
- countless people on forums

### 3rd-party tools

- [REtoolkit](https://github.com/mentebinaria/retoolkit) by [@mentebinaria](https://github.com/mentebinaria)
- [Get-ZimmermanTools](https://ericzimmerman.github.io/) by [@EricZimmerman](https://github.com/EricZimmerman)
- [SysinternalsSuite](https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite) by Microsoft
- Windows Sandbox logo by Microsoft

## License

[ISC](LICENSE)
