<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Codebase Code and Binary Quality Audit Template — Condensed

Perform a focused, evidence-backed audit of the codebase and generated binaries where applicable.

Default mode: audit only. Do not change source code, tests, build files, configs, generated files, documentation, project assets, binaries, or other project files unless implementation is explicitly requested.

Create exactly one audit report by default:

- `audit/code-audit-report.md`

If `audit/` does not exist, create it. If the report already exists, do not overwrite it unless explicitly instructed; instead create `audit/code-audit-report-YYYYMMDD-HHMM.md`. If the user provides a specific output path, use it.

Do not create separate notes, JSON, evidence, summary, or auxiliary files unless explicitly asked.

## Scope

Focus on code and binary quality risks that can affect correctness, reliability, maintainability, security, privacy, performance, compatibility, stability, data integrity, and project-specific safety.

In scope:

- Source code, tests, build files, runtime config, generated source, dependency manifests, lockfiles, and source-tree documentation.
- Generated binaries where available or buildable, including hardening, symbols, dynamic dependencies, embedded paths/secrets, ABI/architecture compatibility, and debug/release differences.
- Compiler/linker flags, debug/release/sanitizer modes, formatter/linter/static-analysis/LSP configuration, and source-build reproducibility.
- Dependency vulnerabilities, risky dependency behavior, unused or bloated dependencies, and source-level license/attribution issues.
- Runtime behavior, feature correctness, error handling, malformed input, resource exhaustion, crash risks, concurrency, parser safety, native/FFI safety, filesystem safety, dynamic loading, update mechanisms, and privileged/service boundaries.
- Source-level handling of sensitive data in logs, telemetry, crash reports, caches, generated artifacts, local files, environment variables, CLI args, URLs, and persisted state.
- GUI/UI flows where applicable, especially user-triggered state changes, destructive actions, validation, frontend/backend synchronization, rollback, and high-blast-radius actions.
- Domain-specific safety where applicable, including hardware, financial, account, infrastructure, privileged automation, destructive operations, or other high-blast-radius behavior.

Out of scope unless explicitly requested:

- CI/CD runners and pipeline setup.
- Signing, notarization, app-store/release packaging, installers, deployment, distribution, infrastructure, hosting, cloud account setup, SBOMs, provenance, attestation, release notes, incident response, on-call process, support process, and legal/commercial compliance beyond source-level licensing and data-handling issues.

Do not score out-of-scope areas.

## Audit priorities

Use code inspection, builds, tests, analyzers, sanitizer/fuzzer output, runtime behavior, dependency data, and binary inspection as available. If evidence is missing, state that clearly and lower confidence.

Prioritize:

1. Broken source builds, broken binaries, broken central workflows, and high-confidence crashes.
2. Security vulnerabilities, privacy leaks, unsafe secrets handling, auth/access-control issues, injection, unsafe parsing/deserialization, path traversal, unsafe temp files, unsafe dynamic loading, and unsafe update/download behavior.
3. Memory, lifetime, native/FFI, resource, undefined-behavior, and concurrency risks.
4. Data loss, corrupted persistence, unsafe rollback/recovery, unsafe destructive operations, and unsafe high-blast-radius GUI/UI or domain-specific actions.
5. Malformed-input handling, denial-of-service/resource exhaustion, unbounded queues/caches/logs/tasks, retry storms, deadlocks, races, shutdown/cancellation failures, and service lifecycle issues.
6. Tests, regression hardening, static analysis, sanitizer/fuzzer coverage, binary inspection, and local developer validation gaps that allow serious issues to recur.
7. Maintainability issues only when they materially increase risk, fragility, duplication, long-term cost, or implementation difficulty.

Avoid low-value checklist output. Do not list every minor style concern. Group related minor issues. Recommend larger refactors only when they clearly reduce risk.

## Recommendation limit

The final report must contain **no more than 15 total fix/improvement recommendations**.

Count every finding with a recommended fix as one recommendation. To stay within the limit:

- Include all Critical and release-blocking High findings first.
- Then include the highest-risk Medium findings.
- Group related Low/Informational items under one recommendation only if they share the same root cause and fix.
- Omit cosmetic, speculative, or low-impact recommendations unless no higher-value issue exists.
- If more than 15 material issues exist, add a short “Deferred lower-priority issues” note listing omitted themes without detailed recommendations.

## Output requirements

The report must contain exactly these sections:

1. Executive Summary and Overall Rating
2. Scorecard
3. Findings and Recommendations
4. Code and Binary Quality Production-Readiness Assessment
5. Implementation Plan
6. Implementation Rules
7. Final Verification Checklist

### 1. Executive Summary and Overall Rating

Include:

- Verdict: Ready to ship / Ready to ship with minor fixes / Not ready to ship / Blocked
- Total weighted score
- Confidence: High / Medium / Low
- Top 5 risks
- Release blockers
- Main code-quality, binary-quality, crash/stability, memory/resource, security/privacy, feature/UI, and domain-specific blockers as applicable
- Highest-blast-radius risks
- Technical debt assessment
- Regression-hardening assessment
- Whether larger refactors are justified
- Main recommended next phase
- What was not assessed and how that affects confidence
- Note that out-of-scope CI/deployment/signing/packaging/infrastructure/distribution/operational-process criteria were not scored

### 2. Scorecard

Score each applicable category from 0 to 10.

Calibration: 10 excellent; 9 very good; 8 good; 7 acceptable; 6 marginal; 5 risky; 4 poor; 3 very poor; 2 critical weakness; 1 nearly broken/unsafe; 0 broken/unsafe/unassessable; N/A not applicable.

Rules:

- Use integers or one decimal place only.
- Use N/A only when genuinely not applicable.
- If applicable but not fully assessed, assign a score and lower confidence.
- Do not give high scores to memory/resource/security/build-hardening/binary-quality categories without concrete evidence.
- If generated binaries are in scope but were not built or inspected, lower confidence in source-build and binary-quality scoring.
- If GUI/UI or domain-specific high-blast-radius behavior is central but not assessed, lower confidence and score affected categories accordingly.

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

If accessibility/i18n or domain safety is central, assign positive weight and reduce less relevant weights so total remains 100%.

Weighted total = sum(score × weight for non-N/A positive-weight categories) / sum(applicable positive weights). Show brief arithmetic.

Verdict rules:

- Ready to ship: no Critical or High blockers; source build/test/binary path sufficiently verified; remaining risks minor and acceptable.
- Ready to ship with minor fixes: no Critical blockers; any High issues are narrow, understood, and not release-blocking.
- Not ready to ship: unresolved High blocker, multiple meaningful Medium issues, or insufficient confidence in testing/build/binary/security/reliability/memory/central workflow/domain safety.
- Blocked: Critical blocker, broken build or binary, severe data loss/security/privacy/safety risk, major memory corruption, high-confidence reachable crash, broken central feature workflow, unsafe high-blast-radius behavior, or missing essential source prerequisite.

### 3. Findings and Recommendations

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
Recommended fix:
Implementation guidance:
Suggested tests:
Release blocker: Yes / No
Estimated effort: Small / Medium / Large
Evidence:
Notes:
```

Evidence must be concrete where available: file paths, functions, commands, source-build output, binary-inspection output, test output, observed runtime behavior, analyzer/sanitizer/fuzzer output, dependency advisory output, GUI/UI behavior, feature behavior, or explicit absence of coverage. If unavailable, write `Evidence unavailable` and lower confidence.

Severity guidance:

- Critical: data loss, security compromise, privacy leak, unsafe system/device/domain state, major crash, broken source build/binary, broken central workflow, severe instability, exploitable memory-safety issue, or unsafe high-blast-radius behavior.
- High: serious correctness, reliability, security, privacy, performance, memory/resource, source-build, binary-quality, feature/UI, or domain-safety issue.
- Medium: real issue that should be fixed but is not immediately blocking.
- Low: localized cleanup, minor debt, style issue, or small optimization.
- Informational: observation or tradeoff with no required fix.

### 4. Code and Binary Quality Production-Readiness Assessment

Answer directly:

- Is the project production-ready from a code and binary quality perspective?
- Is it ready to ship?
- What must be fixed before shipping?
- What binary, crash/stability, memory/resource/lifetime/UB, security/privacy, feature/UI, and domain-specific risks must be fixed before shipping?
- What should be fixed soon after shipping?
- What can be deferred?
- What risks remain after fixes?
- Which components are central, fragile, high-risk, under-tested, performance-sensitive, parser-sensitive, native/FFI-sensitive, security/privacy-sensitive, binary-sensitive, GUI/UI-sensitive, platform-sensitive, or domain-sensitive?
- Which areas appear acceptable and should not be changed unnecessarily?

Do not assess out-of-scope release, deployment, packaging, signing, infrastructure, distribution, or operational-process readiness unless asked.

### 5. Implementation Plan

Provide a practical phased plan for a later coding agent. Keep it tied to the selected findings only.

For each phase include: related finding IDs, tasks, benefit, risk, affected files/modules/binaries, dependencies, validation, release requirement, and implementation order.

Use these phases only as applicable:

0. Safety and Baseline — capture build/test/analyzer/binary-inspection/runtime baselines; identify critical paths and high-risk code; avoid behavior-changing refactors until validation exists.
1. Release Blockers — fix Critical and release-blocking High findings first.
2. Correctness, Reliability, Compatibility — fix serious logic, lifecycle, recovery, malformed-input, feature/UI, platform, and compatibility issues.
3. Regression Hardening — add targeted tests, sanitizer/static-analysis/fuzzer coverage, malformed-input tests, security/privacy tests, binary-inspection checks, and central workflow tests.
4. Performance, Resource, Storage, and Binary Size — fix unbounded growth, avoidable overhead, cost/energy problems, binary bloat, and DoS-sensitive paths.
5. Architecture and Maintainability — reduce duplication, fragile boundaries, unsafe abstractions, dead code, diagnostic leftovers, and avoidable complexity only where justified.
6. Source Build, Binary Quality, Dependencies, and Docs — fix local build/tooling/analyzer/hardening/dependency/license/source-doc gaps. Exclude CI/deployment/signing/packaging/infrastructure unless asked.
7. Final Validation — rerun relevant tests, builds, analyzers, sanitizer/fuzzer checks, binary inspection, dependency checks, and central runtime/GUI/domain-safety validations.

### 6. Implementation Rules

When implementing fixes later:

- Make the smallest safe change that fixes the root cause.
- Preserve behavior, APIs, file formats, config formats, ABI expectations, user-visible behavior, GUI behavior, and integration contracts unless current behavior is wrong or unsafe.
- Refactor only when it reduces risk, duplication, fragility, or long-term maintenance cost.
- Do not add features unless required for correctness, safety, reliability, security, privacy, production-readiness, maintainability, accessibility/i18n where applicable, cost control, domain safety, binary quality, or regression prevention.
- Preserve useful optional debug logging; remove or isolate only diagnostics that are harmful, unsafe, stale, noisy, or production-invasive.
- Fix warning/analyzer/sanitizer/compiler/linker root causes instead of suppressing them. Suppress only narrowly, with justification.
- Prefer safe APIs, explicit bounds checks, checked arithmetic, bounded queues, bounded concurrency, backpressure, rollback, and explicit ownership/lifetime models.
- Treat parser, native/FFI, unsafe, concurrency, service/daemon, dynamic-loading, privileged, GUI high-blast-radius, and domain-sensitive code as high-risk until validated.
- Do not hide crashes without fixing corrupted state, unsafe behavior, or the root cause.
- Preserve or improve generated-binary hardening and crash diagnosability.
- Every fix must have validation, preferably an automated regression test.

### 7. Final Verification Checklist

Verify, where applicable:

- Clean checkout builds successfully.
- Tests pass and central workflows are validated.
- No known crash reproducer still crashes unless explicitly accepted with rationale.
- LSP/compiler/linker/static-analysis/formatter/linter/sanitizer findings are resolved or justified.
- Memory/resource checks cover relevant overflow, underflow, use-after-free, double/invalid free, out-of-bounds, uninitialized memory, null/dangling reference, integer-size, alignment, lifetime, and ABI/FFI risks.
- Malformed, oversized, truncated, corrupted, deeply nested, missing-file, invalid-config, permission, disk-full, network, dependency, subprocess, cancellation, shutdown, restart, and resource-exhaustion paths are tested or explicitly validated where relevant.
- Generated binaries are inspected for hardening, symbols, dynamic dependencies, embedded paths/secrets, unsafe loader paths, executable stack, writable-executable sections, ABI/architecture compatibility, CPU assumptions, bloat, and debug/release differences where applicable.
- Logs, telemetry, crash reports, metrics, traces, errors, URLs, CLI args, env vars, and generated artifacts do not leak sensitive data.
- Filesystem and persistence behavior is safe against path traversal, symlink/hardlink races, unsafe temp files, unsafe archive extraction, unsafe overwrite/delete, partial writes, corrupted state, unsafe permissions, and disk exhaustion where applicable.
- Concurrency and lifecycle behavior has no known races, deadlocks, livelocks, unsafe reentrancy, callback-after-destroy, async lifetime bugs, retry storms, or unsafe shutdown behavior.
- Parser, decoder, deserializer, importer, archive, protocol, plugin, and file-format handling is tested against malicious or malformed inputs where applicable.
- Security/privacy fixes are validated, including auth/access control, sensitive-data redaction, secrets handling, injection, path traversal, unsafe deserialization, unsafe dynamic loading, and unsafe update/download behavior where relevant.
- GUI/UI critical flows are validated for state synchronization, validation, disabled/enabled states, repeated clicks, cancellation, navigation, partial save, rollback, and high-blast-radius actions where applicable.
- Domain-specific safety is validated for safe defaults, rollback, recovery, persistence, restart behavior, rate limits, idempotency, and high-blast-radius actions where applicable.
- Dependencies and source-level licensing are acceptable.
- Public APIs, configs, persisted formats, feature flags, encoding/Unicode/locale behavior, platform expectations, and source-tree docs remain accurate and compatible unless a justified breaking change was made.
- Out-of-scope CI/CD/signing/deployment/packaging/installer/infrastructure/distribution/operational-process checks were not scored unless requested.
