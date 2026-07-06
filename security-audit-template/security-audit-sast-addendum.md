<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security Audit Addendum — Static Analysis and Cross-Platform Tooling

This document supplements `debug-tools-security-audit.md` by defining local verification rules for source-level static analysis, secrets detection, dependency/supply-chain scanning, and Linux/macOS tool parity.

Use this file from `security-audit-sast-addendum.md`.


## Static Application Security Testing (SAST)

Static Application Security Testing means automated source-code analysis performed without running the program. SAST tools scan for security-relevant patterns, unsafe APIs, data-flow risks, injection paths, authorization mistakes, secrets exposure, and dependency exposure.

Examples include:

- `flawfinder` for C/C++ risky API usage
- `semgrep` for structural and custom pattern rules
- `CodeQL` for semantic and data-flow analysis
- language-native linters and analyzers where applicable

SAST results are evidence, not proof of security. Findings must be triaged for reachability, exploitability, false positives, and missing rule coverage.


## Windows installer default policy

On Windows, `install-security-audit-tools.ps1` installs portable, low-side-effect scanners by default where possible:

- `gitleaks`
- `osv-scanner`

The following remain opt-in:

- `CodeQL`, because it is large
- `trufflehog`, because it is deeper/heavier/noisier than `gitleaks`
- `semgrep`, `flawfinder`, and `pip-audit`, because they use pipx/Python user installs and can mutate the user Python environment
- language toolchain-native scanners such as `cargo-audit` and `govulncheck`, because they require existing Rust/Go toolchains
- platform/runtime tools such as WinDbg, LLVM, FFmpeg, and GUI Sysinternals

Use `-Minimal` or the `-Skip*Install` switches when a non-mutating detector-only setup is required.

## General rules

- Use this document as audit guidance, not proof that tools are installed.
- Verify each tool exists and runs before relying on it.
- Prefer local/offline or non-uploading modes.
- Do not upload proprietary source, crash dumps, logs, captures, or secrets to external services unless explicitly approved.
- Missing applicable tools must produce a warning, a coverage note, and a confidence/scoring impact in the audit report.
- A clean scan is not proof of security. Triage for reachability, exploitability, false positives, and rule coverage.
- If `.git/` is unavailable, say whether only the working tree was scanned.

## Static analysis and supply-chain tools

| Tool | Category / Purpose | Verification command | Typical audit command |
|---|---|---|---|
| `semgrep` | Lightweight semantic SAST | `semgrep --version` | `semgrep --config=auto .` |
| `flawfinder` | C/C++ risky API scan | `flawfinder --version` | `flawfinder .` |
| `gitleaks` | Source/history secrets scanning | `gitleaks version` | `gitleaks detect --source=. --verbose` |
| `trufflehog` | Deeper secrets scanning | `trufflehog --version` | `trufflehog filesystem .` |
| `osv-scanner` | Dependency vulnerability scanning | `osv-scanner --version` | `osv-scanner -r .` |
| `cargo-audit` | Rust dependency advisories | `cargo audit --version` | `cargo audit` |
| `npm` | Node dependency advisories | `npm --version` | `npm audit` |
| `pip-audit` | Python dependency advisories | `pip-audit --version` | `pip-audit` |
| `govulncheck` | Go vulnerability analysis | `govulncheck -version` | `govulncheck ./...` |

## Tool applicability

Use relevant tools based on project files:

| Project evidence | Suggested checks |
|---|---|
| `.git/` | `gitleaks`, optionally `trufflehog` |
| C/C++ source | `semgrep`, `flawfinder`, compiler warnings, clang-tidy, sanitizers |
| `Cargo.lock` | `cargo audit`, `osv-scanner` |
| `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock` | `npm audit` where applicable, `osv-scanner` |
| `requirements.txt`, `pyproject.toml`, `poetry.lock`, `Pipfile.lock` | `pip-audit`, `osv-scanner` |
| `go.mod` | `govulncheck`, `go list -m -json all`, `osv-scanner` |
| `pom.xml`, `build.gradle`, `gradle.lockfile` | ecosystem dependency tree tooling, `osv-scanner` |
| native binaries | platform binary hardening tools from `debug-tools-security-audit.md` |

## Linux x64 / ARM64 hardening and runtime primitives

Verify and use where available:

| Tool | Purpose |
|---|---|
| `file` | Architecture and ABI metadata |
| `readelf` | ELF headers, dynamic section, RELRO/NX/PIE evidence |
| `objdump` | Program headers, imports, disassembly |
| `checksec` | Hardening summary |
| `patchelf` | RPATH/RUNPATH inspection |
| `strings` | Embedded string/secrets review |
| `nm` | Symbol inspection |
| `strace` | File/network/process syscall tracing |
| `gdb` / `lldb` | Debugging and core analysis |

Preferred commands:

```sh
file ./binary
readelf -h ./binary
readelf -l ./binary
readelf -d ./binary
objdump -p ./binary
readelf -d ./binary | grep -E 'RPATH|RUNPATH|NEEDED|BIND_NOW'
checksec --file=./binary
```

Do not use `ldd` on untrusted binaries. Use `ldd` only on trusted local build artifacts.

## macOS x64 / ARM64 hardening and runtime primitives

Verify and use where available:

| Tool | Purpose |
|---|---|
| `file` | Architecture and Mach-O metadata |
| `codesign` | Signature, hardened runtime, entitlements |
| `otool` | Load commands, dynamic libraries, RPATH |
| `lipo` | Universal binary slice inspection |
| `strings` | Embedded string/secrets review |
| `nm` | Symbol inspection |
| `dwarfdump` | dSYM/debug info inspection |
| `lldb` | Debugging |
| `spctl` | Gatekeeper assessment where relevant |
| `log` | Unified log evidence |
| `fs_usage` / `dtruss` | Runtime tracing where permitted |

Preferred commands:

```sh
file ./binary
codesign -dvv ./binary
codesign -d --entitlements - ./binary
otool -L ./binary
otool -l ./binary | grep -A3 -E 'LC_RPATH|LC_LOAD_DYLIB'
lipo -info ./binary
```

For universal binaries, inspect each slice independently.

## Required warning language

Use warnings like:

```text
WARNING: semgrep was applicable but unavailable; source-level SAST confidence is reduced.
WARNING: gitleaks was unavailable and .git history was present; secrets-scanning confidence is reduced.
WARNING: osv-scanner was unavailable despite lockfiles/manifests; dependency vulnerability confidence is reduced.
WARNING: Linux ARM64 binary was not inspected with readelf/objdump/checksec; platform binary-hardening confidence is reduced.
WARNING: macOS universal binary was shipped but individual slices were not inspected independently.
```

## Report impact

Missing applicable SAST, secrets, dependency, or platform tools must affect:

- Executive Summary and Overall Security Rating
- Security Scorecard notes
- relevant findings, if coverage loss hides material risk
- Security Production-Readiness Assessment
- Final Verification Checklist

## Full install mode

`install-security-audit-tools.ps1 -Full` opts into all supported install paths, including Python/pip-based SAST tools and large tools such as CodeQL.

Use full mode only on dedicated audit machines or environments where package-manager and Python user-environment mutations are acceptable.

For cleanup, use:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemoveSharedPackages -RemovePythonPackages
```

Default uninstall removes only the script-managed portable install root.

Full mode should record resolved executable paths after download/extraction, not just archive paths. Existing archives should be reprocessed to ensure the manifest contains usable tool paths.
