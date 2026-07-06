<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security audit template and tooling bundle

This bundle uses the intended layout with no version markers in filenames:

```text
security-audit-template-condensed-platforms-tools.md
security-audit-sast-addendum.md
install-security-audit-tools.ps1
install-security-audit-tools.sh
tool-paths.example.env
security-audit-tools-installer-README.md
llm-wiki/
  debug-tools-security-audit.md
```

Only `debug-tools-security-audit.md` is placed under `llm-wiki/`.

Optional local-only file:

```text
tool-paths.env
```

Do not commit secrets to `tool-paths.env`.

## Internal reference policy

The template should look for:

```text
llm-wiki/debug-tools-security-audit.md
llm-wiki/debug-tools.md
security-audit-sast-addendum.md
tool-paths.env
tool-paths.example.env
install-security-audit-tools.ps1
install-security-audit-tools.sh
```

`llm-wiki/debug-tools.md` is only a fallback or supplemental legacy file. The root-level files are not expected under `llm-wiki/`.

## Windows script

Use from the project root:

```powershell
.\install-security-audit-tools.ps1
```

Conservative default: downloads small Sysinternals CLI tools and `vswhere`, detects large tools without installing them.

## Linux/macOS script

Use from the project root:

```sh
chmod +x ./install-security-audit-tools.sh
./install-security-audit-tools.sh
```

Default mode is detection-only.

Optional small installs:

```sh
./install-security-audit-tools.sh --install-small --include-gitleaks --include-osv-scanner
```

Additional opt-ins:

```sh
./install-security-audit-tools.sh --install-small --include-semgrep --include-flawfinder --include-trufflehog
```

## Evidence files

The scripts write evidence such as:

```text
security-audit-tool-manifest.json
security-audit-tool-warnings.txt
security-audit-tool-availability.md
```

Audit reports should copy relevant warnings into the summary and reduce affected scorecard confidence.
## Path correctness after running the Windows installer

After running `install-security-audit-tools.ps1`, do not assume the example paths in `llm-wiki/debug-tools-security-audit.md` are the installed paths.

The default PowerShell installer root is:

```text
%LOCALAPPDATA%\SecurityAuditTools
```

The generated manifest is the source of truth:

```text
%LOCALAPPDATA%\SecurityAuditTools\security-audit-tool-manifest.json
```

Default portable Sysinternals tools are installed under:

```text
%LOCALAPPDATA%\SecurityAuditTools\bin\sysinternals
```

`vswhere.exe` is installed under:

```text
%LOCALAPPDATA%\SecurityAuditTools\bin\vswhere
```

Windows SDK Debugging Tools and MSVC tools are detected but not installed by default.
## Project-specific diagnostics

The DX12/DRED/debug-layer sections in `llm-wiki/debug-tools-security-audit.md` are conditional project-specific guidance. They are not generic security-audit requirements and should not affect scoring for unrelated projects.

Apply them only when the audited project has DX12/D3D12/GPU/capture/hook/overlay behavior or when the audit question specifically concerns those diagnostics.


## Windows SAST/secrets/dependency tool setup


Default Windows run:

```powershell
.\install-security-audit-tools.ps1
```

Default install attempts:

```text
gitleaks
osv-scanner
```

Detected but not installed by default:

```text
semgrep
flawfinder
pip-audit
```

Python/pip-based install opt-in:

```powershell
.\install-security-audit-tools.ps1 -IncludePythonSast
```

Still opt-in:

```text
CodeQL      # large
trufflehog  # deeper/heavier/noisier
WinDbg
LLVM
FFmpeg
GUI Sysinternals
```

Detector-only/minimal behavior:

```powershell
.\install-security-audit-tools.ps1 -Minimal
```

Targeted opt-outs:

```powershell
.\install-security-audit-tools.ps1 -SkipSastInstall
.\install-security-audit-tools.ps1 -SkipSecretsInstall
.\install-security-audit-tools.ps1 -SkipDependencyScannerInstall
```


The PowerShell script installs portable, low-side-effect scanners by default. Python/pip-based scanners are opt-in because they can mutate user Python environments and install scripts outside PATH. CodeQL and trufflehog remain opt-in.

Group installs:

```powershell
.\install-security-audit-tools.ps1 -IncludeSast
.\install-security-audit-tools.ps1 -IncludeSecrets
.\install-security-audit-tools.ps1 -IncludeDependencyScanners
```

Individual installs:

```powershell
.\install-security-audit-tools.ps1 -IncludeSemgrep
.\install-security-audit-tools.ps1 -IncludeFlawfinder
.\install-security-audit-tools.ps1 -IncludeGitleaks
.\install-security-audit-tools.ps1 -IncludeTruffleHog
.\install-security-audit-tools.ps1 -IncludeOSVScanner
.\install-security-audit-tools.ps1 -IncludePipAudit
.\install-security-audit-tools.ps1 -IncludeCodeQL
```

`CodeQL` is large and remains explicitly opt-in.

## Path lookup

After running an installer/detector, use the generated manifest first:

```text
%LOCALAPPDATA%\SecurityAuditTools\security-audit-tool-manifest.json
```

Do not assume installed portable tools are on `PATH` unless `-AddToUserPath` was used.

## Strict required-tool gate

Default behavior is advisory: write warnings, continue, and let the audit adjust score/confidence.

Strict mode is available when the audit scope requires specific tools:

```powershell
.\install-security-audit-tools.ps1 -RequireTools semgrep,gitleaks,osv-scanner -StrictRequiredTools
```

Exit codes:

```text
0 = no warnings
2 = completed with warnings
3 = strict required-tool gate failed
```

## PowerShell compatibility note

The PowerShell installer avoids `$Variable:` interpolation in double-quoted strings because PowerShell treats the colon as part of scoped variable syntax. Use `${Variable}:` or `-f` formatting when editing the script.

## PowerShell scoped-variable note

Valid scoped variables such as `$script:Warnings` and `$env:LOCALAPPDATA` must remain in scoped-variable form. Only ordinary variables followed by a literal colon inside double-quoted strings need `${Variable}:` or `-f` formatting.

## Python/pip-based scanner policy

`semgrep`, `flawfinder`, and `pip-audit` are useful, but they are not installed by default in the Windows script because `pip --user` can:

- modify the user's Python package set
- install scripts into `%APPDATA%\Python\Python*\Scripts`
- leave scripts outside `PATH`
- produce long dependency resolver/backtracking output
- behave differently across Python versions

Use `-IncludePythonSast` or individual `-IncludeSemgrep`, `-IncludeFlawfinder`, and `-IncludePipAudit` switches only when those side effects are acceptable.

## Full install mode

Use `-Full` to install as much supported tooling as practical:

```powershell
.\install-security-audit-tools.ps1 -Full
```

`-Full` enables:

```text
gitleaks
osv-scanner
semgrep / flawfinder / pip-audit through pipx or Python user install
trufflehog
CodeQL
GUI Sysinternals
WinDbg Preview through winget
LLVM through winget
FFmpeg
```

This mode can install large packages, use winget, and mutate the user Python environment. Use it only on a machine where those side effects are acceptable.

## Uninstall mode

Default uninstall removes the script-managed install root:

```powershell
.\install-security-audit-tools.ps1 -Uninstall
```

This removes portable tools and generated evidence under:

```text
%LOCALAPPDATA%\SecurityAuditTools
```

Shared package-manager installs and Python user packages are not removed by default because they may have existed before the script was run.

To attempt removing shared packages installed by supported script paths:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemoveSharedPackages
```

To attempt removing Python/pip-based packages installed by supported script paths:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemovePythonPackages
```

To remove all supported categories:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemoveSharedPackages -RemovePythonPackages
```

Use `-WhatIfOnly` to preview uninstall actions:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemoveSharedPackages -RemovePythonPackages -WhatIfOnly
```

## Full-mode reliability fixes

The PowerShell installer handles these full-mode cases explicitly:

- `winget` returning a non-zero code for an already-installed package is verified with `winget list` before being treated as failure.
- LLVM tools are searched in known install directories such as `C:\Program Files\LLVM\bin` after winget installation, not only in the current shell `PATH`.
- Existing downloaded archives are still extracted/resolved so the manifest records executable paths rather than only archive paths.
- WinDbg Preview can be recorded as package-installed even when the `WinDbgX.exe` alias is not visible in the current shell.
