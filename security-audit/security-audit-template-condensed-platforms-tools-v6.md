<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security Audit Template — Condensed

Perform a focused, evidence-backed security audit of the codebase, configuration, generated binaries, and runtime behavior where applicable.

Default mode: audit only. Do not change source code, tests, build files, configs, generated files, documentation, project assets, binaries, or other project files unless implementation is explicitly requested.

Create exactly one audit report by default:

- `audit/security-audit-report.md`

If `audit/` does not exist, create it. If the report already exists, do not overwrite it unless explicitly instructed; instead create:

- `audit/security-audit-report-YYYYMMDD-HHMM.md`

If the user provides a specific output path, use it.

Do not create separate notes, JSON, evidence, summary, or auxiliary files unless explicitly asked.

---

## Scope

Focus on security and privacy risks that can affect confidentiality, integrity, availability, authentication, authorization, data handling, supply-chain safety, runtime isolation, memory safety, binary hardening, abuse resistance, and high-assurance component correctness.

### In scope

- Source code, tests, build files, runtime config, dependency manifests, lockfiles, generated source, and source-tree documentation.
- Security fixes and proposed mitigations, including whether they preserve intended features, central workflows, APIs, compatibility, and performance characteristics.
- Local project audit knowledge under `llm-wiki/`, especially `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`, where present.
- Authentication, authorization, session management, access control, privilege boundaries, tenancy boundaries, admin/debug interfaces, and business-logic authorization paths.
- Input validation, injection risks, unsafe parsing, deserialization, path traversal, SSRF, XXE, command injection, SQL/NoSQL injection, template injection, header/log injection, unsafe redirects, and unsafe shell usage.
- Secrets handling in source, logs, configs, environment variables, CLI args, URLs, caches, telemetry, crash reports, local files, generated artifacts, and binaries.
- Cryptography, password handling, token handling, key management, random number generation, certificate/TLS handling, signature verification, and downgrade behavior.
- Filesystem safety, temp files, archive extraction, symlink/hardlink races, unsafe overwrite/delete behavior, path normalization, permissions, partial writes, rollback, and corrupted-state recovery.
- Network security, API exposure, CORS, CSRF, request smuggling-sensitive code, redirects, webhooks, callback URLs, outbound request restrictions, and protocol-level trust boundaries.
- Dependency vulnerabilities, risky dependency behavior, license/security notes, unused or bloated dependencies, pinning/lockfile consistency, and source-level supply-chain assumptions.
- Generated binaries where available or buildable, including hardening, symbols, dynamic dependencies, embedded paths/secrets, unsafe loader paths, executable stack, writable-executable sections, ABI/architecture compatibility, CPU assumptions, and debug/release differences.
- Compiler/linker hardening and diagnostics, including warning settings, sanitizer builds, hardening flags, static-analysis configuration, and source-build reproducibility.
- Runtime behavior under malformed input, resource exhaustion, retry storms, concurrency races, cancellation, shutdown, restart, crash/recovery, and abuse scenarios.
- GUI/UI or API flows involving destructive actions, account changes, permission changes, payment/financial actions, privileged automation, infrastructure changes, or other high-blast-radius operations.
- High-assurance components where applicable, including memory-safe design, minimized trusted unsafe/C++/FFI surface area, formalized invariants, explicit preconditions/postconditions, defensive validation, and targeted adversarial tests.
- Domain-specific safety where applicable, including hardware, financial, medical, account, infrastructure, privileged automation, destructive operations, or other high-blast-radius behavior.

### Required target platform and architecture coverage

Audit each supported release target separately. At minimum, assess the following targets when they are supported or intended:

| Platform | Architecture | Required assessment |
|---|---|---|
| Windows | x64 | Build, tests, runtime smoke tests, binary hardening, dependency loading, installer/runtime assumptions if in scope |
| Windows | ARM64 | Build, tests, runtime smoke tests, binary hardening, dependency loading, architecture-specific assumptions |
| Linux | x64 | Build, tests, runtime smoke tests, binary hardening, dynamic dependencies, loader paths, distro/libc assumptions |
| Linux | ARM64 | Build, tests, runtime smoke tests, binary hardening, dynamic dependencies, alignment/endian/atomic assumptions |
| macOS | x64 | Build, tests, runtime smoke tests, binary hardening, dynamic dependencies, Intel-specific assumptions |
| macOS | ARM64 | Build, tests, runtime smoke tests, binary hardening, dynamic dependencies, Apple Silicon assumptions |
| macOS | Universal, if shipped | Verify both slices independently and confirm packaging does not hide per-architecture failures |

If a target is claimed as supported but not built, tested, or inspected, score the affected categories lower and reduce confidence.

If a target is not supported, mark it clearly as `N/A — not a supported target`; do not silently omit it.

For Linux dependency inspection, prefer `readelf -d`, `objdump -p`, or `patchelf --print-rpath` for untrusted binaries. Use `ldd` only on trusted local build artifacts because dynamic-loader based inspection can be unsafe for untrusted binaries on some systems.

Assess platform-specific security differences, including:

- calling conventions, pointer size, integer width, alignment, atomics, SIMD/CPU feature assumptions, and ABI compatibility
- endian assumptions if relevant to protocols, files, serialization, crypto, or binary formats
- path normalization, case sensitivity, Unicode handling, reserved names, long paths, symlinks, hardlinks, file permissions, and executable bits
- shell quoting, subprocess behavior, environment inheritance, dynamic library search order, plugin loading, and update/download behavior
- platform-specific sandboxing, entitlement, privilege, service/daemon, registry/keychain/credential-store, and IPC behavior where applicable
- per-platform dependency resolution, bundled libraries, runtime redistributables, system library versions, and libc/libstdc++/MSVC runtime assumptions
- per-platform crash behavior, diagnostics, symbol leakage, debug/release differences, and hardened runtime behavior


### Required local audit knowledge discovery

Before starting the audit, inspect the repository for local audit knowledge under `llm-wiki/`.

Check these files in order:

1. `llm-wiki/debug-tools-security-audit.md` — preferred security-audit tool inventory and diagnostic guide
2. `llm-wiki/debug-tools.md` — fallback or supplemental project-specific debugging/tool inventory
3. `llm-wiki/security-audit-sast-addendum.md` — source-level SAST, secrets, dependency, and cross-platform tooling guidance
4. `llm-wiki/tool-paths.env` — local machine/project path overrides, if present
5. `llm-wiki/tool-paths.example.env` — documented path variables and expected layout
6. `llm-wiki/install-security-audit-tools.ps1` — optional Windows installer/detector
7. `llm-wiki/install-security-audit-tools.sh` — optional Linux/macOS installer/detector
8. other relevant `llm-wiki/*.md` files

Preference rules:

- Prefer `debug-tools-security-audit.md` over `debug-tools.md` for security audits.
- Use `security-audit-sast-addendum.md` to identify source-level static analysis, secrets scanning, dependency scanning, and non-Windows platform inspection tools.
- Use `tool-paths.env` or documented environment variables to resolve project-local binaries, PDBs, symbols, logs, dumps, captures, build roots, and install roots.
- Treat hardcoded paths in documentation as local examples unless explicitly declared mandatory for the current environment.
- If a documented path variable is unset, attempt documented relative discovery before warning.
- Warn only when a missing file, tool, path, platform, binary, dump, log, symbol directory, or diagnostic input materially reduces audit coverage.
- Missing or unavailable expected coverage must be reflected in the Executive Summary, Security Scorecard notes, Security Production-Readiness Assessment, and Final Verification Checklist.


### Local audit knowledge and tool-inventory documents

Before starting the audit, inspect the repository for local audit knowledge under:

- `llm-wiki/debug-tools-security-audit.md` — preferred when present
- `llm-wiki/debug-tools.md` — fallback or supplemental local debug-tool inventory
- `llm-wiki/*.md` — additional local audit guidance

Treat these files as project-local audit guidance and tool inventories, not as authoritative proof that a tool is installed or usable.

If `llm-wiki/install-security-audit-tools.ps1` exists, it may be used to install or detect local audit tools. Running it is optional and should follow its conservative defaults. The audit must still verify the resulting tool availability instead of assuming installation succeeded.


If `llm-wiki/debug-tools-security-audit.md` exists, use it as the preferred security-audit tool inventory. If it does not exist, fall back to `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`. If both exist, use `debug-tools-security-audit.md` as the primary source and `debug-tools.md` as supplemental project-specific debugging guidance. Use these files to identify available or expected debugging, binary-inspection, crash-analysis, media/capture-analysis, runtime-diagnostics, and platform-specific tools that may be useful for the audit. Prefer tools listed there when they fit the audit task.

For Windows crash and binary inspection, `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` may define project-specific tools and paths such as:

- `cdb.exe`, `windbg.exe`, `WinDbgX.exe`, and `dumpchk.exe` for `.dmp` analysis
- `symchk.exe`, `dbh.exe`, `pdbcopy.exe`, and `symstore.exe` for symbol/PDB validation
- `dumpbin.exe`, `link.exe /dump`, `lib.exe /list`, `undname.exe`, `llvm-objdump.exe`, and `llvm-strings.exe` for PE/COFF, object, symbol, import/export, section, disassembly, and strings inspection
- Sysinternals tools such as `procdump.exe`, `procmon.exe`, `procexp.exe`, `vmmap.exe`, `handle.exe`, `listdlls.exe`, `sigcheck.exe`, and `strings.exe`
- project-specific capture/media helpers such as `ffmpeg.exe` and `ffprobe.exe`
- project-specific diagnostics such as DX12 DRED, DX12 debug layer, and always-on `DX12 DIAG:` log interpretation where applicable

When crash dumps are analyzed on Windows, use the symbol-path guidance from `llm-wiki/debug-tools-security-audit.md` if present, otherwise from `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` if present. In particular, do not use a Microsoft-symbol-server-only path when the project-local PDB directory is required for complete stack traces.

Tool-inventory handling rules:

- Check whether `llm-wiki/debug-tools-security-audit.md` exists before selecting crash, dump, symbol, binary, or runtime-diagnostic tools; if absent, check `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`.
- Check whether each relevant listed tool is actually available at the documented path before relying on it.
- If a listed tool is missing, inaccessible, incompatible with the current platform, or fails to run, print a clear warning in the report.
- If a tool is unavailable but a reasonable fallback exists, use the fallback and document the reduced coverage.
- If no fallback exists, mark the affected evidence as unavailable, lower confidence, and reduce relevant scores.
- If the audit environment cannot access the listed platform, architecture, binaries, dumps, logs, PDBs, symbols, or diagnostic tools, state this in the Executive Summary and affected findings.
- Do not silently skip a potentially relevant local tool, dump, symbol directory, binary-inspection utility, or diagnostic log named in `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`.
- Do not mutate debug flags, global runtime settings, binaries, PDBs, registry settings, system settings, or project files unless implementation or intrusive diagnostics are explicitly requested.
- Use mutation-capable tools, such as PE/COFF editing tools or global debug-flag tools, only with explicit intent and document the risk.

Availability warnings must be visible in the final report. Include them in:

- Executive Summary and Overall Security Rating
- Security Scorecard notes for affected categories
- Findings evidence or notes, where relevant
- Security Production-Readiness Assessment
- Final Verification Checklist

Examples of warnings:

```text
WARNING: neither llm-wiki/debug-tools-security-audit.md nor llm-wiki/debug-tools.md was found; local project-specific audit tooling and symbol-path guidance were not available. Confidence in crash/binary inspection is reduced.
WARNING: cdb.exe was listed in llm-wiki/debug-tools.md but was not available at the documented path; Windows dump analysis was not performed with the preferred debugger.
WARNING: Local PDB directory from llm-wiki/debug-tools.md was unavailable; crash stack traces may be incomplete.
WARNING: Linux ARM64 target is claimed as supported but no build, runtime, or binary-inspection evidence was available. Platform coverage score and confidence were reduced.
```


### Out of scope unless explicitly requested

- CI/CD runner security and pipeline setup.
- Cloud account configuration, hosting infrastructure, deployment, distribution, signing, notarization, app-store/release packaging, installers, SBOMs, provenance, attestation, release notes, incident response, on-call process, support process, and legal/commercial compliance beyond source-level licensing and security-relevant data handling.

Do not score out-of-scope areas.

---

## Audit priorities

Use code inspection, builds, tests, analyzers, dependency scanners, sanitizer/fuzzer output, runtime behavior, binary inspection, and manual review as available. If evidence is missing, state that clearly and lower confidence.

Prioritize:

1. Critical security flaws, broken authentication, broken authorization, privilege escalation, exposed secrets, unsafe defaults, and reachable high-impact exploit paths.
2. Injection, unsafe deserialization, path traversal, SSRF, XXE, command execution, unsafe dynamic loading, unsafe update/download behavior, and malicious file handling.
3. Business-logic and authorization bugs that automated scanners and LLM reviewers are likely to miss.
4. Privacy leaks, sensitive data exposure, insecure logging, weak redaction, telemetry leaks, token leaks, and unnecessary sensitive-data retention.
5. Cryptographic misuse, weak randomness, insecure password/token handling, missing verification, broken TLS/certificate handling, and weak key lifecycle handling.
6. Dependency vulnerabilities, risky transitive dependencies, unpinned dependencies, compromised supply-chain assumptions, and source-level license/security issues.
7. Memory safety, native/FFI risks, resource exhaustion, denial-of-service, parser abuse, unbounded queues/caches/logs/tasks, retry storms, and unsafe concurrency.
8. Missing compiler hardening, missing binary hardening, permissive warning posture, missing sanitizer coverage, and uninspected security-sensitive binaries.
9. Missing or unavailable project-local audit knowledge, tool inventories, crash dumps, PDBs/symbols, binaries, logs, or platform-specific diagnostic tools that materially reduce audit coverage.
10. Security regression gaps, missing abuse-case tests, missing malformed-input tests, missing auth/access-control tests, and missing fuzz targets for parser/protocol/file/network/deserialization code.
11. Maintainability issues only when they materially increase security risk, make fixes unsafe, hide vulnerabilities, or weaken future review.
12. Proposed security fixes that silently disable features, reduce central workflow correctness, create unacceptable performance regressions, or replace a vulnerability with a denial-of-service, availability, compatibility, or usability failure.

Avoid low-value checklist output. Do not list every minor style concern. Group related minor issues. Recommend larger refactors only when they clearly reduce security risk.

---

## Required security review methods

Use the following methods where applicable. Treat missing or incomplete coverage as evidence that lowers confidence.


### Security-specific use of `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`

When `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` contains a `Security audit additions` section, apply it during the audit.

Use it to select and validate tools for:

- PE/COFF hardening inspection
- DLL search-order and sideloading review
- embedded secrets and sensitive string scans
- Authenticode, signer, hash, and trust validation
- bundled dependency and local library inspection
- crash-dump sensitivity and symbol/PDB completeness
- Windows process mitigation policy
- filesystem and registry tracing
- network behavior inspection
- Windows event-log correlation
- project-specific DX12/DRED/debug-layer diagnostics, where applicable

The audit report must warn when a relevant documented tool, target binary, crash dump, local PDB directory, symbol path, log, capture, or diagnostic input is unavailable.

The warning must include:

- what was unavailable
- why it mattered
- what fallback, if any, was used
- what evidence was lost
- which scorecard categories and confidence levels were affected

Do not treat tool availability as a pass/fail security result. Treat it as audit coverage evidence.

### Cross-platform audit-tool automation parity

The audit must not give Windows-only tooling stronger coverage than Linux or macOS without saying so.

When supported targets include Linux or macOS, use or provide equivalent tool-availability evidence for those platforms. Prefer the local detector scripts when present:

- Windows: `llm-wiki/install-security-audit-tools.ps1`
- Linux/macOS: `llm-wiki/install-security-audit-tools.sh`

Both scripts should produce comparable evidence where possible:

- tool manifest JSON
- warnings file
- Markdown availability report
- tool paths
- tool versions where available
- SHA256 hashes for downloaded or inspected portable tools where practical
- source URLs for downloaded tools
- skipped or unavailable tool warnings
- coverage impact notes

If only Windows tool evidence exists while Linux/macOS are supported targets, lower confidence for platform/architecture coverage, binary inspection, and tooling categories.


### Project-local tool discovery and availability validation

Before using generic tool assumptions, inspect `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` and other relevant `llm-wiki/*.md` files.

For each relevant listed tool or artifact, record:

- expected path or invocation
- purpose
- whether it exists
- whether it can run in the current environment
- whether the current platform/architecture matches the tool
- whether required inputs are available, such as dumps, binaries, PDBs, symbols, logs, captures, or repro files
- fallback used, if any
- coverage lost if unavailable

Unavailable tools, symbols, binaries, dumps, or logs are not automatically findings unless they materially reduce security assurance. They must still be disclosed in the summary, scorecard notes, and readiness assessment.

### Security-fix non-regression review

When reviewing or planning fixes, verify that proposed mitigations do not silently regress product behavior.

A valid security fix should:

- fix the root cause, not only hide the symptom
- preserve intended features, central workflows, APIs, file formats, ABI expectations, configuration formats, persisted data, user-visible behavior, and integration contracts unless the current behavior is itself unsafe
- preserve reasonable performance, resource use, latency, throughput, binary size, startup time, and energy behavior for affected workflows
- avoid replacing a confidentiality/integrity issue with an availability, data-loss, compatibility, or usability failure
- avoid disabling features, code paths, plugins, protocols, platform support, diagnostics, or acceleration paths as the default “fix” unless that is explicitly justified and accepted
- keep secure behavior fail-closed where appropriate, without turning normal valid input or common workflows into avoidable failures
- include regression tests for both the security issue and the preserved legitimate behavior

Feature disablement is acceptable only when one of the following is true:

- the feature is inherently unsafe and cannot be made safe within the release window
- the feature is unused, unsupported, deprecated, or already documented as unsafe/experimental
- the feature is placed behind an explicit opt-in, admin-controlled, or compatibility flag with clear documentation
- the user explicitly requests disabling the feature as the mitigation
- the release is blocked and temporary disablement is documented as an emergency mitigation with follow-up work

If a fix intentionally changes behavior or performance, the report must state:

- what changed
- why the change is necessary
- who or what workflows are affected
- whether the change is temporary or permanent
- what alternatives were considered
- how feature, compatibility, and performance regressions were tested
- whether affected users need migration guidance or configuration changes

### Compiler and linker hardening

Assess whether the project enables strict diagnostics and hardening settings appropriate to the language, platform, and risk profile.

For C/C++/native code, assess where feasible:

- `-Wall`
- `-Wextra`
- `-Wconversion`
- `-Wshadow`
- `-Werror` where feasible and not counterproductive
- stack protector settings
- `_FORTIFY_SOURCE` or equivalent checked-libc hardening where applicable
- PIE/ASLR compatibility
- RELRO/NOW where applicable
- NX / non-executable stack
- CFI or equivalent control-flow protection where practical
- hardened allocator or runtime options where applicable
- debug/release differences that affect security
- removal or isolation of production-invasive diagnostics
- narrow, justified warning suppressions only when unavoidable

Do not require every flag blindly. Evaluate whether omissions are justified for the compiler, platform, build mode, dependency constraints, ABI constraints, and release target.

Platform-specific hardening checks should include, where applicable:

- **Windows x64/ARM64:** MSVC or clang-cl warning level such as `/W4`; `/WX` where feasible; `/sdl`; `/GS`; DEP/NX; ASLR with `/DYNAMICBASE`; high-entropy VA; Control Flow Guard such as `/guard:cf`; exception-continuation protection where available; safe DLL search behavior; manifest/UAC expectations; runtime library consistency; PDB/debug-symbol handling.
- **Linux x64/ARM64:** PIE; full RELRO; immediate binding where appropriate; stack canaries; NX stack; `_FORTIFY_SOURCE`; CET/BTI/PAC or equivalent platform support where applicable; safe `RPATH`/`RUNPATH`; no unsafe writable/executable sections; expected glibc/musl/libstdc++ compatibility; stripped symbols where appropriate.
- **macOS x64/ARM64:** hardened runtime expectations where applicable; PIE; stack protector; safe `@rpath`/`@loader_path`/`@executable_path` usage; entitlement assumptions; sandbox expectations where applicable; universal-binary slice parity; deployment target compatibility; debug-symbol handling.


### Source-level SAST, secrets, and dependency baseline

Before relying on binary or runtime analysis alone, run or inspect source-level baseline checks where applicable.

Use language/ecosystem-appropriate tools. Examples:

| Tool | Category | Use when applicable |
|---|---|---|
| `semgrep` | SAST / structural vulnerability scanning | General source trees, especially web/API/auth/parser/security-sensitive code |
| `flawfinder` | C/C++ risky API scanning | C/C++ codebases |
| `gitleaks` | secrets scanning | Source tree and Git history where available |
| `trufflehog` | deeper secrets scanning | High-sensitivity repositories or when history scanning is needed |
| `osv-scanner` | dependency vulnerability scanning | Repositories with lockfiles/manifests |
| `cargo-audit` | Rust dependency advisories | Rust projects with `Cargo.lock` |
| `npm audit` | Node dependency advisories | Node projects with `package-lock.json` or similar |
| `pip-audit` | Python dependency advisories | Python projects with requirements or lockfiles |
| `govulncheck` | Go vulnerability analysis | Go modules |
| `go list -m -json all` | Go dependency inventory | Go modules |
| `mvn dependency:tree` / `gradle dependencies` | JVM dependency inventory | Java/Kotlin/Gradle/Maven projects |

Rules:

- Do not require every tool for every project.
- Select tools based on languages, dependency manifests, threat model, and available environment.
- Treat a clean scanner result as useful evidence, not proof of security.
- Triage findings for reachability, exploitability, false positives, and missing rule coverage.
- If applicable SAST, secrets, or dependency scanning is unavailable, warn and lower confidence.
- If scanning Git history is unavailable because `.git/` is absent, state that only the working tree was scanned.
- Do not upload source code or secrets to external services unless explicitly approved.


### Static analysis

Run or inspect available static-analysis results where applicable, such as:

- CodeQL
- clang-tidy
- Coverity
- Snyk
- Semgrep-style rules
- language-native security linters
- dependency vulnerability scanners
- secrets scanners

Static-analysis findings must be triaged for reachability, exploitability, false positives, and missing rule coverage. Do not treat a clean static-analysis result as proof of security.

### Dynamic analysis

Run or inspect dynamic-analysis results where applicable, including:

- ASan
- UBSan
- TSan
- MSan, where applicable
- Valgrind or platform equivalents, where useful
- runtime resource-exhaustion checks
- crash reproducers
- malformed-input tests
- concurrency/lifecycle stress tests

Dynamic-analysis findings in security-sensitive paths should be treated as high risk until root-caused.

### Fuzzing

Identify and assess fuzz targets for:

- parsers
- protocol handlers
- file formats
- archive/import/export paths
- networking and request parsing
- deserialization
- decoders/encoders
- boundary-heavy code
- native/FFI entry points
- any untrusted-input boundary

Fuzzing assessment should include corpus quality, dictionaries where useful, sanitizer pairing, crash deduplication, minimized reproducers, regression tests for discovered crashes, and coverage of security-sensitive branches.

### LLM-assisted review

Use LLM review only as an additional reviewer, not as authoritative evidence.

Where used, prompt the reviewer to identify:

- exploit paths
- trust-boundary assumptions
- missing checks
- authorization bypasses
- dangerous defaults
- unsafe parser or deserialization behavior
- secret/data exposure paths
- denial-of-service paths
- missing tests and abuse cases
- likely false confidence from tests or scanners

LLM review output must be verified against source code and runtime behavior before becoming a finding.

### Manual business-logic and authorization review

Perform manual review for business-logic, authorization, tenancy, workflow, and state-machine bugs. These are high-priority because automated scanners and LLMs both struggle to detect them reliably.

Review should include:

- role/permission matrix
- object ownership and tenant isolation
- confused-deputy paths
- direct object reference behavior
- state-transition rules
- replay/idempotency
- destructive-action confirmation and rollback
- admin/debug escape hatches
- payment/account/infrastructure/high-blast-radius workflows, where applicable

### Regression tests from audit findings

Every accepted security finding should produce validation, preferably an automated regression test.

Do not accept comments, documentation-only notes, or “reviewed manually” statements as sufficient closure for a concrete bug unless an automated test is genuinely impractical and a manual verification procedure is documented.

### High-assurance component review

For high-assurance or high-blast-radius components, assess whether the design minimizes trusted complexity.

Prefer:

- memory-safe implementation where practical
- smaller trusted C/C++/unsafe/FFI surface area
- narrow privileged code paths
- explicit invariants
- checked preconditions and postconditions
- fail-closed behavior
- bounded resources
- deterministic error handling
- minimized parser complexity
- formalized state machines for critical flows
- targeted property tests or model tests where useful
- clear separation between trusted and untrusted data

---

## Recommendation limit

The final report must contain **no more than 15 total fix/improvement recommendations**.

Count every finding with a recommended fix as one recommendation.

To stay within the limit:

- Include all Critical and release-blocking High findings first.
- Then include the highest-risk Medium findings.
- Group related Low/Informational items under one recommendation only if they share the same root cause and fix.
- Omit cosmetic, speculative, or low-impact recommendations unless no higher-value issue exists.
- If more than 15 material issues exist, add a short “Deferred lower-priority issues” note listing omitted themes without detailed recommendations.

---

## Output requirements

The report must contain exactly these sections:

1. Executive Summary and Overall Security Rating
2. Security Scorecard
3. Findings and Recommendations
4. Security Production-Readiness Assessment
5. Implementation Plan
6. Implementation Rules
7. Final Verification Checklist

---

# 1. Executive Summary and Overall Security Rating

Include:

- Verdict: Ready to ship / Ready to ship with minor fixes / Not ready to ship / Blocked
- Total weighted score
- Confidence: High / Medium / Low
- Top 5 security risks
- Release blockers
- Main authentication, authorization, data exposure, secrets, cryptography, dependency, binary, runtime, and domain-specific blockers as applicable
- Highest-blast-radius risks
- Technical debt that materially affects security
- Regression-hardening assessment
- Manual business-logic and authorization review status
- Static-analysis, dynamic-analysis, fuzzing, and LLM-assisted-review status
- Local `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` availability and relevant tool availability warnings
- High-assurance component posture, where applicable
- Whether recommended fixes preserve intended features, central workflows, compatibility, and performance
- Whether larger refactors are justified
- Main recommended next phase
- Which expected local tools, binaries, dumps, symbols, logs, targets, or diagnostic inputs were unavailable
- What was not assessed and how that affects confidence
- Note that out-of-scope CI/deployment/signing/packaging/infrastructure/distribution/operational-process criteria were not scored

---

# 2. Security Scorecard

Score each applicable category from 0 to 10.

Calibration:

- 10 excellent
- 9 very good
- 8 good
- 7 acceptable
- 6 marginal
- 5 risky
- 4 poor
- 3 very poor
- 2 critical weakness
- 1 nearly broken/unsafe
- 0 broken/unsafe/unassessable
- N/A not applicable

Rules:

- Use integers or one decimal place only.
- Use N/A only when genuinely not applicable.
- If applicable but not fully assessed, assign a score and lower confidence.
- Do not give high scores to security, privacy, dependency, build-hardening, or binary-quality categories without concrete evidence.
- If generated binaries are in scope but were not built or inspected, lower confidence in binary and build-hardening scoring.
- If high-blast-radius behavior is central but not assessed, lower confidence and score affected categories accordingly.
- If business-logic or authorization review is central but not performed, lower confidence and score affected categories accordingly.
- If parser/protocol/file/network/deserialization code is central but lacks fuzzing or malformed-input tests, lower confidence and score affected categories accordingly.
- If `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` exists but relevant listed tools, symbols, dumps, logs, binaries, or platform targets are unavailable, lower confidence and score affected categories accordingly.
- If `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` contains security-specific tool guidance but relevant checks are skipped, unavailable, or unsupported in the audit environment, lower confidence and affected scores accordingly.

| Category | Weight | Score | Confidence | Notes |
|---|---:|---:|---|---|
| Authentication and session management | 9% | | | |
| Authorization, access control, tenancy, and privilege boundaries | 13% | | | |
| Business logic, workflow integrity, and abuse resistance | 8% | | | |
| Input validation, injection resistance, and unsafe parsing | 10% | | | |
| Secrets, credentials, tokens, and sensitive configuration | 8% | | | |
| Privacy, data exposure, logging, telemetry, and retention | 8% | | | |
| Cryptography, TLS, signing, and randomness | 6% | | | |
| Filesystem, storage, persistence, and recovery safety | 6% | | | |
| Network, API, webhook, CORS, CSRF, and outbound request safety | 7% | | | |
| Dependency, supply-chain, and source-level licensing risk | 6% | | | |
| Runtime reliability, DoS resistance, concurrency, and resource safety | 6% | | | |
| Compiler/linker hardening, binary hardening, native/FFI safety, and platform/architecture coverage | 5% | | | |
| Static analysis, SAST/secrets/dependency coverage, sanitizer coverage, fuzzing, local audit-tool availability, and security tooling | 4% | | | |
| Security tests, regression hardening, and quality gates | 4% | | | |
| GUI/UI high-blast-radius safety, if applicable | N/A or adjusted | | | |
| Domain-specific safety/failsafes, if applicable | N/A or adjusted | | | |
| High-assurance component design, if applicable | N/A or adjusted | | | |

If GUI/UI, domain safety, or high-assurance component safety is central, assign positive weight and reduce less relevant weights so total remains 100%.

Weighted total:

`sum(score × weight for non-N/A positive-weight categories) / sum(applicable positive weights)`

Show brief arithmetic.

## Verdict rules

- **Ready to ship:** no Critical or High blockers; source build/test/binary path sufficiently verified; remaining security risks minor and acceptable.
- **Ready to ship with minor fixes:** no Critical blockers; any High issues are narrow, understood, and not release-blocking.
- **Not ready to ship:** unresolved High blocker, multiple meaningful Medium issues, or insufficient confidence in security, privacy, testing, build, binary, dependency, reliability, memory, central workflow, business-logic, authorization, or domain-safety posture.
- **Blocked:** Critical blocker, exposed secret, broken auth/access control, severe privacy leak, exploitable injection, unsafe deserialization, severe data loss/security/safety risk, major memory corruption, high-confidence reachable crash in a security-sensitive path, broken central security workflow, unsafe high-blast-radius behavior, or missing essential source prerequisite.

---

# 3. Findings and Recommendations

Include no more than 15 findings/recommendations total.

Use deterministic IDs:

- `F-[CATEGORY_NUMBER]-[SEQUENTIAL_NUMBER]`
- Example: `F-04-001`

Each finding must use exactly this format:

```text
ID:
Category:
Severity: Critical / High / Medium / Low / Informational
Confidence: High / Medium / Low
Location:
Problem:
Impact:
Blast radius:
Attack scenario:
Recommended fix:
Implementation guidance:
Suggested tests:
Release blocker: Yes / No
Estimated effort: Small / Medium / Large
Evidence:
Notes:
```

For each finding with a recommended fix, the `Implementation guidance`, `Suggested tests`, or `Notes` field must identify any expected feature, compatibility, or performance impact. If the fix disables behavior, removes support, blocks valid input, adds meaningful latency, increases resource use, or changes user-visible behavior, state that explicitly and justify it.

Evidence must be concrete where available:

- File paths
- Functions/classes/modules
- Commands
- Build output
- Test output
- Static-analysis output
- Sanitizer output
- Fuzzer output
- Dependency advisory output
- Secrets-scanning output
- Binary-inspection output
- Per-platform build/test/runtime/binary-inspection output
- Local `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` tool-inventory checks
- Tool availability or unavailability checks
- Symbol/PDB availability checks
- Crash dump, binary, log, or diagnostic input availability checks
- Runtime behavior
- GUI/UI behavior
- API behavior
- Security control behavior
- Manual authorization/business-logic review result
- LLM-assisted-review result, only after human/source verification
- Explicit absence of coverage

If unavailable, write `Evidence unavailable` and lower confidence.

## Severity guidance

- **Critical:** exposed secrets, authentication bypass, authorization bypass, tenant isolation break, privilege escalation, remote code execution, arbitrary file read/write/delete, severe privacy leak, exploitable memory corruption, unsafe update/download path, unsafe system/device/domain state, severe data loss, or unsafe high-blast-radius behavior.
- **High:** serious but bounded security, privacy, dependency, cryptography, injection, filesystem, parser, binary, runtime, business-logic, or access-control issue.
- **Medium:** real security issue that should be fixed but is not immediately blocking.
- **Low:** localized cleanup, minor hardening, minor policy gap, small unsafe pattern with limited exposure.
- **Informational:** observation or tradeoff with no required fix.

---

# 4. Security Production-Readiness Assessment

Answer directly:

- Is the project production-ready from a security perspective?
- Is it ready to ship?
- What must be fixed before shipping?
- What authentication, authorization, tenancy, business-logic, injection, secrets, privacy, cryptography, dependency, compiler-hardening, binary, runtime, feature/UI, high-assurance, and domain-specific risks must be fixed before shipping?
- What should be fixed soon after shipping?
- Do proposed fixes preserve intended features, central workflows, platform support, compatibility, and performance?
- Are any proposed fixes actually feature disablement, behavior removal, or performance tradeoffs that require explicit acceptance?
- What can be deferred?
- What risks remain after fixes?
- Which components are central, fragile, high-risk, under-tested, parser-sensitive, native/FFI-sensitive, network-sensitive, security/privacy-sensitive, binary-sensitive, GUI/UI-sensitive, platform-sensitive, domain-sensitive, or high-assurance-sensitive?
- Which areas appear acceptable and should not be changed unnecessarily?
- Which scanner, sanitizer, fuzzer, LLM-review, manual-review, platform, and architecture coverage gaps most affect confidence?
- Which local tool-inventory, debugging-tool, binary-inspection-tool, symbol/PDB, dump, log, and diagnostic-input gaps most affect confidence?

Do not assess out-of-scope release, deployment, packaging, signing, infrastructure, distribution, or operational-process readiness unless asked.

---

# 5. Implementation Plan

Provide a practical phased plan for a later coding agent. Keep it tied to the selected findings only.

For each phase include:

- Related finding IDs
- Tasks
- Benefit
- Risk
- Affected files/modules/binaries
- Dependencies
- Validation
- Feature, compatibility, and performance non-regression checks
- Release requirement
- Implementation order

Use these phases only as applicable:

## 0. Safety and Baseline

Capture build/test/analyzer/binary-inspection/runtime baselines; inspect `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` and relevant `llm-wiki/*.md` files; validate availability of relevant local tools, binaries, dumps, logs, symbols, and platform targets; identify critical security paths and high-risk code; avoid behavior-changing refactors until validation exists.

## 1. Release Blockers

Fix Critical and release-blocking High findings first.

## 2. Authentication, Authorization, Business Logic, and Data Protection

Fix auth/session issues, access-control flaws, tenancy breaks, privilege-boundary weaknesses, workflow/state-machine abuse paths, sensitive-data exposure, privacy leaks, and unsafe persistence.

## 3. Injection, Parser, Filesystem, and Network Hardening

Fix unsafe input handling, injection, deserialization, path traversal, SSRF, XXE, archive extraction, command execution, redirects, webhooks, CORS, CSRF, request parsing, and outbound request restrictions.

## 4. Cryptography, Secrets, and Dependency Risk

Fix cryptographic misuse, weak randomness, token/key handling, TLS/certificate handling, exposed secrets, vulnerable dependencies, risky transitive dependencies, and lockfile inconsistencies.

## 5. Compiler, Runtime, Binary, and Native/FFI Hardening

Fix missing warning coverage, unsafe suppressions, missing sanitizer coverage, missing hardening flags, unsafe native/FFI boundaries, platform/architecture portability risks, binary hardening gaps, unsafe loader paths, symbol/debug leakage, missing preferred inspection-tool coverage, missing symbol/PDB handling, and security-sensitive crash paths.

## 6. Runtime Abuse Resistance

Fix denial-of-service risks, unbounded resource use, unsafe concurrency, retry storms, cancellation/shutdown bugs, crash-prone security paths, and malformed-input failure modes.

## 7. Security Regression Hardening

Add targeted tests, abuse-case tests, malformed-input tests, auth/access-control tests, business-logic tests, privacy/logging tests, sanitizer/static-analysis/fuzzer coverage, dependency checks, binary-inspection checks, and central workflow tests.

## 8. High-Assurance Component Hardening

For high-assurance components, reduce trusted unsafe/native surface area, formalize invariants, add property/model tests where useful, and document assumptions that must remain true for security.

## 9. Architecture and Maintainability

Reduce duplication, fragile boundaries, unsafe abstractions, dead code, diagnostic leftovers, and avoidable complexity only where justified by security risk reduction.

## 10. Final Validation

Rerun relevant tests, builds, analyzers, sanitizer/fuzzer checks, binary inspection, dependency checks, manual authorization/business-logic review, LLM-assisted review where useful, and central runtime/GUI/domain-safety validations.

---

# 6. Implementation Rules

When implementing fixes later:

- Make the smallest safe change that fixes the root cause.
- Preserve behavior, APIs, file formats, config formats, ABI expectations, user-visible behavior, GUI behavior, and integration contracts unless current behavior is wrong or unsafe.
- Do not disable, remove, or degrade supported features as a security fix unless explicitly justified, documented, and accepted.
- Do not replace a security issue with an avoidable availability, performance, compatibility, data-loss, or usability regression.
- Preserve central workflow performance unless the security fix requires a measured and accepted tradeoff.
- Measure or test performance-sensitive fixes when they affect hot paths, startup, shutdown, rendering, networking, parsing, storage, concurrency, binary size, memory use, or battery/energy use.
- If temporary feature disablement is used as an emergency mitigation, document the rollback plan, owner, follow-up fix, and user-visible impact.
- Refactor only when it reduces security risk, duplication, fragility, or long-term maintenance cost.
- Do not add features unless required for security, privacy, correctness, reliability, production-readiness, maintainability, accessibility/i18n where applicable, cost control, domain safety, binary quality, or regression prevention.
- Preserve useful optional debug logging; remove or isolate only diagnostics that are harmful, unsafe, stale, noisy, production-invasive, or likely to leak sensitive data.
- Fix warning/analyzer/sanitizer/compiler/linker root causes instead of suppressing them. Suppress only narrowly, with justification.
- Prefer safe APIs, explicit bounds checks, checked arithmetic, bounded queues, bounded concurrency, backpressure, rollback, safe defaults, and explicit ownership/lifetime models.
- Prefer memory-safe designs for high-assurance and high-blast-radius components. Keep trusted C/C++/unsafe/FFI surface area small, explicit, and heavily tested.
- Treat parser, native/FFI, unsafe, concurrency, service/daemon, dynamic-loading, privileged, GUI high-blast-radius, authentication, authorization, tenancy, business-logic, and domain-sensitive code as high-risk until validated.
- Do not hide crashes without fixing corrupted state, unsafe behavior, or the root cause.
- Preserve or improve generated-binary hardening and crash diagnosability.
- Every fix must have validation, preferably an automated regression test.
- Check local `llm-wiki/` audit guidance before assuming generic debugging, binary-inspection, crash-analysis, or diagnostic commands.
- Prefer project-documented diagnostic tools and symbol paths when applicable, but verify that they exist and run before relying on them.
- Warn when a relevant project-documented tool, symbol path, dump, binary, log, or target platform is unavailable.
- Do not close a security finding with only a comment, note, or claim that the code was reviewed unless automated validation is genuinely impractical and a manual verification procedure is documented.

---

# 7. Final Verification Checklist

Verify, where applicable:

- Clean checkout builds successfully.
- `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md` and relevant `llm-wiki/*.md` files were checked before selecting debugging, crash-analysis, binary-inspection, and runtime-diagnostic tools.
- Relevant project-documented tools were checked for existence and usability.
- Missing, inaccessible, incompatible, or failed project-documented tools are warned about in the report.
- Required dumps, binaries, symbols/PDBs, logs, captures, reproducers, and diagnostic inputs are available or explicitly marked unavailable.
- Missing preferred tools or inputs are reflected in confidence and affected scores.
- `llm-wiki/security-audit-sast-addendum.md` was checked when present.
- SAST, secrets scanning, and dependency scanning were run or explicitly marked unavailable/not applicable with confidence impact.
- Linux/macOS tool availability was captured with comparable evidence to Windows when those targets are supported.
- Hardcoded local paths in documentation were treated as examples unless confirmed as required for the current audit environment.
- Documented path variables from `tool-paths.env` or `tool-paths.example.env` were used before warning about missing local artifacts.
- Security-specific guidance in `llm-wiki/debug-tools-security-audit.md` or `llm-wiki/debug-tools.md`, including PE hardening, DLL sideloading, signatures, strings/secrets, dependency inventory, dump sensitivity, runtime mitigations, filesystem/registry tracing, network inspection, and event-log checks, was applied where relevant.
- Any skipped or unavailable security-specific local-tool checks are listed with impact on evidence, score, and confidence.
- Each supported target is built, tested, and inspected separately: Windows x64, Windows ARM64, Linux x64, Linux ARM64, macOS x64, macOS ARM64, and macOS universal binaries where shipped.
- Unsupported targets are explicitly marked `N/A — not a supported target`.
- Platform-specific path handling, Unicode behavior, shell/subprocess behavior, dynamic library loading, permissions, IPC, credential storage, and runtime dependency assumptions are validated where relevant.
- Architecture-specific pointer size, integer width, alignment, atomics, SIMD/CPU feature, ABI, and binary-format assumptions are validated where relevant.
- Tests pass and central security workflows are validated.
- Security fixes preserve intended features, central workflows, APIs, configs, persisted formats, platform support, and integration contracts unless a breaking change is explicitly justified.
- Security fixes do not silently disable features, diagnostics, acceleration paths, plugins, protocols, or supported platforms as a substitute for fixing the root cause.
- Performance-sensitive fixes are checked for regressions in latency, throughput, startup, shutdown, rendering/frame timing, network behavior, memory use, CPU use, binary size, and energy/battery use where relevant.
- Any intentional behavior removal, feature disablement, compatibility break, or performance tradeoff is documented, justified, accepted, and covered by follow-up work where needed.
- Authentication and session flows are validated.
- Authorization, tenant isolation, object ownership, and privilege-boundary checks are validated.
- Business-logic and state-transition rules are manually reviewed and tested for abuse cases.
- Admin, debug, internal, and privileged interfaces are protected.
- No known exploit reproducer still succeeds unless explicitly accepted with rationale.
- No known crash reproducer still crashes in a security-sensitive path unless explicitly accepted with rationale.
- Compiler warning settings and hardening choices are documented and justified.
- Static-analysis findings are resolved, justified, or documented as false positives.
- Sanitizer findings are resolved or justified.
- Fuzzing exists for parser, protocol, file-format, networking, deserialization, decoder/encoder, archive, and boundary-heavy code where relevant.
- Fuzzer crashes have minimized reproducers and regression tests.
- LLM-assisted review, if used, has been treated as advisory and verified against code/runtime evidence.
- Input handling covers malformed, oversized, truncated, corrupted, deeply nested, missing-field, invalid-config, permission, disk-full, network, dependency, subprocess, cancellation, shutdown, restart, and resource-exhaustion paths where relevant.
- Injection-sensitive paths are validated against SQL/NoSQL injection, command injection, template injection, header injection, log injection, path traversal, SSRF, XXE, unsafe redirects, unsafe deserialization, and unsafe archive extraction where relevant.
- Secrets are not present in source, generated files, logs, telemetry, crash reports, metrics, traces, URLs, CLI args, env vars, local files, caches, or binaries unless explicitly required and protected.
- Logs, telemetry, crash reports, metrics, traces, errors, URLs, CLI args, env vars, and generated artifacts do not leak sensitive data.
- Cryptography and TLS behavior are validated, including certificate verification, signature verification, key handling, token handling, password handling, randomness, and downgrade behavior where relevant.
- Filesystem and persistence behavior is safe against path traversal, symlink/hardlink races, unsafe temp files, unsafe archive extraction, unsafe overwrite/delete, partial writes, corrupted state, unsafe permissions, and disk exhaustion where applicable.
- Network and API behavior is safe against unsafe CORS, CSRF, webhook spoofing, SSRF, unsafe redirect following, request smuggling-sensitive parsing, replay issues, and unauthenticated privileged access where applicable.
- Concurrency and lifecycle behavior has no known races, deadlocks, livelocks, unsafe reentrancy, callback-after-destroy, async lifetime bugs, retry storms, or unsafe shutdown behavior.
- Parser, decoder, deserializer, importer, archive, protocol, plugin, and file-format handling is tested against malicious or malformed inputs where applicable.
- Generated binaries are inspected for hardening, symbols, dynamic dependencies, embedded paths/secrets, unsafe loader paths, executable stack, writable-executable sections, ABI/architecture compatibility, CPU assumptions, bloat, and debug/release differences where applicable.
- High-assurance components have minimized trusted unsafe/native surface area, documented invariants, targeted adversarial tests, and fail-closed behavior where relevant.
- GUI/UI critical flows are validated for state synchronization, validation, disabled/enabled states, repeated clicks, cancellation, navigation, partial save, rollback, and high-blast-radius actions where applicable.
- Domain-specific safety is validated for safe defaults, rollback, recovery, persistence, restart behavior, rate limits, idempotency, and high-blast-radius actions where applicable.
- Dependencies and source-level licensing are acceptable.
- Public APIs, configs, persisted formats, feature flags, encoding/Unicode/locale behavior, platform expectations, and source-tree docs remain accurate and compatible unless a justified breaking change was made.
- Unavailable local tools, binaries, dumps, symbols, logs, platform targets, and diagnostic inputs are listed with their impact on coverage, confidence, and scoring.
- Out-of-scope CI/CD/signing/deployment/packaging/installer/infrastructure/distribution/operational-process checks were not scored unless requested.
