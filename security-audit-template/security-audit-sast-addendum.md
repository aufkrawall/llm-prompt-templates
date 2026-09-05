<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security Audit Addendum — Static Analysis and Cross-Platform Tooling

This document supplements `llm-wiki/debug-tools-security-audit.md` with source-level static analysis, secrets detection, dependency/supply-chain scanning, and Linux/macOS tooling guidance.

Treat this file as audit guidance, not as proof that any tool is installed, appropriate, configured, or complete.

## Core evidence rule

Automated scan results are evidence, not proof of security. A clean scan does not prove absence of vulnerabilities, and an unavailable scanner does not prove the software is less secure.

- Triage findings for reachability, exploitability, mitigations, false positives, and rule coverage before reporting them as confirmed defects.
- Missing applicable tools reduce **coverage and confidence**. Do not automatically lower the product's security score solely because a preferred scanner is unavailable.
- Lower a substantive security/readiness score only when the missing evidence prevents verification of a security requirement, release criterion, supported target, or material risk area.
- If an audit has an explicit strict coverage gate, report failure of that gate separately from confirmed product vulnerabilities.

## Safety and execution rules

- Verify each tool exists and runs before relying on it.
- Prefer repository-pinned, local, offline, or non-uploading modes.
- Do not upload proprietary source, crash dumps, logs, captures, symbols, credentials, or secrets to external services unless explicitly approved.
- Do not install global packages or mutate user-level toolchains merely to increase scanner count unless authorized.
- Inspect repository-controlled hooks, plugins, build scripts, analyzers, and downloaded tools before executing them when they can run arbitrary code.
- If `.git/` is unavailable, state whether secrets/history checks covered only the working tree.
- Record unavailable high-value checks as coverage gaps with the affected assurance area and any fallback used.

## Static Application Security Testing (SAST)

SAST analyzes source without exercising the application runtime. Relevant tools may include:

| Tool | Typical purpose | Important limitation |
|---|---|---|
| `semgrep` | Structural/custom pattern and data-flow rules | Coverage depends heavily on selected rules/configuration |
| `CodeQL` | Semantic/data-flow analysis | Heavier setup; language/build extraction may be required |
| `flawfinder` | C/C++ risky API triage | Pattern-oriented; expect false positives and blind spots |
| compiler/language analyzers | Type, lifetime, nullability, warnings, unsafe patterns | Limited to implemented analyzer checks |

Use project-specific rules when available. Generic/autoconfigured scans are useful discovery passes but are not substitutes for manual threat-oriented review.

## Secrets and dependency scanning

| Tool | Category / purpose | Typical verification |
|---|---|---|
| `gitleaks` | Working-tree/history secrets detection | `gitleaks version` |
| `trufflehog` | Deeper secrets discovery | `trufflehog --version` |
| `osv-scanner` | Dependency vulnerability scanning | `osv-scanner --version` |
| `cargo-audit` | Rust dependency advisories | `cargo audit --version` |
| `npm` / ecosystem package manager | Node dependency advisories | check package-manager version first |
| `pip-audit` | Python dependency advisories | `pip-audit --version` |
| `govulncheck` | Go vulnerability analysis | `govulncheck -version` |

Network-backed advisory checks may contact external services. Use them only when network access is allowed for the audit environment. Prefer local caches/databases when the environment requires offline operation.

## Tool applicability

Select tools from project evidence rather than running every scanner unconditionally:

| Project evidence | Useful checks |
|---|---|
| `.git/` | secrets scan of current tree and, when relevant, history |
| C/C++ source | compiler warnings, clang-tidy/other analyzers, Semgrep/flawfinder where useful, sanitizers for suitable runtime paths |
| `Cargo.lock` | `cargo audit` and/or OSV-style dependency scanning |
| `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock` | ecosystem advisory tooling and/or OSV-style scanning |
| `requirements.txt`, `pyproject.toml`, `poetry.lock`, `Pipfile.lock` | Python advisory tooling and/or OSV-style scanning |
| `go.mod` | `govulncheck`, module inspection, OSV-style scanning |
| `pom.xml`, Gradle files/locks | ecosystem dependency-tree/advisory tooling |
| native binaries | platform binary hardening and dependency inspection |

Do not penalize a project for a scanner that is irrelevant to its languages, artifact types, threat model, or supported platforms.

## Windows installer policy

`install-security-audit-tools.ps1` may install or discover audit tools. Keep conservative defaults:

- portable, low-side-effect tools may be installed by default where the script documents that behavior;
- large tools, Python user-environment changes, or toolchain-specific additions should remain opt-in;
- detector-only or minimal modes should remain available for environments where mutation is undesirable.

After installation or discovery, verify resolved executable paths. A successful installer exit does not itself prove that every requested tool is usable.

## Linux x64 / ARM64 inspection

Useful tools include:

| Tool | Purpose |
|---|---|
| `file` | Architecture and ABI metadata |
| `readelf` | ELF headers, program headers, dynamic metadata, hardening evidence |
| `objdump` | Headers, dependencies, disassembly |
| `checksec` | Hardening summary |
| `patchelf --print-rpath` | RPATH/RUNPATH inspection |
| `strings` / `nm` | Embedded strings and symbols |
| `strace` | Runtime syscall tracing |
| `gdb` / `lldb` | Debugging and core analysis |

Representative static commands:

```sh
file ./binary
readelf -h ./binary
readelf -l ./binary
readelf -d ./binary
objdump -p ./binary
checksec --file=./binary
```

Do not use `ldd` on untrusted binaries. Prefer static metadata inspection such as `readelf -d` or `objdump -p`. Use `ldd` only on trusted local build artifacts.

## macOS x64 / ARM64 inspection

Useful tools include:

| Tool | Purpose |
|---|---|
| `file` | Architecture and Mach-O metadata |
| `codesign` | Signature, entitlements, hardened-runtime metadata |
| `otool` | Load commands, linked libraries, RPATH |
| `lipo` | Universal-binary slice inspection |
| `strings` / `nm` | Embedded strings and symbols |
| `dwarfdump` | dSYM/debug information |
| `lldb` | Debugging |
| `spctl` | Gatekeeper assessment where relevant |
| `log`, `fs_usage`, `dtruss` | Runtime diagnostics where permitted |

Representative commands:

```sh
file ./binary
codesign -dvv ./binary
codesign -d --entitlements - ./binary
otool -L ./binary
otool -l ./binary
lipo -info ./binary
```

For universal binaries, inspect each relevant slice independently when architecture-specific assurance matters.

## Reporting unavailable coverage

Use concise coverage notes such as:

```text
COVERAGE GAP: semgrep was applicable but unavailable; source-level SAST coverage is reduced. Manual review and compiler diagnostics were used as partial fallback.
COVERAGE GAP: gitleaks was unavailable while Git history was present; history-level secrets-scanning confidence is reduced.
COVERAGE GAP: the Linux ARM64 artifact was unavailable; binary-hardening claims for that supported target were not verified.
```

Reflect material coverage gaps in the executive summary, relevant scorecard notes, readiness assessment, and verification section. Keep **coverage/confidence** distinct from **confirmed product defects**.

## Full install mode

If the installer supports a full mode, reserve it for dedicated audit environments where larger downloads and user-level package-manager changes are acceptable. Cleanup behavior should be explicit and should not remove unrelated shared packages by default.
