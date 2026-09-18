<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security audit template and tooling bundle

The security bundle uses the files below plus the shared generic discovery helper from `../common-tools/`:

```text
security-audit-template.md
security-audit-sast-addendum.md
install-security-audit-tools.ps1
install-security-audit-tools.sh
tool-paths.example.env            # security-specific additions
security-audit-tools-installer-README.md
llm-wiki/
  debug-tools-security-audit.md

../common-tools/
  discover-debug-tools.ps1
  tool-paths.example.env          # generic debugger/developer overrides
```

In an integrated project, place the shared helper at `tools/discover-debug-tools.ps1` and merge the generic + security path-variable examples into the root `tool-paths.example.env`.

Only `debug-tools-security-audit.md` is placed under `llm-wiki/`.

Optional local-only/generated files include:

```text
tool-paths.env
debug-tool-manifest.json
debug-tool-warnings.txt
debug-tool-availability.md
security-audit-tool-manifest.json
security-audit-tool-warnings.txt
security-audit-tool-availability.md
```

Do not commit secrets to `tool-paths.env` or generated evidence.

## Internal reference policy

The template should look for:

```text
llm-wiki/debug-tools-security-audit.md
llm-wiki/debug-tools.md
security-audit-sast-addendum.md
tool-paths.env
tool-paths.example.env
tools/discover-debug-tools.ps1
install-security-audit-tools.ps1
install-security-audit-tools.sh
```

`llm-wiki/debug-tools.md` is only a fallback or supplemental project-specific file. The root-level files are not expected under `llm-wiki/`.

`llm-wiki/debug-tools-security-audit.md` in this repository is intentionally generic. When copying the bundle into a concrete project, add durable project-specific tool paths and diagnostic knowledge to that project's local copy rather than to this reusable template.

## Evidence and scoring policy

Tool availability is audit-coverage evidence, not a product vulnerability by itself.

- Missing applicable tools should produce visible warnings and lower audit confidence.
- Do not automatically lower the product/security score solely because a preferred scanner or debugger is unavailable.
- Lower substantive scores when missing evidence demonstrates an unmet requirement, prevents verification of a required release/security criterion, or the chosen scoring model explicitly measures verification coverage.
- Explicit strict required-tool gates may fail independently of confirmed product vulnerabilities.

## Windows script

Use from the project root:

```powershell
.\install-security-audit-tools.ps1
```

Conservative default: install/detect security-audit tools where supported, then invoke the shared non-mutating `tools/discover-debug-tools.ps1` helper for generic debugger/developer-tool paths.

## Linux/macOS script

Use from the project root:

```sh
chmod +x ./install-security-audit-tools.sh
./install-security-audit-tools.sh
```

Default mode is detection-only. Detection-only operation is normal and is not itself a warning; missing applicable tools may still produce warnings.

Optional small installs:

```sh
./install-security-audit-tools.sh --install-small --include-gitleaks --include-osv-scanner
```

Additional opt-ins:

```sh
./install-security-audit-tools.sh --install-small --include-semgrep --include-flawfinder --include-trufflehog
```

The shell script performs its evidence-producing detection pass after optional installation so the final manifest reflects the post-install state rather than retaining stale pre-install `missing` results.

For tool resolution, it checks the current `PATH` plus the script-managed `$INSTALL_ROOT/bin`, `PIPX_BIN_DIR` when set, common user-bin paths such as `~/.local/bin`, and the active Python 3 user-base `bin` directory when available. Portable or Python/pipx-installed tools therefore do not have to be added permanently to `PATH` merely to be detected by the current run.

## Evidence files

The Windows workflow writes separate generic and security evidence:

```text
debug-tool-manifest.json
debug-tool-warnings.txt
debug-tool-availability.md
security-audit-tool-manifest.json
security-audit-tool-warnings.txt
security-audit-tool-availability.md
```

The generic manifest owns debugger/developer-tool paths. The security manifest owns security-specific scanner/install evidence. The Linux/macOS security script continues to use its security-audit manifest for its own detection results.

Audit reports should carry forward material warnings and reflect them in coverage/confidence notes.

## Path correctness after running the Windows installer

Do not assume example paths in documentation are the installed paths. Prefer the generated manifest, then local path overrides, then shell discovery.

The default PowerShell installer root is:

```text
%LOCALAPPDATA%\SecurityAuditTools
```

When the Windows security installer runs, it places both manifests under its managed root:

```text
%LOCALAPPDATA%\SecurityAuditTools\debug-tool-manifest.json
%LOCALAPPDATA%\SecurityAuditTools\security-audit-tool-manifest.json
```

Use `debug-tool-manifest.json` for generic debugger/developer paths and `security-audit-tool-manifest.json` for security-specific tools.

Default portable Sysinternals tools are installed under:

```text
%LOCALAPPDATA%\SecurityAuditTools\bin\sysinternals
```

`vswhere.exe` is installed under:

```text
%LOCALAPPDATA%\SecurityAuditTools\bin\vswhere
```

Windows SDK Debugging Tools and MSVC tools are not installed by default. Their paths are discovered by the shared `discover-debug-tools.ps1` helper, which handles x86, x64, ARM, and ARM64 SDK debugger roots plus x86/x64/ARM64 MSVC host/target layouts.

The generic discovery regression check lives with the shared helper:

```powershell
.\common-tools\tests\test-debug-tool-discovery.ps1
```

The security installer also has a regression check that ensures generic path-generation logic is not duplicated back into the security script:

```powershell
.\security-audit-template\tests\test-generic-debug-discovery-integration.ps1
```

## Project-specific diagnostics

The reusable `llm-wiki/debug-tools-security-audit.md` deliberately avoids one project's incident history, product names, hardcoded symbol paths, or subsystem-specific debugging signatures.

After copying the bundle into a project, its local tool inventory may add project-specific diagnostics such as GPU validation, service tracing, media/capture analysis, device/hardware tooling, protocol traces, symbol layouts, or domain-specific runtime instrumentation.

Apply project-specific diagnostics only when their subsystem is in scope. Missing irrelevant project-specific tools must not reduce score or confidence.

## Windows SAST/secrets/dependency tool setup

Default Windows run:

```powershell
.\install-security-audit-tools.ps1
```

Default install attempts may include:

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

Still opt-in because of size, side effects, or specialization:

```text
CodeQL
trufflehog
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

Python/pip-based scanners remain opt-in because they can mutate user Python environments, install scripts outside PATH, and introduce resolver/version side effects. CodeQL and trufflehog remain opt-in because of size or depth/noise.

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

## Path lookup

After running an installer/detector, use the generated manifest first. Do not assume portable tools are on `PATH` unless the manifest/environment confirms that or `-AddToUserPath` was used.

Recommended resolution order:

1. generated `debug-tool-manifest.json` for generic debugger/developer tools
2. generated `security-audit-tool-manifest.json` for security-specific tools
3. local `tool-paths.env`
4. repository-local/pinned tool locations
5. script-managed/local user tool roots and `Get-Command`, `where.exe`, `command -v`, or equivalent discovery
6. documented project-specific known-good paths
7. safe fallbacks

## Strict required-tool gate

Default behavior is advisory: write warnings, continue the audit, and reduce coverage/confidence as appropriate.

Strict mode is available when the audit scope explicitly requires specific tools:

```powershell
.\install-security-audit-tools.ps1 -RequireTools semgrep,gitleaks,osv-scanner -StrictRequiredTools
```

Typical exit-code policy:

```text
0 = no warnings
2 = completed with warnings
3 = strict required-tool gate failed
```

Strict gates should name only tools that are genuinely required for the requested audit scope; optional or irrelevant tools must not block the audit.

## PowerShell compatibility notes

The PowerShell installer avoids `$Variable:` interpolation in double-quoted strings because PowerShell treats the colon as part of scoped-variable syntax. Use `${Variable}:` or `-f` formatting when editing ordinary variables followed by a literal colon.

Valid scoped variables such as `$script:Warnings` and `$env:LOCALAPPDATA` must remain in scoped-variable form.

## Python/pip-based scanner policy

`semgrep`, `flawfinder`, and `pip-audit` are useful, but they are not installed by default in the Windows script because Python user installs can:

- modify the user's Python package set
- install scripts into user script directories outside `PATH`
- produce resolver/backtracking output and dependency conflicts
- behave differently across Python versions

Use `-IncludePythonSast` or individual scanner switches only when those side effects are acceptable.

## Full install mode

Use `-Full` to install as much supported tooling as practical:

```powershell
.\install-security-audit-tools.ps1 -Full
```

Full mode may enable:

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

This mode can install large packages, use package managers, and mutate the user Python environment. Use it only on a machine where those side effects are acceptable.

## Uninstall mode

Default uninstall removes the script-managed install root:

```powershell
.\install-security-audit-tools.ps1 -Uninstall
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

## Full-mode reliability requirements

The PowerShell installer should handle these cases explicitly:

- a package manager returning a non-zero code for an already-installed package should be verified with package-manager inventory before being treated as failure;
- tools installed outside the current shell `PATH` should be searched in known installation directories and recorded by resolved executable path;
- existing downloaded archives should still be extracted/resolved so the manifest records executable paths rather than archive paths;
- package-installed tools such as WinDbg Preview may need to be recorded even when a shell alias is not visible in the current session.
