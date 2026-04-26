<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Codebase Code and Binary Quality Audit Template

Perform a thorough audit of the entire codebase and generated binaries where applicable. Spawn multiple sub-agents to read the codebase where useful to avoid context-window limits.

Default mode: audit only. Do not change source code, tests, build files, configs, generated files, documentation, project assets, binaries, or any other project files unless implementation is explicitly requested.

Create exactly one audit artifact by default:

- `audit/code-audit-report.md`

If `audit/` does not exist, create it. If `audit/code-audit-report.md` already exists, do not overwrite it unless explicitly instructed. Instead create `audit/code-audit-report-YYYYMMDD-HHMM.md`.

If the user provides a specific output path, use that path.

If in agent plan mode that prevents regular file writes, write the audit report file as an agent plan that can be implemented after switching to agent code mode.

Do not create separate JSON, notes, findings, evidence, summary, or auxiliary files unless explicitly asked. The single audit report must contain the executive summary, scorecard, detailed findings, implementation plan, implementation rules, and verification checklist.

================================================================================
SCOPE
================================================================================

Focus on actual code quality, source-level build quality, generated-binary quality, runtime behavior, maintainability, correctness, reliability, performance, security, source-level privacy leakage risks, compatibility, and regression resistance.

Explicitly out of scope unless the user asks:

- CI/CD pipeline setup, CI runners, release/deployment automation
- release packaging, installers, installer scripts, app-store packaging, distribution channels
- container publishing/image hardening, infrastructure-as-code, production infrastructure, hosting/cloud account setup
- secrets/certificates outside the source tree, code signing, notarization
- SBOMs, artifact attestation/provenance, release notes, changelogs
- incident-response, on-call/runbook process
- legal/commercial compliance review beyond source-level data-handling and licensing issues
- operational-process readiness, staffing, monitoring process, support process, or external runbooks

Still in scope:

- source code, tests, generated source, runtime configuration, logging behavior, update mechanisms implemented in code
- source-level build scripts/config required to compile, link, analyze, test, fuzz, or inspect the project
- compiler/linker flags, debug/release/sanitizer modes, hardening settings, and generated-binary quality affected by build settings
- generated binaries where available or buildable, including binary hardening, symbol visibility, dynamic dependencies, embedded paths/secrets, and ABI/architecture compatibility
- LSP/typechecking/static-analysis warnings, formatter/linter config affecting code quality
- dependency manifests/lockfiles, source-level dependency vulnerabilities, source-level license compatibility/attribution
- memory safety, resource safety, process stability, malformed-input handling, and denial-of-service risks caused by source code or build settings
- native/FFI boundary safety, parser safety, filesystem safety, dynamic-loading safety, and privilege-boundary safety where applicable
- source-level handling of sensitive data, including secrets, credentials, tokens, personal data, local files, logs, telemetry, crash reports, caches, and generated artifacts
- developer-facing build, test, analyze, sanitizer, fuzzer, troubleshooting, configuration, crash-diagnosis, migration, and recovery documentation in the source tree

Score only in-scope criteria. Do not penalize or reward CI, signing, deployment, packaging, installer, infrastructure, distribution, or operational-process concerns unless explicitly requested.

================================================================================
GENERAL PRINCIPLES
================================================================================

Prefer clear, reliable, maintainable, performant, robust implementations over clever, compact, or fragile shortcuts. Shorter code is not automatically better.

Recommend larger refactors only when they clearly reduce risk, duplication, fragility, technical debt, or long-term maintenance cost.

Do not add features unless required for correctness, reliability, security, privacy-leak prevention, maintainability, source-level build quality, binary quality, production-readiness, compatibility, accessibility where applicable, internationalization where applicable, cost control, domain safety where applicable, or regression prevention.

Do not remove annotations, comments, diagnostics, metadata, or optional debug logging unless definitely outdated, misleading, harmful, unsafe, too expensive, or interfering with normal operation.

Identify previous diagnostic/debug/experimental/temporary features. Decide whether they should be removed, isolated, disabled, cleaned up, or left intact. They must not interfere with production behavior, correctness, performance, stability, security, privacy posture, binary quality, or maintainability.

When proposing fixes, preserve existing behavior, public APIs, compatibility expectations, persisted data formats, source-level build workflows, accessibility/localization behavior where applicable, platform behavior, operational assumptions, and user-visible behavior unless current behavior is clearly incorrect and the change is justified.

Do not dismiss crash, memory, lifetime, native-boundary, parser, concurrency, resource-exhaustion, binary-hardening, dynamic-loading, or malformed-input issues as theoretical if they can plausibly cause process crashes, data corruption, denial of service, privilege escalation, information disclosure, sandbox escape, account compromise, unsafe behavior, or long-term maintenance risk.

================================================================================
OPTIONAL PROJECT CONTEXT
================================================================================

Use provided context to prioritize the audit. If missing, infer purpose and critical paths from code structure, entry points, build files, tests, docs, runtime behavior, generated binaries, and config.

Project name:
[insert]

Primary purpose and users:
[insert]

Critical parts and blast radius:
[insert critical modules/workflows/APIs/UI/storage/real-time/safety paths and likely failure impact]

Code, binary, performance, security, privacy-leak, stability, data, cost, and safety-critical areas:
[insert hot paths, auth, parsing, secrets, sensitive data, long-running jobs, persisted state, cloud/API cost paths, native/FFI code, parsers, untrusted file/network inputs, update mechanisms, plugins, dynamic loading, archive handling, deserialization, privileged operations, hardware/financial/medical/industrial safety if applicable]

Target platforms and platform-specific risks:
[insert OS, architecture, runtime, browser, mobile, embedded, Windows/macOS/Linux risks, ACLs, services, drivers, wake/sleep, signals/SEH, filesystem semantics, symlinks/hardlinks, case sensitivity, ASLR/NX/DEP, ABI/calling conventions, alignment, endianness, pointer width, CPU feature assumptions, dynamic loader behavior, encoding/locale behavior]

Build system, binaries, and tooling:
[insert compiler, linker, package manager, build system, LSP, formatter, linter, analyzers, sanitizers, fuzzers, hardening flags, binary inspection tools, debug/release profiles]

Feature flags, kill switches, rollout controls:
[insert if implemented in source code]

Known problems and constraints:
[insert warnings, TODOs, crashes, weak areas, no-go refactors, licenses, deadlines, supported versions]

================================================================================
AUDIT EXECUTION STRATEGY
================================================================================

Avoid shallow checklist skimming. Audit in focused passes, then produce one consolidated report:

1. Purpose, critical paths, blast radius
2. Correctness, reliability, failure modes, timing, concurrency, backpressure
3. Memory/resources/lifetimes/undefined behavior/sanitizers/native and FFI safety
4. Security, privacy leakage, and source-level threat model
5. Performance, storage I/O, energy, cost, resource exhaustion, and denial-of-service-sensitive paths
6. Architecture, maintainability, duplication, dead code, and bloat
7. Logging, diagnostics, observability, debug behavior, and crash diagnostics
8. Tests, regression hardening, quality gates, fuzzing, and sanitizer/static-analysis coverage
9. Source-level build scripts, LSP, static analysis, compiler/linker/hardening settings, generated-binary inspection, and tooling
10. Dependencies, source-level licensing, APIs, config, encoding, platform compatibility, docs, accessibility/i18n if applicable, and domain safety if applicable

If context limits prevent a full audit, prioritize critical paths, blockers, crash/data-loss risks, security/privacy-leak/safety risks, memory corruption, use-after-free, buffer overflow/underflow, heap/stack corruption, double free, invalid free, stack overflow, integer bounds/allocation bugs, parser bugs, race/deadlock risks, generated-binary hardening, source-build correctness, and user-specified areas. State what was not inspected and lower confidence.

================================================================================
STRICT COMPARABILITY REQUIREMENTS
================================================================================

Follow the required output structure exactly.

Do not rename, reorder, merge, split, or omit report sections.

Do not rename scorecard categories. Do not add scorecard categories. Map unusual issues to the closest category and explain in Notes.

Do not remove categories. If genuinely not applicable, mark N/A and re-normalize scoring.

Do not give high scores to unassessed categories. If evidence is missing, assign a score, lower confidence, and explain missing evidence.

Use exact labels:

- Severity: Critical / High / Medium / Low / Informational
- Confidence: High / Medium / Low
- Release blocker: Yes / No
- Effort: Small / Medium / Large

Finding IDs must be deterministic:

F-[CATEGORY_NUMBER]-[SEQUENTIAL_NUMBER]

Examples: F-01-001, F-04-001, F-11-003

Each finding has one primary category. Mention secondary categories in Notes. Do not duplicate findings unless root causes differ.

================================================================================
AUDIT CATEGORIES
================================================================================

Review the full source tree: source, tests, source-level build files, scripts needed to compile/run/analyze, docs, generated files where relevant, dependency manifests, lockfiles, configs, and source-level project structure. Inspect generated binaries where available or buildable.

1. Correctness and bugs
Review logic bugs, edge cases, bad assumptions, error handling, exceptions, state transitions, cleanup, crashes, regressions, undefined behavior, init/teardown, partial failures, malformed input, fragile integrations, cancellation/retry/restart/shutdown bugs, and bugs in logging/diagnostics/debug paths.

Also review uncaught exceptions, panics, aborts, fatal assertions, off-by-one errors, index/range/length/offset/count/capacity mistakes, integer overflow/underflow/truncation/sign-conversion bugs affecting allocation or bounds checks, incorrect state-machine transitions, unsafe fallback behavior, serialization/deserialization correctness, malformed/corrupted/oversized/truncated/deeply nested input, invalid config, debug/release behavior differences, platform/compiler/runtime differences, and restart/migration/downgrade edge cases.

2. Reliability, failure recovery, concurrency, timing, backpressure, and process stability
Review partial failure, timeouts, cancellation, interrupted shutdown, restart, disk-full, permission/network/dependency failures, corrupted input/state, missing files, invalid config, overload, resource exhaustion, external process failure, lifecycle/recovery/rollback/retry/idempotency, failure loops, races, deadlocks, livelocks, thread safety, async ordering, shared state, locks/atomics/reentrancy, unsafe cancellation/signal handling, blocking calls, subprocess/IPC/socket/file/system-service interactions, monotonic vs wall-clock, timer drift, sleep/wake, scheduling, throttling/debouncing, unbounded queues/tasks, FD/socket/thread-pool exhaustion, rate limits, graceful degradation, lock-free memory ordering, ABA, visibility, progress guarantees, false sharing, and architecture/compiler assumptions.

Also review process crashes from unbounded recursion, stack exhaustion, heap/memory exhaustion, FD/socket/handle/thread/process/subprocess/timer/task exhaustion, repeated crash loops, unsafe signal handlers, cleanup/shutdown handlers that access destroyed state, callbacks/timers/tasks firing after owner destruction, cancellation leaving corrupted state or leaked resources, reentrancy bugs, lock-order inversion, starvation, priority inversion, UI/event-loop/request-thread blocking, TOCTOU reliability races, clock jumps, retry storms, cache stampedes, and behavior when peers or dependencies hang, crash, return malformed data, or violate protocol expectations.

3. Memory, resource, pointer, lifetime, and undefined-behavior safety
Review memory/resource/FD/handle/socket leaks, pointer issues, use-after-free, null/dangling references, ownership/lifetime bugs, unbounded memory growth, excessive allocation, buffers, reference cycles, unsafe aliasing, cleanup omissions, RAII/disposal/finalization, strict aliasing, signed overflow, alignment, invalid lifetimes, out-of-bounds access, uninitialized memory, invalid casts, data races, ABI/FFI boundary errors, and ASan/UBSan/TSan/MSan/Valgrind/static-analyzer coverage where applicable.

Also review buffer overflow/underflow, stack/heap/global buffer overflow, heap/stack corruption, off-by-one reads/writes, use-after-return/scope/move, double free, invalid free, allocator/deallocator mismatch, freeing stack/static/foreign/borrowed memory, stale pointers across callbacks/async tasks/event loops/FFI calls, dangling views/slices/spans/string_views/iterators, iterator/reference invalidation, reference-counting mistakes, ARC/GC/finalizer/disposer ordering bugs, null dereference, invalid pointer arithmetic, pointer truncation, pointer/integer casts, pointer provenance issues, type confusion, invalid downcasts, object lifetime violations, uninitialized padding leakage, size_t/signed index mistakes, allocation-size overflow, unsafe string/memory APIs, non-NUL-terminated string assumptions, UTF-8/UTF-16 byte-count vs character-count bounds bugs, stack overflow from recursion or large stack allocations, mmap/shared-memory lifetime errors, memory-mapped file truncation races, unsafe exception/SEH/signal/unwind handling, calling-convention/layout/packing/alignment/endian mismatches, lock-free memory reclamation bugs, ABA, unsafe code blocks, native extensions, generated bindings, and suppressed sanitizer/static-analysis findings.

4. Security, privacy leakage, and source-level threat model
Review validation, parsing, injection, path traversal, command execution, deserialization, secrets, insecure defaults, permissions, temp files, network security, dependency vulnerabilities, supply chain, auth/authz, sensitive data leakage, code-level update mechanisms, crypto, env vars, file permissions, dynamic/plugin/module loading, privilege boundaries, platform security controls, telemetry implemented in code, retention/deletion behavior implemented in code, access controls implemented in code, audit logging implemented in code, trust boundaries, attacker-controlled inputs, privileged operations, sensitive paths, abuse cases, and bugs that could become vulnerabilities.

Also review memory-corruption exploitability, format-string vulnerabilities, command/shell/argument injection, SQL/NoSQL/LDAP/XPath/template/code/expression injection, unsafe eval/exec/dynamic loading, archive traversal/zip-slip, unsafe decompression, decompression bombs, XML/entity expansion bombs, regex denial of service, algorithmic-complexity DoS, parser differentials, unsafe parsing of attacker-controlled JSON/XML/YAML/TOML/CSV/protobuf/msgpack/image/audio/video/archive/font/document/protocol inputs, unsafe deserialization/object injection, prototype pollution, SSRF, request smuggling, response splitting, header injection, open redirect, CSRF, XSS, unsafe CORS/origin/referrer handling, insecure cookies/sessions, auth/authz bypass, IDOR/BOLA, confused-deputy bugs, privilege escalation, sandbox/permission escape, unsafe setuid/capability/service behavior, symlink/hardlink attacks, TOCTOU security races, unsafe temp files, DLL/library search-order hijacking, unsafe env vars/PATH/LD_LIBRARY_PATH/DYLD_* behavior, unsafe updates/downloads, missing signature/hash verification, weak randomness, nonce/key reuse, insecure crypto modes/KDFs/hashes, timing/cache side channels, secrets or sensitive data in logs/crash dumps/URLs/env/CLI/local storage/telemetry/generated artifacts, insecure debug/admin/test backdoors, missing rate limits, multi-tenant boundary failures, and source-level sensitive-data logging/storage/transmission/retention/deletion/access gaps.

5. Performance, optimization, cost, and energy efficiency
Review hot paths, startup, runtime overhead, allocations, I/O, CPU-heavy loops, repeated work, algorithms, caching, synchronization, blocking, polling, logging, serialization/parsing/formatting, data structures, batching, incremental processing, database queries, cloud/API usage implemented in code, assets referenced by code, background work, dependency/runtime bloat, wakeups, busy loops, timers, battery drain, thermal load, infrastructure cost caused by code behavior, and energy cost. Prefer safe optimizations that preserve readability, correctness, and maintainability.

Also review excessive allocation churn, avoidable copying, unbounded result sets, missing pagination/streaming, N+1 queries, expensive synchronous work on UI/event-loop/request threads, lock contention, false sharing, cache-unfriendly hot paths, excessive logging/metrics/tracing/crash-report overhead, timer/wakeup storms, retries without backoff/jitter, cache stampedes, resource-amplification from malformed input, decompression bombs, regex backtracking blowups, algorithmic-complexity attacks, parser blowups, unbounded caches/logs/diagnostic buffers, binary size/bloat, unnecessary linked dependencies, and optimizations that make crash/security/memory behavior harder to reason about.

6. Storage, filesystem, data persistence, I/O, and disaster recovery
Review SSD/HDD/network-storage I/O, temp files, logs, caches, configs, databases, persisted state, generated artifacts, lock/IPC files, user/app data, excessive writes, write amplification, flushing/fsync, atomicity, corruption/partial writes, network filesystem behavior, retry/cache invalidation, unbounded logs/caches, unsafe paths, cleanup, disk-full/permission failures, unsafe temp files, filesystem races, log rotation/retention/cleanup implemented in code, schemas/migrations/downgrade/cache compatibility, corrupted/partial state recovery, interrupted upgrades, backups/restore implemented in code, disaster recovery validation, and retention/deletion implemented in code.

Also review path traversal, symlink/hardlink races, TOCTOU filesystem races, unsafe archive extraction, unsafe overwrite/delete/recursive-delete behavior, permissions/ACL inheritance bugs, world-readable/writable sensitive files, secrets/PII/keys/session data written unsafely, atomic write/rename patterns, partial write handling, interrupted migration recovery, corrupted cache/config/database behavior, large/sparse files, memory-mapped file truncation/growth races, case-sensitive vs case-insensitive behavior, Unicode filename normalization, Windows reserved names/long paths, stale lock recovery, IPC/socket file cleanup, and safe handling of partial downloads/uploads/imports/exports.

7. Architecture, design, and maintainability
Review bad practices, fragile design, coupling, module boundaries, abstractions, hidden dependencies, duplication, redundancy, dead code, bloat, technical debt, inconsistent patterns, complex control flow, unclear ownership, weak required extensibility, separation of concerns, accidental complexity, testability, global state, dependency direction, error propagation, and configuration architecture.

Also review unclear ownership/lifetime boundaries, unsafe or implicit resource ownership transfer, weak separation between trusted/untrusted data, weak separation between parsing/validation/authorization/execution, unsafe plugin/extension architecture, architecture that makes cancellation/shutdown/retry/recovery unsafe, unbounded queues/tasks/memory, callback/event designs prone to reentrancy or use-after-free, inconsistent async/error/cleanup conventions, leaky abstractions around storage/network/auth/filesystem/process/native boundaries, dead code reachable through reflection/plugins/generated code/dynamic loading/feature flags, duplicated parsers/validators/auth checks/crypto wrappers, unnecessary unsafe/native code, and insufficient isolation of high-risk parsers, native bindings, file extractors, crypto, auth, update logic, dynamic loading, or privileged operations.

8. Code style and consistency
Review formatting, naming, error handling, logging, abstractions, file organization, idioms, docs style, nullability, ownership, lifetime conventions, async/concurrency patterns, config patterns, and test style. Prefer automated formatting/linting/static analysis over subjective style rules.

Also review inconsistent nullability/ownership/lifetime annotations, inconsistent cleanup/disposal idioms, unsafe APIs used without clear wrappers, inconsistent bounds-checking or checked-arithmetic conventions, inconsistent validation and logging-redaction patterns, unclear comments around unsafe/native/FFI/concurrency code, stale comments that hide crash/security risks, unjustified warning/analyzer suppressions, and style patterns that make static analysis, fuzzing, sanitizers, or review less effective.

9. Logging, debugging, diagnostics, and observability
Review optional debug logging, diagnostic remnants, log correctness/levels/volume/formatting, sensitive data exposure, performance impact, error messages, crash diagnostics, metrics/tracing/telemetry implemented in code, and whether diagnostics alter timing, state, behavior, storage writes, privacy posture, binary behavior, or stability. Preserve useful optional debug logging if controlled, efficient, safe, and non-invasive.

Also review leaks of secrets/tokens/credentials/cookies/auth headers/PII/payment data/keys/file contents/memory dumps/stack locals/request bodies/URLs/env vars/CLI args/paths/hostnames/internal topology, crash dumps/core dumps/minidumps containing sensitive data, telemetry/crash-reporting consent/retention/redaction where implemented in code, diagnostic endpoints or debug flags exposed in production, debug behavior that changes timing/concurrency/memory layout/error handling/security posture, logging that masks crashes or swallows exceptions, logging that causes recursion/deadlock/reentrancy/allocation failure/signal unsafety, unbounded log volume, metrics-cardinality explosions, diagnostic memory leaks, unsafe crash handling, production-aborting debug assertions, and observability gaps for critical failures, crash loops, resource exhaustion, malformed-input rejection, and security-relevant events.

10. Tests, regression hardening, and quality gates
Review unit/integration/e2e/fuzz/property/snapshot/regression/concurrency/performance/security/privacy-leak/source-build/binary-inspection/migration/restore/failure-mode tests. Assess reliability, determinism, meaningful assertions, critical-path coverage, static-analysis gates, sanitizer gates, linter/formatter gates, and whether important bugs could return undetected. Do not assess CI runner setup or CI infrastructure unless asked.

Also review coverage for buffer overflow/underflow, stack/heap corruption, use-after-free/return/scope, double/invalid free, integer overflow/truncation/sign-conversion in allocation/bounds paths, malformed/oversized/deeply nested/truncated/corrupted input, missing files, permission/disk-full/network/dependency/subprocess failures, cancellation/timeout/retry/restart/shutdown, partial initialization/writes/migrations, OOM/allocation failure where practical, memory/FD/socket/thread/queue/subprocess/timer/connection/log/cache/rate-limit exhaustion, races/deadlocks/livelocks/reentrancy/async ordering, lock-free/atomic behavior, fuzzing for parsers/decoders/deserializers/importers/archive extractors/protocols/plugins/boundary validators, property tests for serialization/canonicalization/state machines, sanitizer builds, static-analysis findings, dependency vulnerability checks, secret/sensitive-data redaction, auth/access control, filesystem attack tests, security regression tests, performance/DoS regression tests, platform-specific tests, reproducible source builds, generated-binary inspection checks, and crash reproducers.

11. Source-level build scripts, tooling, LSP, static analysis, compiler settings, build environments, and binary inspection
Review LSP/type/static-analyzer/linter/compiler warnings, formatter/editor config, false positives, suppressed warnings, stale generated files, include/module/type paths, dependency discovery, workspace config, source-level build scripts, local build/analyze setup, compiler/linker/optimization flags, debug/release differences, sanitizer/hardened builds, source-build reproducibility, incremental/cross-platform builds, dependency pinning, generated code, cache behavior, determinism, parallelism, environment assumptions, diagnostics, debuggability, hardening, target compatibility, crash diagnosability, generated-binary inspection, and generated-binary quality affected by source/build settings. Do not assess CI runners, deployment automation, signing, packaging, installers, or distribution unless asked.

Also review ASan/HWASan/UBSan/TSan/MSan/LeakSanitizer, Valgrind or equivalent runtime checkers, fuzzing builds, static-analysis configuration, warnings for dangerous APIs, warnings-as-errors for high-risk classes where practical, stack canaries/stack protector, `_FORTIFY_SOURCE` or equivalent fortified checks, PIE, RELRO, NX/DEP, ASLR compatibility, CFI, SafeStack/shadow stack, hardened allocators, frame pointers, debug symbols, symbol stripping policy, core/minidump configuration where source-controlled or code-controlled, exception/unwind settings, LTO/PGO effects on sanitizer/debuggability/UB, optimization flags that expose undefined behavior, integer-overflow/bounds-check options, unsafe-code gates, Rust Miri/Clippy/cargo-audit/cargo-deny/cargo-geiger, Go race detector/vet/staticcheck/fuzzing/cgo safety, JVM/.NET native interop analyzers, TypeScript strictness and runtime validation boundaries, native extension build flags, ABI/calling-convention compatibility, generated-code reproducibility, build scripts executing untrusted inputs, unsafe dependency discovery paths, shell quoting, dangerous suppressions, overly broad sanitizer suppressions, and source-level build logic that downloads or executes code unsafely.

Inspect generated binaries where applicable using tools such as `readelf`, `objdump`, `otool`, `dumpbin`, `checksec`, `ldd`, `otool -L`, `nm`, `strings`, `size`, `file`, platform-specific loader tools, and platform-specific binary inspection tools. Review architecture targets, ABI compatibility, exported symbols, symbol visibility, debug symbols, stripped/unstripped state, embedded paths/secrets, RPATH/RUNPATH/install_name/search paths, dynamic library dependencies, executable stack, writable-executable sections, RELRO/PIE/NX/DEP/ASLR compatibility, stack canaries, CFI/shadow-stack support, section permissions, unexpected bundled code, binary size/bloat, minimum OS/runtime compatibility, CPU feature assumptions, and release/debug/sanitizer binary differences.

12. Dependencies, supply chain, and source-level licensing
Review direct/transitive dependencies, bloat, outdated/vulnerable/unused packages, license compatibility, missing notices, attribution, risky sources, vendored/generated code, binary blobs used by the source tree, dependency pinning, lockfile correctness, and reproducible dependency resolution. Do not audit final release packaging, signing, SBOMs, attestation, or distribution unless asked.

Also review dependencies with known memory-safety, parser, deserialization, archive, decompression, regex, crypto, auth, networking, native, or filesystem vulnerabilities; native dependencies/extensions; transitive dependencies that parse untrusted input; dependencies that execute code during install/build; postinstall scripts; dependency confusion and typosquatting risks; unpinned git/path/url dependencies; abandoned dependencies; duplicate versions; vulnerable crypto/auth/parsing/archive/image/XML/YAML/serialization libraries; vendored code provenance; binary blobs used by source builds; generated code with unknown generator version; lockfile drift; missing notices; risky optional dependencies; and dependency APIs used unsafely.

13. Public API, compatibility, configuration, encoding, feature flags, and source-tree documentation
Review APIs, CLI args, configs, persisted formats, schemas, migrations, caches, downgrade behavior, protocols, plugin/module interfaces, file formats, IPC contracts, env vars, external integrations, user-visible behavior, defaults, config parsing, invalid/missing config, secrets, unsafe defaults, precedence, remote/local conflicts, invalid flag combinations, feature flags, rollout controls implemented in code, kill switches implemented in code, emergency disable paths implemented in code, UTF-8/UTF-16/ANSI, Windows A/W APIs, codepages, Unicode normalization, path/console/filesystem encoding, locale-sensitive parsing/formatting, sorting/collation, README, build/setup docs, local analysis docs, sanitizer/fuzzer docs, API/config docs, troubleshooting docs, crash-diagnosis docs, recovery docs, stale comments, and missing critical source-tree documentation.

Also review malformed config causing crashes, invalid flag combinations causing unsafe behavior, debug/dev/test settings leaking into production behavior, untested feature-flag combinations, config precedence bypassing security controls, env vars injecting unsafe paths/commands/libraries/credentials/plugins/debug behavior, API contracts for ownership/lifetime/concurrency/encoding/error/resource-limit behavior, CLI/API sensitive-data leakage, safe rejection of malformed file formats/protocols, Unicode normalization/case folding/path normalization causing auth/storage/identity/routing bugs, locale parsing affecting security/money/dates/sorting/persisted data, and docs for build/analyze/test/sanitizer/fuzzer workflows, binary inspection, crash troubleshooting, corrupted-state recovery, and safe reset/repair.

14. Accessibility and internationalization, if applicable
If the project has user-facing UI, CLI output, generated reports, documentation UI, or human-facing text, review accessibility and internationalization issues that can cause incorrect behavior, crashes, data loss, security confusion, safety confusion, or unusable critical flows. Otherwise mark N/A.

Review keyboard/focus/screen-reader behavior only for user-facing surfaces where it affects core usability or critical flows. Review Unicode, encoding, locale-sensitive parsing/formatting, path/console/filesystem text boundaries, normalization, collation, bidirectional text, homoglyph/confusable-character risks, truncation hiding important information, localized strings with unsafe formatting or attacker-controlled content, and format-string/localization placeholder mismatches where they affect correctness, crashes, security, compatibility, or persisted formats.

15. Domain-specific safety and failsafes, if applicable
If the project controls hardware, infrastructure through code, money movement, user accounts, privileged system behavior, security-sensitive workflows, medical/industrial systems, automation, or other high-blast-radius workflows, review code-level failsafes, safe defaults, fail-closed/open choices, watchdogs, emergency stops, kill switches, rollback, degraded mode, idempotency, crash/restart behavior, stale-state handling, operator visibility, and whether failures leave the system safe. Otherwise mark N/A.

Also review duplicated actions after retries, partial transactions, inconsistent rollback, unsafe defaults after config loss/corruption, safety impact of memory corruption/undefined behavior/concurrency bugs/malformed inputs/resource exhaustion/restart loops, rate limits under clock jumps/restarts/concurrency, irreversible-operation safeguards, financial/account/security/privileged-operation idempotency, auditability of high-risk actions, and safe behavior under OOM, disk-full, permission failure, corrupted state, partial writes, and failed rollback.

================================================================================
REQUIRED OUTPUT FORMAT FOR THE SINGLE AUDIT FILE
================================================================================

Create one report at `audit/code-audit-report.md` by default.

The report must contain exactly these sections:

1. Executive Summary and Overall Rating
2. Scorecard
3. Findings by Category
4. Code and Binary Quality Production-Readiness Assessment
5. Detailed Implementation Plan
6. Implementation Rules
7. Final Verification Checklist

--------------------------------------------------------------------------------
1. Executive Summary and Overall Rating
--------------------------------------------------------------------------------

This section must appear at the top. Include:

- Verdict: Ready to ship / Ready to ship with minor fixes / Not ready to ship / Blocked
- Total score
- Confidence: High / Medium / Low
- Top 5 highest-risk findings
- Main code-quality blockers
- Main binary-quality blockers
- Main crash/process-stability blockers
- Main memory-safety/resource-safety blockers
- Main security/privacy-leak blockers
- Main non-blocking improvements
- Technical debt assessment
- Regression-hardening assessment
- Whether larger refactors are justified
- Highest-blast-radius risks
- Main recommended next phase
- Note that out-of-scope CI/deployment/signing/packaging/infrastructure/distribution/operational-process criteria were not scored

Explain confidence based on code inspected, builds/tests run, runtime behavior verified, binaries inspected, source-level analyzers run, sanitizer/fuzzer/static-analysis coverage checked, crash/security/memory-risk areas inspected, and categories not fully assessed.

--------------------------------------------------------------------------------
2. Scorecard
--------------------------------------------------------------------------------

Score each applicable category from 0 to 10.

Calibration:
10 excellent; 9 very good; 8 good; 7 acceptable; 6 marginal; 5 risky; 4 poor; 3 very poor; 2 critical weakness; 1 nearly broken/unsafe; 0 broken/unsafe/unassessable; N/A not applicable.

Rules:
- Use integers or one decimal place only.
- Do not use ranges.
- Use N/A only when genuinely not applicable.
- If applicable but not fully assessed, assign a score and lower confidence.
- Do not score out-of-scope CI/CD, signing, deployment, packaging, installer, infrastructure, distribution, or operational-process criteria.
- Do not give high scores to memory/resource/security/build-hardening/binary-quality categories unless there is concrete evidence from code inspection, binary inspection, build settings, sanitizer/static-analysis/fuzzer coverage, tests, or runtime behavior.
- If memory-unsafe/native/FFI code exists and was not meaningfully assessed, lower confidence and score accordingly.
- If generated binaries are in scope but were not inspected or could not be built, lower confidence in source-level build and binary-quality scoring.

Default code/binary-quality weights sum to 100%.

| Category | Weight | Score | Confidence | Notes |
|---|---:|---:|---|---|
| Correctness and bugs | 13% | | | |
| Reliability, failure recovery, concurrency, timing, backpressure, and process stability | 14% | | | |
| Memory, resource, pointer, lifetime, and undefined-behavior safety | 13% | | | |
| Security, privacy leakage, and source-level threat model | 11% | | | |
| Performance, optimization, cost, and energy efficiency | 8% | | | |
| Storage, filesystem, data persistence, I/O, and disaster recovery | 7% | | | |
| Architecture, design, and maintainability | 9% | | | |
| Code style and consistency | 3% | | | |
| Logging, debugging, diagnostics, and observability | 4% | | | |
| Tests, regression hardening, and quality gates | 9% | | | |
| Source-level build scripts, tooling, LSP, static analysis, compiler settings, build environments, and binary inspection | 6% | | | |
| Dependencies, supply chain, and source-level licensing | 2% | | | |
| Public API, compatibility, configuration, encoding, feature flags, and source-tree documentation | 1% | | | |
| Accessibility and internationalization, if applicable | 0% default / N/A unless applicable | | | |
| Domain-specific safety and failsafes, if applicable | 0% default / N/A unless central | | | |

If accessibility/internationalization or domain-specific safety is central, assign it positive weight and reduce less relevant weights so total remains 100%.

N/A formula:
Applicable weight sum = sum of positive weights for non-N/A categories.
Weighted total = sum(category score × category weight for non-N/A positive-weight categories) / applicable weight sum.

Show brief arithmetic after the scorecard.

Verdict rules:
- Ready to ship: no Critical or High code/binary-quality blockers; no unmitigated serious crash/security/privacy-leak/memory-safety blockers; source build/test/binary path sufficiently verified; remaining risks minor/acceptable.
- Ready with minor fixes: no Critical blockers; any High issues are narrow, understood, and not release-blocking; required fixes small/low-risk.
- Not ready: unresolved High blocker, multiple Medium issues creating meaningful risk, insufficient confidence in testing/source-build/binary quality/security/reliability, or insufficient confidence in memory/process-stability risks for high-blast-radius code.
- Blocked: Critical blocker, severe data-loss/security/privacy-leak/safety risk, major memory corruption, high-confidence reachable crash, severe production instability, broken source build, broken generated binary, missing essential source prerequisite, or unverified critical path.

--------------------------------------------------------------------------------
3. Findings by Category
--------------------------------------------------------------------------------

Group findings by category. Include all material findings. Group Low/Informational findings only when they share root cause and fix.

For each finding, use exactly:

ID:
Category:
Severity:
Confidence:
Location:
Problem:
Impact:
Blast radius:
Recommended fix:
Implementation guidance:
Regression risk:
Suggested tests:
Release blocker:
Estimated effort:
Evidence:
Notes:

Evidence must include concrete basis: file paths, functions, commands, source-build output, binary-inspection output, test output, observed behavior, static analysis output, sanitizer output, fuzzer output, dependency advisory output, relevant code patterns, or explicit absence of coverage. If unavailable, write "Evidence unavailable" and lower confidence.

Severity:
Critical = data loss, security compromise, privacy leak, unsafe physical/device state, major crash, severe instability, severe production failure, remotely reachable memory corruption, exploitable memory-safety issue, broken source build, broken generated binary, or broken behavior.
High = serious correctness, reliability, security, privacy-leak, performance, source-build, binary-quality, safety, memory-safety, resource-exhaustion, or maintainability issue.
Medium = real issue, not immediately blocking.
Low = minor issue, cleanup, style problem, small optimization, or localized debt.
Informational = observation, tradeoff, or optional improvement.

When assigning severity, consider attacker reachability, malformed-input reachability, crash likelihood, exploitability, binary exposure, data sensitivity, privilege level, persistence, blast radius, recurrence likelihood, and whether the issue can corrupt memory, persistent state, user data, credentials, financial/medical/safety state, or authorization boundaries.

--------------------------------------------------------------------------------
4. Code and Binary Quality Production-Readiness Assessment
--------------------------------------------------------------------------------

Explicitly answer:
- Is this project production-ready from a code and binary quality perspective?
- Is it ready to ship from a code and binary quality perspective?
- What must be fixed before shipping?
- What binary-quality or generated-binary risks must be fixed before shipping?
- What crash/process-stability risks must be fixed before shipping?
- What memory/resource/lifetime/undefined-behavior risks must be fixed before shipping?
- What security/privacy-leak risks must be fixed before shipping?
- What should be fixed soon after shipping?
- What can be deferred?
- What risks remain after fixes?
- Which parts need special care because they are central to the project?
- Which parts are fragile, risky, under-tested, costly, insecure, privacy-sensitive, platform-sensitive, memory-sensitive, crash-prone, concurrency-sensitive, parser-sensitive, native/FFI-sensitive, binary-sensitive, or safety-sensitive?
- Which areas are acceptable and should not be changed unnecessarily?

Do not assess CI/CD, signing, deployment, packaging, installers, distribution, infrastructure, or operational-process readiness unless asked.

--------------------------------------------------------------------------------
5. Detailed Implementation Plan
--------------------------------------------------------------------------------

This section must be detailed enough for a later coding agent to use as the primary implementation plan.

Phases:
0. Safety and Baseline — establish tests, backups, reproducible source builds, generated-binary baselines, binary-inspection baselines, baseline behavior, known warnings/LSP errors/build output/generated artifacts/failures/performance-cost baselines, critical paths, high-risk modules, crash reproductions where available, sanitizer/static-analysis/fuzzer baselines where applicable. Identify memory-unsafe/native/FFI/parser/concurrency/resource-sensitive code. Avoid behavior-changing refactors until validation exists.
1. Critical Fixes — fix blockers, crashes, broken source builds, broken binaries, data corruption, security/privacy-leak/safety risks, severe regressions, severe instability, memory corruption, use-after-free, buffer overflow/underflow, heap/stack corruption, double free, invalid free, exploitable parser bugs, unsafe deserialization, and critical malformed-input/resource-exhaustion paths.
2. Correctness, Reliability, Compatibility — fix logic bugs, state/lifecycle/error handling, failure recovery, timing, backpressure, compatibility, fragile behavior, cancellation/shutdown/retry/restart issues, malformed input handling, partial failure handling, binary compatibility, and crash-prone edge cases.
3. Regression Hardening — add/improve tests, static analysis, sanitizer coverage, linting, formatting, fuzzing, validation, malformed-input tests, resource-exhaustion tests, concurrency tests, parser tests, security regression tests, binary-inspection checks, and memory/lifetime regression tests. Do not include CI runner/infrastructure work unless asked.
4. Performance, Cost, Energy, Resources, and Binary Size — safe optimizations, lower overhead, improve memory/resource/storage I/O, reduce avoidable code-caused cloud/API/database/bandwidth/energy cost, remove bloat, reduce binary bloat where useful, and address algorithmic DoS or unbounded resource behavior.
5. Architecture and Maintainability — remove duplication, dead code, redundant code, diagnostic leftovers, fragile design, avoidable complexity, unclear ownership/lifetime boundaries, unsafe native/FFI abstraction leaks, and risky parser/security/concurrency abstractions. Refactor only when justified.
6. Source Build, Binary Quality, and Developer Tooling — fix LSP/compiler/static-analysis warnings, source-level build scripts, compiler/linker flags, local build environments, sanitizer/fuzzer/hardened build settings, generated-binary hardening, symbol visibility, dynamic dependency issues, dependency issues, source-level licensing, and crash diagnosability. Exclude CI/CD/signing/packaging/deployment/infrastructure/distribution unless asked.
7. Accessibility, Internationalization, Source Docs, and Domain Safety Where Applicable — fix only applicable accessibility, localization, source-tree docs, config/troubleshooting docs, crash troubleshooting docs, corrupted-state recovery docs, sanitizer/fuzzer/binary-inspection docs, and disaster recovery docs. Validate restore paths where implemented/documented in source.
8. Final Validation — run tests, clean source builds, binary inspection, static analysis, sanitizer/fuzzer validation where applicable, and verify performance/logs/storage/restore/compatibility/accessibility/i18n/safety where applicable. Confirm no regressions, new crashes, privacy leaks, resource leaks, memory-safety regressions, binary-quality regressions, or security regressions.

For each phase include: tasks, related finding IDs, benefit, risk, affected files/modules/binaries, dependencies, validation, whether required before release from code and binary quality perspective, and implementation order.

--------------------------------------------------------------------------------
6. Implementation Rules
--------------------------------------------------------------------------------

When implementing fixes later:
- Make the smallest safe change when sufficient.
- Refactor only when it reduces risk, duplication, fragility, or long-term maintenance cost.
- Preserve behavior unless clearly wrong.
- Preserve useful optional debug logging.
- Preserve annotations/comments unless definitely outdated, misleading, or harmful.
- Fix warning root causes instead of suppressing unless justified.
- Add no features unless needed for correctness, safety, reliability, security, privacy-leak prevention, production-readiness, maintainability, accessibility/i18n where applicable, cost control, domain safety where applicable, binary quality, or regression prevention.
- Ensure every fix has validation.
- Prefer automated tests for bug fixes and regression-prone areas.
- Add targeted regression tests for crashes, memory-safety bugs, parser bugs, malformed inputs, resource exhaustion, security bugs, binary-quality regressions, and concurrency bugs.
- Avoid worsening performance, runtime behavior, storage behavior, cost profile, accessibility/i18n where applicable, platform behavior, safety, source-build assumptions, binary quality, crash diagnosability, or sanitizer/static-analysis coverage.
- Preserve APIs, file formats, config formats, ABI expectations, binary compatibility expectations, and integration contracts unless breaking change is justified.
- Avoid broad stylistic rewrites and clever rewrites of clear code.
- Do not remove apparent dead code until confirming it is unused by builds, reflection, dynamic loading, plugins, generated code, tests, binaries, or integrations.
- Treat existing warnings, LSP errors, compiler warnings, linker warnings, sanitizer findings, fuzzer findings, binary-inspection findings, and static-analysis findings as issues to investigate and fix properly.
- Do not silence sanitizer/static-analysis/compiler/linker warnings unless the suppression is narrow, justified, documented, and safer than the alternative.
- Treat memory-unsafe/native/FFI/concurrency/parser/dynamic-loading code as high-risk until inspected and tested.
- Prefer safe APIs over unsafe string/memory/path/process/dynamic-loading APIs.
- Prefer explicit bounds checks and checked arithmetic for allocation, indexing, parsing, and serialization sizes.
- Prefer bounded queues, bounded concurrency, and backpressure over unbounded growth.
- Prefer explicit ownership/lifetime models over implicit assumptions.
- Preserve or improve compiler/linker hardening flags and generated-binary hardening where applicable.
- Do not introduce new unsafe code, native code, dynamic loading, shell execution, deserialization, or parser complexity unless justified and validated.
- Avoid fixes that merely hide crashes without fixing corrupted state, unsafe behavior, or root cause.
- Preserve crash diagnostics while redacting sensitive data.
- Keep validation reproducible for later agents.

--------------------------------------------------------------------------------
7. Final Verification Checklist
--------------------------------------------------------------------------------

Verify:
- Tests pass.
- Clean source checkout builds cleanly.
- Generated binaries are produced reproducibly enough for the project’s source-level expectations.
- LSP/compiler/linker/static-analysis/formatter/linter/sanitizer issues are resolved or justified.
- No new crashes/regressions.
- No known crash reproducer still crashes unless explicitly accepted with documented rationale.
- Memory-safety checks cover buffer overflow/underflow, stack buffer overflow, heap buffer overflow, global/static buffer overflow, heap corruption, stack corruption, use-after-free, use-after-return, use-after-scope, use-after-move, double free, invalid free, allocator/deallocator mismatch, out-of-bounds read/write, uninitialized memory, null/dangling references, integer-size/bounds errors, pointer/integer conversion errors, alignment errors, strict-aliasing issues, and ABI/FFI boundary errors where applicable.
- Crash-prone paths are tested or validated under malformed input, oversized input, deeply nested input, truncated input, corrupted input/state, resource exhaustion, cancellation/shutdown, restart, OOM/allocation failure where practical, invalid config, missing files, permission failure, disk-full, network failure, dependency failure, subprocess failure, and external service malformed responses.
- Native/hardened builds use appropriate sanitizer, static-analysis, fuzzer, and compiler/linker hardening settings where applicable.
- Hardening settings are checked where relevant: stack canaries, fortified libc/runtime checks, PIE, RELRO, NX/DEP, ASLR compatibility, CFI, SafeStack/shadow stack, hardened allocators, frame pointers, debug symbols, and crash diagnosability.
- Generated binaries are inspected where applicable for hardening, symbol visibility, dynamic dependencies, embedded secrets/paths, unsafe loader search paths, executable stack, writable-executable sections, ABI/architecture compatibility, CPU feature assumptions, binary bloat, and release/debug/sanitizer differences.
- Optional debug logging remains safe and non-invasive.
- Diagnostic leftovers are removed, isolated, disabled, or harmless.
- Logs, telemetry, crash reports, metrics, traces, and error messages do not leak secrets, credentials, tokens, sensitive data, memory contents, command-line secrets, environment secrets, sensitive paths, or sensitive request/response bodies.
- Storage writes, log rotation, cleanup, disk-exhaustion behavior, cache retention, and temporary-file behavior are acceptable.
- Filesystem behavior is safe against path traversal, symlink/hardlink attacks, TOCTOU races, unsafe temp files, unsafe archive extraction, unsafe overwrite/delete behavior, unsafe recursive delete behavior, and permission failures where applicable.
- Resource cleanup, memory behavior, performance, and code-caused cost/energy profile are acceptable.
- Critical paths are tested or explicitly validated.
- Failure modes, timing, clock/sleep/wake/timeout/scheduling, backpressure, and exhaustion behavior are correct where applicable.
- Concurrency behavior is safe: no known data races, deadlocks, livelocks, unsafe reentrancy, callback-after-destroy, async lifetime bugs, or lock-free memory-reclamation bugs.
- Security/privacy-leak/accessibility/i18n/domain-safety issues are resolved or documented where applicable.
- Parser, decoder, deserializer, importer, archive, protocol, and file-format handling are tested against malformed, oversized, deeply nested, truncated, corrupted, and malicious inputs where applicable.
- Backup/restore/migration/disaster recovery paths implemented in code are tested or validated.
- Dependencies and source-level licensing are appropriate.
- Direct/transitive dependencies with parser, crypto, auth, native, filesystem, archive, deserialization, decompression, or network-facing risk are checked for vulnerabilities and unsafe usage.
- Public APIs/configs/persisted data/feature flags/integrations remain compatible unless justified.
- ABI expectations, binary compatibility expectations, dynamic dependency expectations, and platform targets remain compatible unless justified.
- Encoding/Unicode/locale/platform text-boundaries are correct where applicable.
- Source-tree documentation is accurate enough for development, build, analysis, binary inspection, troubleshooting, crash diagnosis, memory-safety validation, sanitizer/fuzzer usage, and recovery.
- Out-of-scope CI/CD/signing/deployment/packaging/installer/infrastructure/distribution/operational-process checks were not scored unless requested.

================================================================================
FINAL RESPONSE REQUIREMENTS
================================================================================

The final report must be practical, specific, evidence-backed, and actionable.

The top of the report must contain the overall rating and executive summary.

Detailed sections must be specific enough for a later coding agent to implement fixes safely.

Avoid vague advice. Prefer concrete findings with locations, risks, fixes, implementation guidance, and validation methods.

If speculative, mark confidence Low or Medium and explain missing evidence.

If a category cannot be fully assessed because code, source-build output, tests, runtime access, generated binaries, binary-inspection output, dependency data, production config, cost data, source-level privacy requirements, UI/localization requirements, platform requirements, hardware/domain requirements, native-symbol/debug data, sanitizer/fuzzer/static-analysis output, crash reproducers, or source-tree documentation are unavailable, say so and reduce confidence.

If no serious issue is found in a category, still include the category in the scorecard and briefly state why it appears acceptable.

Do not omit relevant in-scope issues because they are pre-existing, non-critical, stylistic, outside main application code, hard to reproduce, platform-specific, sanitizer-only, static-analysis-only, binary-inspection-only, or only reachable through malformed input.

Do not assess or score CI/CD setup, CI runners, signing, deployment automation, release automation, packaging, installers, distribution, infrastructure, hosting/cloud account config, operational processes, or legal/commercial compliance unless asked.

The result must be a clear code and binary quality production-readiness assessment with a fixed scorecard, weighted total score, deterministic finding IDs, evidence-backed findings, and detailed phased implementation plan.