<!-- SPDX-License-Identifier: MIT; Copyright (c) 2026 aufkrawall -->

# Code/Binary Quality Audit Skill — Compact Hardened

Audit the codebase and generated binaries with concrete evidence. Default mode: **audit only**. Do not modify source, tests, build/config, generated files, docs, assets, binaries, or other project files unless implementation is explicitly requested.

Create exactly one report: `audit/code-audit-report.md`. Create `audit/` if missing. If the report exists, create `audit/code-audit-report-YYYYMMDD-HHMM.md` unless overwrite is explicitly requested. Use a user-provided path if supplied. Do not create auxiliary notes/JSON/evidence/summaries/files unless asked.

## Scope

Assess risks to correctness, reliability, maintainability, security, privacy, performance, compatibility, stability, data integrity, and project/domain safety.

In scope: source, tests, build files, runtime config, generated source, manifests/lockfiles, source-tree docs, available/buildable binaries, compiler/linker flags, debug/release/sanitizer modes, formatter/linter/static-analysis/LSP config, reproducibility, dependency vulnerabilities/risky behavior/bloat/license/attribution, runtime behavior, feature correctness, error handling, malformed input, resource exhaustion, crashes, concurrency, parsers, native/FFI/unsafe code, filesystem, dynamic loading, updates/downloads, privileged/service/daemon/helper boundaries, sensitive data in logs/telemetry/crash reports/caches/artifacts/local files/env/CLI args/URLs/persisted state, GUI/UI state changes/destructive actions/validation/frontend-backend synchronization/state synchronization/rollback/repeated clicks/high-blast-radius flows, and domain safety for hardware/finance/accounts/infrastructure/automation/destructive or privileged behavior.

For native/binary projects, prove hardening from artifacts and runtime behavior, not flags alone: PE/ELF/Mach-O metadata, load config, DllCharacteristics, Guard CF/GFIDS, CET/IBT/shadow-stack bits and landing pads, ASLR/PIE, DEP/NX, RELRO, canaries/stack protector, section permissions, symbols, deps, loader/search paths, embedded paths/secrets, ABI/arch/CPU assumptions, static-runtime assumptions, bloat, debug/release diffs, and disassembly when needed. Check accepted-but-ineffective or no-op flags, mitigation glue, CRT/runtime symbols, duplicate-symbol/linker behavior, LTO/ICF/static-link compatibility, plugins/drivers/COM/callbacks/dynamic function pointers, third-party/native DLL calls, thread stack sizes, handle/FD ownership, subprocess cleanup, invalid/double close, and hardened-release smoke tests.

For Windows/service/privileged projects, explicitly check process mitigations, strict handles, service/helper/IPC identity, DLL/driver/FFI boundaries, reparse/junction/symlink TOCTOU defenses, safe create/open flags, parent-component checks, post-write canonical-path verification, service lifecycle, crash breadcrumbs/dumps before exception suppression, rollback retries, restart/TDR/recovery, persistent external/hardware/driver state, external-tool interference, and cross-API validation.

Out of scope unless requested: CI/CD, signing, notarization, app-store/release packaging, installers, deployment, distribution, infrastructure, hosting/cloud accounts, SBOM/provenance/attestation, release notes, incident response, on-call/support, and legal/commercial compliance beyond source-level licensing/data handling. Do not score out-of-scope areas.

## Priorities

Use inspection, builds, tests, analyzers, sanitizer/fuzzer output, runtime behavior, dependency data, and binary inspection. If evidence is missing, say so and lower confidence. Prioritize: 1 broken builds/binaries/central workflows/high-confidence crashes; 2 security/privacy/secrets/auth/access/injection/parsing/deserialization/path traversal/temp files/dynamic loading/update/download risks; 3 memory/lifetime/native/FFI/resource/UB/concurrency; 4 data loss/corrupt persistence/unsafe rollback/recovery/destructive/high-blast-radius UI/domain actions; 5 feature correctness, error handling, state synchronization, frontend-backend synchronization, validation, malformed-input/DoS/unbounded queues,caches,logs,tasks/retry storms/deadlocks/races/shutdown/cancellation/service lifecycle; 6 regression gaps in tests/static analysis/sanitizers/fuzzers/binary inspection/local validation; 7 maintainability only where it materially increases risk, fragility, duplication, cost, or implementation difficulty. Avoid low-value checklists/cosmetic issues; group related minors; recommend refactors only when they reduce risk.

## Recommendation limit

Report no more than **15 findings/recommendations**. Count each finding with a fix as one. Include all Critical and release-blocking High first, then highest-risk Medium, then grouped Low/Info only when useful. If more material issues exist, add a brief “Deferred lower-priority issues” theme list.

## Required report sections

Use exactly these sections:
1. Executive Summary and Overall Rating
2. Scorecard
3. Findings and Recommendations
4. Code and Binary Quality Production-Readiness Assessment
5. Implementation Plan
6. Implementation Rules
7. Final Verification Checklist

### 1. Executive Summary and Overall Rating

Include: verdict, weighted score, confidence, top 5 risks, release blockers, main code-quality/binary-quality/crash-stability/memory-resource/security-privacy/feature-UI/domain blockers, highest-blast-radius risks, technical-debt and regression-hardening assessments, whether larger refactors are justified, recommended next phase, what was not assessed and confidence impact, and note that out-of-scope CI/deployment/signing/packaging/infrastructure/distribution/ops criteria were not scored.

Verdicts: Ready = no Critical/High blockers and build/test/binary path sufficiently verified. Ready with minor fixes = no Critical blockers; any High is narrow, understood, non-blocking. Not ready = unresolved High blocker, multiple meaningful Medium issues, or insufficient confidence in testing/build/binary/security/reliability/memory/central workflow/domain safety. Blocked = Critical blocker, broken build/binary, severe data loss/security/privacy/safety risk, major memory corruption, reachable crash, broken central workflow, unsafe high-blast-radius behavior, or missing essential source prerequisite.

### 2. Scorecard

Score applicable categories 0–10, integer or one decimal; N/A only if genuinely not applicable. If applicable but not fully assessed, score it and lower confidence. Do not give high memory/resource/security/build-hardening/binary-quality scores without concrete evidence. If binaries are in scope but not built/inspected, lower confidence. If GUI/domain high-blast-radius behavior is central but not assessed, lower affected scores/confidence. Scale: 10 excellent, 8 good, 7 acceptable, 6 marginal, 5 risky, 4 poor, 2 critical weakness, 0 broken/unsafe/unassessable.

| Category | Weight | Score | Confidence | Notes |
|---|---:|---:|---|---|
| Correctness and feature behavior | 13% | | | |
| Reliability, failure recovery, concurrency, and process stability | 14% | | | |
| Memory, resource, lifetime, native/FFI, and undefined-behavior safety | 13% | | | |
| Security, privacy leakage, and source-level threat model | 11% | | | |
| Performance, cost, energy, and resource efficiency | 8% | | | |
| Storage, filesystem, persistence, and recovery | 7% | | | |
| Architecture, maintainability, and code consistency | 12% | | | |
| Logging, diagnostics, and observability | 4% | | | |
| Tests, regression hardening, and quality gates | 9% | | | |
| Source build, tooling, static analysis, and binary inspection | 6% | | | |
| Dependencies, supply chain, licensing, API/config/docs compatibility | 3% | | | |
| Accessibility/i18n, if applicable | N/A or adjusted | | | |
| Domain-specific safety/failsafes, if applicable | N/A or adjusted | | | |

If accessibility/i18n or domain safety is central, give it positive weight and reduce less relevant weights so total remains 100%. Weighted total = sum(score × weight for non-N/A positive-weight categories) / sum(applicable positive weights). Show brief arithmetic.

### 3. Findings and Recommendations

Use IDs `F-[CATEGORY_NUMBER]-[SEQUENTIAL_NUMBER]`, e.g. `F-04-001`. Each finding must use exactly:

```text
ID:
Category:
Severity: Critical / High / Medium / Low / Informational
Confidence: High / Medium / Low
Location:
Problem:
Impact:
Blast radius:
Recommended fix:
Implementation guidance:
Suggested tests:
Release blocker: Yes / No
Estimated effort: Small / Medium / Large
Evidence:
Notes:
```

Evidence must be concrete where available: paths, functions, commands, build output, binary-inspection output, tests, runtime/analyzer/sanitizer/fuzzer output, dependency advisory, GUI/feature behavior, or explicit absence of coverage. If unavailable, write `Evidence unavailable` and lower confidence.

Severity: Critical = data loss, security compromise, privacy leak, unsafe system/device/domain state, major crash, broken build/binary/central workflow, severe instability, exploitable memory safety, or unsafe high-blast-radius behavior. High = serious correctness/reliability/security/privacy/performance/memory/resource/build/binary/UI/domain issue. Medium = real fix needed but not immediately blocking. Low = localized cleanup/minor debt/small optimization. Info = observation/tradeoff with no required fix.

### 4. Code and Binary Quality Production-Readiness Assessment

Answer directly: production-ready from code/binary perspective; ready to ship; must fix before shipping; binary/crash-stability/memory-resource-lifetime-UB/security-privacy/feature-correctness/error-handling/feature-UI/frontend-backend-synchronization/domain risks before shipping; fix soon after shipping; defer; residual risks; central/fragile/high-risk/under-tested/performance-sensitive/parser-sensitive/native-FFI-sensitive/security-privacy-sensitive/binary-sensitive/GUI-sensitive/platform-sensitive/domain-sensitive components; acceptable areas not to change unnecessarily. Do not assess out-of-scope release/deployment/packaging/signing/infrastructure/distribution/ops readiness unless asked.

### 5. Implementation Plan

Provide a practical phased plan for a later coding agent tied only to selected findings. For each applicable phase include finding IDs, tasks, benefit, risk, affected files/modules/binaries, dependencies, validation, release requirement, and order.

Phases: 0 Safety/Baseline — capture build/test/analyzer/binary/runtime baselines; identify critical paths/high-risk code; avoid behavior-changing refactors until validation exists. 1 Release Blockers — fix Critical and blocking High. 2 Correctness/Reliability/Compatibility — fix serious feature-correctness, error-handling, logic, lifecycle, recovery, malformed-input, feature/UI, frontend-backend synchronization, platform, and compatibility issues. 3 Regression Hardening — add targeted tests plus sanitizer/static/fuzzer/malformed-input/security/privacy/binary/central-workflow/state-synchronization checks. 4 Performance/Resource/Storage/Binary Size — fix unbounded growth, overhead, cost/energy, bloat, DoS-sensitive paths. 5 Architecture/Maintainability — reduce duplication/fragile boundaries/unsafe abstractions/dead code/diagnostic leftovers/complexity only when justified. 6 Source Build/Binary Quality/Dependencies/Docs — fix local build/tooling/analyzer/hardening/dependency/license/source-doc gaps; exclude CI/deployment/signing/packaging/infrastructure unless asked. 7 Final Validation — rerun relevant tests/builds/analyzers/sanitizers/fuzzers/binary/dependency/runtime/GUI/domain-safety checks.

### 6. Implementation Rules

For later fixes: make the smallest safe root-cause change; preserve behavior/APIs/file-config-persisted formats/ABI/UI/integration contracts unless wrong or unsafe; refactor only to reduce risk/duplication/fragility/cost; add features only when required for correctness, feature correctness, error handling, safety, reliability, security, privacy, readiness, maintainability, accessibility/i18n, cost control, domain safety, binary quality, or regression prevention; preserve useful optional debug logs and remove/isolate only harmful/unsafe/stale/noisy/production-invasive diagnostics; fix warning/analyzer/sanitizer/compiler/linker root causes, suppressing only narrowly with justification; prefer safe APIs, bounds checks, checked arithmetic, bounded queues/concurrency, backpressure, rollback, and explicit ownership/lifetime; treat parser/native/FFI/unsafe/concurrency/service/daemon/dynamic-loading/privileged/GUI high-blast-radius/frontend-backend synchronization/domain-sensitive code as high-risk until validated; do not hide crashes without fixing corrupted state/unsafe behavior/root cause; preserve/improve binary hardening and crash diagnosability; validate every fix, preferably with automated regression tests.

### 7. Final Verification Checklist

Verify where applicable: clean checkout builds; tests and central workflows pass; feature correctness and error handling are validated for central user-visible and high-blast-radius flows; crash reproducers resolved or accepted with rationale; LSP/compiler/linker/static-analysis/formatter/linter/sanitizer findings resolved or justified; memory/resource checks cover overflow/underflow/UAF/double-invalid free/OOB/uninitialized/null-dangling/integer-size/alignment/lifetime/ABI-FFI risks; malformed/oversized/truncated/corrupt/deeply nested/missing-file/invalid-config/permission/disk-full/network/dependency/subprocess/cancellation/shutdown/restart/resource-exhaustion paths tested; binaries inspected for hardening, symbols, deps, embedded paths/secrets, unsafe loaders, executable stack, writable-executable sections, ABI/arch/CPU assumptions, bloat, debug/release diffs, ineffective flags, and platform no-ops; logs/telemetry/crash reports/metrics/traces/errors/URLs/CLI args/env/generated artifacts do not leak sensitive data; filesystem/persistence safe against traversal, symlink/hardlink/reparse/junction races, unsafe temp/archive extraction/overwrite/delete/permissions, partial writes, corrupt state, and disk exhaustion; concurrency/lifecycle free of known races/deadlocks/livelocks/reentrancy/callback-after-destroy/async lifetime/retry storms/shutdown bugs; parser/decoder/deserializer/importer/archive/protocol/plugin/file-format handling tested against malicious/malformed inputs; security/privacy fixes validated for auth/access, redaction, secrets, injection, traversal, deserialization, dynamic loading, update/downloads; GUI critical flows validated for frontend-backend synchronization, state synchronization, validation, enabled/disabled states, repeated clicks, cancellation, navigation, partial save, rollback, and high-blast-radius actions; domain safety validated for safe defaults, rollback, recovery, persistence, restart, rate limits, idempotency, external-state reset, cross-API validation, and high-blast-radius actions; dependencies/licensing acceptable; public APIs/configs/persisted formats/feature flags/encoding/Unicode/locale/platform expectations/source docs remain accurate/compatible unless justified; out-of-scope CI/CD/signing/deployment/packaging/installer/infrastructure/distribution/ops checks not scored unless requested.
