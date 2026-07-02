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
