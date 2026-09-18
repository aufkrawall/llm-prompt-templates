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

Interactive default: starting the script without parameters opens a setup wizard. The default wizard profile is **Full install**. Press Enter to accept that profile, review the plan, then confirm; the script attempts every supported install path, including large packages, and finally invokes the shared non-mutating `tools/discover-debug-tools.ps1` helper for generic debugger/developer-tool paths.

The default full profile can download several GB, install/update shared developer packages, change the user Python environment, trigger UAC elevation, and require a reboot. Use the custom/minimal wizard profiles or explicit CLI switches when that is not desired.

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

A confirmed default/full Windows run attempts both the **Windows SDK Debugging Tools** feature (including `cdb.exe` and related SDK tools) and the current stable **Visual Studio Build Tools C++ workload** with recommended and optional components. After installation, the shared `discover-debug-tools.ps1` helper resolves x86, x64, ARM, and ARM64 SDK debugger roots plus x86/x64/ARM64 MSVC host/target layouts. Explicit CLI/custom/minimal runs can still omit either large toolchain.

The generic discovery regression check lives with the shared helper:

```powershell
.\common-tools\tests\test-debug-tool-discovery.ps1
```

The security installer also has regression checks for generic-discovery ownership and the wizard/full-install contract:

```powershell
.\security-audit-template\tests\test-generic-debug-discovery-integration.ps1
.\security-audit-template\tests\test-installer-wizard.ps1
```

## Project-specific diagnostics

The reusable `llm-wiki/debug-tools-security-audit.md` deliberately avoids one project's incident history, product names, hardcoded symbol paths, or subsystem-specific debugging signatures.

After copying the bundle into a project, its local tool inventory may add project-specific diagnostics such as GPU validation, service tracing, media/capture analysis, device/hardware tooling, protocol traces, symbol layouts, or domain-specific runtime instrumentation.

Apply project-specific diagnostics only when their subsystem is in scope. Missing irrelevant project-specific tools must not reduce score or confidence.

## Windows wizard and install profiles

Default interactive run:

```powershell
.\install-security-audit-tools.ps1
```

Wizard profiles:

1. **Full install** — default; all supported install paths, including large packages.
2. **Full install + edit paths/validation settings**.
3. **Custom install** — exposes every install/skip switch plus path and validation settings.
4. **Minimal/detection-focused**.
5. **Uninstall**.

The default Full profile enables or attempts:

```text
Visual Studio Build Tools C++ workload (recommended + optional VCTools components)
Windows SDK Debugging Tools / cdb.exe
WinDbg
LLVM
FFmpeg
CodeQL
GUI + CLI Sysinternals
gitleaks
trufflehog
osv-scanner
semgrep
flawfinder
pip-audit
vswhere
```

Toolchain-native scanners that the script does not manage, such as `cargo-audit` and `govulncheck`, are still detected when applicable. If they are missing, the completion summary reports them.

A custom or explicit CLI run can opt out:

```powershell
.\install-security-audit-tools.ps1 -Minimal
.\install-security-audit-tools.ps1 -Full -SkipSastInstall
.\install-security-audit-tools.ps1 -Full -SkipSecretsInstall
.\install-security-audit-tools.ps1 -Full -SkipDependencyScannerInstall
.\install-security-audit-tools.ps1 -IncludeWindowsSdkDebuggers
.\install-security-audit-tools.ps1 -IncludeVisualStudioBuildTools
```

Skip switches take precedence over the corresponding SAST/secrets/dependency include switches, including when `-Full` is used.

The Windows SDK debugger feature uses Microsoft's SDK installer and the `OptionId.WindowsDesktopDebuggers` feature. Visual Studio Build Tools uses Microsoft's current stable Build Tools bootstrapper with `Microsoft.VisualStudio.Workload.VCTools`, `--includeRecommended`, and `--includeOptional`.

At the end of every run, the script prints a consolidated installation/discovery summary. Items that were not installed, not found, unresolved, failed, or intentionally skipped are listed there, followed by recorded warnings and evidence paths.

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
2 = completed with unavailable/skipped tools or warnings
3 = strict required-tool gate failed
```

Strict gates should name only tools that are genuinely required for the requested audit scope; optional or irrelevant tools must not block the audit.

## PowerShell compatibility notes

The PowerShell installer avoids `$Variable:` interpolation in double-quoted strings because PowerShell treats the colon as part of scoped-variable syntax. Use `${Variable}:` or `-f` formatting when editing ordinary variables followed by a literal colon.

Valid scoped variables such as `$script:Warnings` and `$env:LOCALAPPDATA` must remain in scoped-variable form.

## Python/pip-based scanner policy

The default wizard/full profile attempts `semgrep`, `flawfinder`, and `pip-audit` through pipx or Python user installs. This can:

- modify the user's Python package set
- install scripts into user script directories outside `PATH`
- produce resolver/backtracking output and dependency conflicts
- behave differently across Python versions

The wizard shows this side effect before final confirmation. Use a custom/minimal profile or `-SkipSastInstall` / `-SkipDependencyScannerInstall` when these changes are not acceptable.

## Full install mode

The no-argument wizard defaults to Full mode. For non-interactive automation, request the same profile explicitly:

```powershell
.\install-security-audit-tools.ps1 -Full
```

Full mode enables every supported install category, including Windows SDK Debugging Tools and Visual Studio Build Tools/MSVC. Explicit skip switches remain authoritative for their corresponding categories.

This mode can install large packages, use package managers, modify shared developer tooling, mutate the user Python environment, trigger UAC, and require a reboot. The installer performs final discovery afterward and reports anything that is still unavailable.

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
