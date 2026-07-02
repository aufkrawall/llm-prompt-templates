<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security audit template and tooling bundle v5

This bundle contains the security audit template and companion local tooling documents/scripts.

## Files

- `security-audit-template-condensed-platforms-tools-v5.md`
- `debug-tools-security-audit-v2.md`
- `security-audit-sast-addendum.md`
- `install-security-audit-tools.ps1`
- `install-security-audit-tools.sh`
- `tool-paths.example.env`
- `security-audit-tools-installer-README-v5.md`

## Repository layout

Recommended placement:

```text
llm-wiki/
  debug-tools-security-audit.md
  debug-tools.md
  security-audit-sast-addendum.md
  install-security-audit-tools.ps1
  install-security-audit-tools.sh
  tool-paths.example.env
  tool-paths.env              # local only, do not commit secrets
```

## What changed in v5

- The audit template now explicitly looks for `llm-wiki/security-audit-sast-addendum.md`.
- The template expects Linux/macOS tool-availability evidence comparable to Windows evidence.
- The template prefers `llm-wiki/debug-tools-security-audit.md`, then falls back to `llm-wiki/debug-tools.md`.
- A POSIX `install-security-audit-tools.sh` detector/optional installer was added.
- SAST, secrets scanning, and dependency scanning are operationalized as baseline evidence.
- Hardcoded local paths are treated as examples unless required by the current audit target.
- `tool-paths.example.env` provides portable path variables for local overrides.
- Linux/macOS binary inspection now warns against using `ldd` on untrusted binaries.

## Windows script

Use:

```powershell
.\install-security-audit-tools.ps1
```

Conservative default: downloads small Sysinternals CLI tools and `vswhere`, detects large tools without installing them.

## Linux/macOS script

Use:

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

Both scripts write evidence such as:

```text
security-audit-tool-manifest.json
security-audit-tool-warnings.txt
security-audit-tool-availability.md
```

Audit reports should copy relevant warnings into the summary and reduce affected scorecard confidence.
