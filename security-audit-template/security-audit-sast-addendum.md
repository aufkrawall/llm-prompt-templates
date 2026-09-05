<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security Audit Addendum — Static Analysis and Cross-Platform Tooling

This document supplements `debug-tools-security-audit.md` by defining local verification rules for source-level static analysis, secrets detection, dependency/supply-chain scanning, and Linux/macOS tool parity.

Use this file from `security-audit-sast-addendum.md`.

## Evidence, coverage, and scoring semantics

Automated scan results are evidence, not proof of security. A clean scan does not prove absence of vulnerabilities, and an unavailable scanner does not by itself prove the product is less secure.

Keep these concepts distinct:

- **Product/security score:** evidence-backed state of the audited product and its controls.
- **Coverage/confidence:** how completely the audit could verify that state.
- **Readiness:** whether available evidence is sufficient for the intended release or assurance claim.

Missing applicable tools must be reported as coverage gaps and lower confidence. Lower a substantive product/security score only when the missing evidence demonstrates an unmet requirement, prevents verification of a required release/security criterion, or the scoring rubric explicitly measures verification coverage. Strict required-tool gates, when explicitly enabled, may fail independently of confirmed product vulnerabilities.

### Score calculation integrity

When the security audit requires weighted score arithmetic and a calculator, shell, scripting runtime, spreadsheet, or equivalent deterministic arithmetic tool is available, compute the score mechanically rather than estimating it mentally. Preserve the category scores, applicable positive weights, excluded/N/A categories, renormalization basis, unrounded result, and final rounding rule so another reviewer can reproduce the total.

Do not silently round intermediate values. If deterministic calculation tooling is unavailable, show the arithmetic explicitly and lower confidence in the numerical total if it cannot be independently checked. A mathematically precise total does not increase substantive security confidence when the underlying evidence is weak.


## Static Application Security Testing (SAST)

Static Application Security Testing means automated source-code analysis performed without running the program. SAST tools scan for security-relevant patterns, unsafe APIs, data-flow risks, injection paths, authorization mistakes, secrets exposure, and dependency exposure.

Examples include:

- `flawfinder` for C/C++ risky API usage
- `semgrep` for structural and custom pattern rules
- `bandit` for Python AST-based security checks
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

`bandit` is also useful for Python projects, but the current installer does not manage it. Use it when already available, or install it only with explicit authorization under the same Python-environment caution applied to other pip/pipx-based scanners.

Use `-Minimal` or the `-Skip*Install` switches when a non-mutating detector-only setup is required.

## General rules

- Use this document as audit guidance, not proof that tools are installed.
- Verify each tool exists and runs before relying on it.
- Prefer local/offline or non-uploading modes.
- Do not upload proprietary source, crash dumps, logs, captures, or secrets to external services unless explicitly approved.
- Missing applicable tools must produce a warning, a coverage note, and a confidence impact in the audit report; scoring impact follows the evidence/coverage rules above.
- A clean scan is not proof of security. Triage for reachability, exploitability, false positives, and rule coverage.
- If `.git/` is unavailable, say whether only the working tree was scanned.
- If `.git/` is present and history is relevant, determine whether the checkout is shallow before claiming history coverage. Prefer `git rev-parse --is-shallow-repository` where supported. A shallow clone must be reported as partial history coverage even if the available commits scan cleanly.
- When relevant, note partial/filter-clone state, missing remote objects, detached/synthetic CI checkouts, or other conditions that make repository history incomplete. Do not describe the scan as "full history" unless the available repository evidence supports that claim.

## Static analysis and supply-chain tools

| Tool | Category / Purpose | Verification command | Typical audit command |
|---|---|---|---|
| `semgrep` | Lightweight semantic SAST | `semgrep --version` | `semgrep --config=auto .` |
| `bandit` | Python AST-based SAST | `bandit --version` | `bandit -r .` |
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
| `.git/` | determine full/shallow/partial history coverage; `gitleaks`, optionally `trufflehog` |
| C/C++ source | `semgrep`, `flawfinder`, compiler warnings, clang-tidy, sanitizers |
| `Cargo.lock` | `cargo audit`, `osv-scanner` |
| `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock` | `npm audit` where applicable, `osv-scanner` |
| `requirements.txt`, `pyproject.toml`, `poetry.lock`, `Pipfile.lock`, Python source | `bandit` and/or `semgrep` for source SAST; `pip-audit` and `osv-scanner` for dependencies |
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
WARNING: repository checkout is shallow; secrets/history scanning covered only the available partial history and must not be reported as a full-history clean result.
WARNING: osv-scanner was unavailable despite lockfiles/manifests; dependency vulnerability confidence is reduced.
WARNING: Linux ARM64 binary was not inspected with readelf/objdump/checksec; platform binary-hardening confidence is reduced.
WARNING: macOS universal binary was shipped but individual slices were not inspected independently.
```

## Report impact

Missing applicable SAST, secrets, dependency, or platform tools and incomplete repository history must affect:

- Executive Summary and Overall Security Rating notes
- Security Scorecard notes and confidence
- relevant findings, if coverage loss hides material risk
- Security Production-Readiness Assessment
- Final Verification Checklist

Do not convert a missing tool or shallow checkout into a vulnerability finding by itself. Apply substantive score penalties only under the evidence/coverage rules above.

## Full install mode

`install-security-audit-tools.ps1 -Full` opts into all supported install paths, including Python/pip-based SAST tools and large tools such as CodeQL.

Use full mode only on dedicated audit machines or environments where package-manager and Python user-environment mutations are acceptable.

For cleanup, use:

```powershell
.\install-security-audit-tools.ps1 -Uninstall -RemoveSharedPackages -RemovePythonPackages
```

Default uninstall removes only the script-managed portable install root.

Full mode should record resolved executable paths after download/extraction, not just archive paths. Existing archives should be reprocessed to ensure the manifest contains usable tool paths.
