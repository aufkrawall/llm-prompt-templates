<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Security Audit Template — Condensed, Cross-Language Hardened

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


## Local audit knowledge and tools

Before generic tool assumptions, inspect relevant repository-local audit guidance in this order when present:

1. `llm-wiki/debug-tools-security-audit.md`
2. `llm-wiki/debug-tools.md`
3. `security-audit-sast-addendum.md`
4. generated `debug-tool-manifest.json` and `security-audit-tool-manifest.json`
5. `tool-paths.env` / documented path overrides
6. repository-provided discovery or audit scripts

Treat these files as guidance and path evidence, not proof that a tool or artifact is usable. Resolve tools from generated manifests first, then local overrides, shell/PATH discovery, documented paths, and safe fallbacks. Never guess paths.

Verify relevant tools and inputs before relying on them. Missing tools, targets, binaries, dumps, symbols, logs, or other evidence are coverage limitations, not vulnerabilities by themselves; lower only the affected confidence/readiness or scores. Warn only when the missing evidence materially affects the audit.

Do not mutate global debugger/runtime/system state, install large or global tooling, upload source or sensitive artifacts, or run intrusive diagnostics unless explicitly authorized. Repository installers/detectors are optional; if used, verify their resulting manifests rather than assuming installation succeeded.

Apply project-specific diagnostics only to matching subsystems. Missing DX12/DRED, GPU, media/capture, hook/overlay, or similar project-specific tooling must not affect unrelated projects. For supported Linux/macOS targets, do not claim Windows-equivalent tooling coverage unless comparable evidence exists.

Strict prerequisite/coverage mode is opt-in. When explicitly requested, block deeper analysis only for missing tools or evidence that are actually required for the requested scope.

### Out of scope unless explicitly requested

Hosted CI/CD administration, cloud/hosting configuration, deployment/distribution, signing/notarization, app-store/release packaging, installers, SBOM/provenance/attestation, release notes, incident response/on-call/support, and legal/commercial compliance beyond source-level licensing and security-relevant data handling. Do not score these areas.

## Audit priorities and method

Use code inspection, builds/tests, analyzers, dependency and secrets scanners, sanitizer/fuzzer output, runtime behavior, binary inspection, and manual review as applicable. Missing evidence lowers confidence; it is not a clean result.

Prioritize:
1. reachable Critical/High flaws: broken authentication/authorization/tenancy, privilege escalation, exposed secrets, unsafe defaults, injection/RCE, severe privacy or memory-safety issues, and high-blast-radius paths
2. business-logic/workflow authorization bugs and unsafe state transitions
3. cryptography, token/key/TLS handling, privacy/logging, dependency and supply-chain risk
4. parser/filesystem/network/native/FFI/concurrency/resource-exhaustion and abuse-resistance issues
5. missing hardening or validation that materially weakens release assurance
6. maintainability only when it materially increases security risk or makes fixes unsafe

Separate discovery from findings. Validate reachability, preconditions, mitigations, and actual behavior before reporting material findings. Treat scanner and LLM output as leads until verified against source/runtime evidence. Group shared-root-cause minor issues and avoid cosmetic checklist findings.

### Security-fix non-regression review

When proposing mitigations:
- fix the root cause rather than hiding the symptom
- preserve intended features, contracts, persisted formats, supported platforms, and central workflows unless the existing behavior is unsafe
- do not trade confidentiality/integrity for avoidable availability, compatibility, data-loss, usability, or material performance regressions
- do not disable features, protocols, plugins, diagnostics, acceleration, or platform support as the default fix unless explicitly justified and accepted
- require validation of both the security issue and preserved legitimate behavior

If a proposed fix intentionally changes behavior, compatibility, or material performance, state the change, affected workflows, rationale, alternatives, migration/configuration impact, and how the tradeoff was validated.

### Compiler, linker, and runtime process hardening

Assess whether the project enables strict diagnostics and hardening settings appropriate to the language, platform, architecture, build mode, and risk profile. Distinguish **binary opt-in metadata/compile-time hardening** from **runtime process mitigation state**. A hardened PE/ELF header alone is not proof that the corresponding runtime mitigation is active, and a runtime policy does not compensate for an unhardened binary when the mitigation requires compiler/linker instrumentation.

For C/C++/native code, assess where feasible:

- `-Wall`
- `-Wextra`
- `-Wconversion`
- `-Wshadow`
- `-Werror` where feasible and not counterproductive
- stack protector settings, preferring strong coverage such as `-fstack-protector-strong` where supported
- stack-clash protection such as `-fstack-clash-protection` where supported and relevant
- `_FORTIFY_SOURCE`, preferably level 3 when supported by the libc/toolchain and otherwise the strongest compatible level
- PIE/ASLR compatibility
- RELRO/NOW where applicable
- NX / non-executable stack
- CFI, CET, BTI/PAC/GCS, shadow-stack, or equivalent control-flow protection where practical and supported
- hardened allocator or runtime options where applicable
- debug/release differences that affect security
- removal or isolation of production-invasive diagnostics
- narrow, justified warning suppressions only when unavoidable

Do not require every flag blindly. Evaluate whether omissions are justified for the compiler, platform, build mode, dependency constraints, ABI constraints, runtime/JIT requirements, plugin model, hardware support, and release target. If a mitigation would break a required feature such as JIT compilation, dynamic plugins, instrumentation, or legacy interoperability, record the incompatibility and assess compensating controls rather than silently forcing the mitigation.

### Required language- and toolchain-specific coverage

Do not treat memory-safe languages as automatically secure, and do not apply C/C++ controls mechanically to managed or memory-safe runtimes. Identify every production language, compiler/runtime, build mode, FFI/native boundary, generated-code path, and package ecosystem, then apply the matching checks below. Where multiple languages are present, audit each language independently and audit the boundaries between them.

At minimum, record for each production language/toolchain:

- compiler/runtime version and supported release target
- release/profile settings actually used to ship
- warning/lint/analyzer posture and suppressions
- dependency manifest and lock/integrity mechanism
- native/unsafe/FFI surface area
- concurrency/runtime safety checks that are meaningful for that language
- fuzzing/property/adversarial test coverage for untrusted-input boundaries
- generated-binary hardening where the language emits or bundles native executables/libraries
- debug/release differences, including assertions, overflow behavior, panic/exception behavior, symbols, tracing, and runtime code generation
- whether security claims depend on implementation details that vary by compiler/runtime version

#### C

For C code, assess the native hardening baseline above plus C-specific memory and API risks:

- strict warnings appropriate to the compiler, including conversion/sign/format/prototype/implicit-declaration warnings where supported
- elimination or tightly justified use of unbounded string/memory APIs and unsafe variadic/format-string patterns
- integer overflow/truncation in allocation sizes, lengths, indexes, offsets, protocol fields, and pointer arithmetic
- lifetime/ownership discipline for heap, stack, globals, callbacks, and cross-thread objects
- flexible-array members, packed structures, aliasing, alignment, endian conversion, and serialization assumptions
- `setjmp`/`longjmp`, signal-handler safety, async-signal-safe behavior, and error-path cleanup where relevant
- compiler hardening such as stack protection, stack-clash protection, FORTIFY, PIE, RELRO/NOW, NX, CFI/CET/BTI/PAC/GCS, and production-appropriate auto-variable initialization where supported
- ASan/UBSan and other sanitizer configurations in dedicated test builds where supported
- fuzzing of parsers, protocol handlers, file formats, decoders, archive code, and all other untrusted-input boundaries

Do not accept "clean valgrind" or "clean sanitizer run" as proof of memory safety; report exercised coverage and untested paths.

#### C++

For C++, apply all relevant C/native checks and additionally assess:

- ownership expressed with RAII and standard smart-pointer/container abstractions where practical
- raw owning pointers, manual `new`/`delete`, placement construction, custom allocators, pointer arithmetic, lifetime extension, and object-reuse patterns
- iterator/reference invalidation, bounds assumptions, signed/unsigned conversions, narrowing, and exception-safety of state-changing operations
- type confusion risks from casts, unions/variants, polymorphism, serialization, RTTI, plugin interfaces, and ABI boundaries
- exception behavior across DLL/shared-library/FFI boundaries and whether exceptions can cross incompatible runtimes or C ABIs
- unsafe concurrency, object lifetime across callbacks/tasks, atomics/memory ordering, and thread-safety contracts
- standard-library hardening/assertion modes where supported and compatible, such as GNU libstdc++ assertions or libc++ hardening modes; record whether they are production-enabled or test-only
- Clang/GCC/MSVC static analysis and sanitizers appropriate to the codebase; consider CFI with LTO where practical for high-risk native components
- whether Spectre-class mitigations, speculative-load hardening, or platform-specific mitigated libraries are justified for secrets/high-trust boundaries; do not require them blindly

#### Rust

Rust memory safety substantially reduces some vulnerability classes only for safe Rust. Audit the trusted `unsafe` and native surface explicitly rather than giving Rust code a high score by language choice alone.

Assess where applicable:

- `cargo check`/`cargo build` and `cargo clippy` over representative release feature sets and targets; use `--all-targets` and all compatible features where practical, but do not force mutually exclusive feature combinations
- rustc and Clippy warnings/lints, with security-relevant suppressions narrow and justified; consider denying warnings in controlled builds where maintenance policy supports it
- inventory of `unsafe` blocks/functions/traits/impls, `unsafe extern`/FFI declarations, raw pointers, unions, `MaybeUninit`, manual allocation, `transmute`, raw slice/string construction, `set_len`, pinning, and unsafe `Send`/`Sync` implementations
- `unsafe_code` policy: use `#![deny(unsafe_code)]` for crates that should contain no unsafe code; for crates that require unsafe code, isolate it into small reviewed modules and require documented safety invariants rather than globally denying required functionality
- `unsafe_op_in_unsafe_fn` and equivalent linting so unsafe operations remain explicit and reviewable
- FFI ABI, ownership, alignment, unwinding, callback lifetime, thread-safety, allocator, and panic-boundary behavior; never allow an unwind to cross an ABI boundary that does not permit it
- integer overflow behavior in release builds: use explicit checked/saturating arithmetic or `overflow-checks` where security-sensitive arithmetic requires fail-closed behavior; do not assume debug overflow checks exist in release
- panic strategy (`unwind` vs `abort`) as a deliberate reliability/security tradeoff, especially for services, FFI, and high-assurance components
- Cargo dependency integrity: `Cargo.lock` for shipped applications/binaries where appropriate; registry/source overrides, `[patch]`, git dependencies, build scripts, proc macros, and native-sys crates reviewed as supply-chain/code-execution surface
- `cargo-audit` or equivalent RustSec advisory checking; consider `cargo-deny` or equivalent for advisories, duplicate/version/source/license policy when used by the project
- Miri for suitable unsafe-heavy or invariant-sensitive code where it can execute meaningfully; document unsupported OS/FFI behavior rather than treating skipped Miri coverage as a pass
- sanitizer builds on supported targets/toolchains where material; Rust sanitizer support can be toolchain/target dependent and may require nightly, so record actual support instead of assuming availability
- fuzzing with `cargo-fuzz`/libFuzzer or another suitable engine for parsers, codecs, protocol/file boundaries, unsafe abstractions, and FFI entry points
- emitted PE/ELF/Mach-O hardening exactly as for other native binaries; do not assume Rust automatically provides the required ASLR/CFG/CET/RELRO/NX properties for every target/linker configuration

#### Go

Go removes many memory-management hazards but still requires explicit review of concurrency, `unsafe`, cgo, assembly, reflection, dependency integrity, and emitted native binaries.

Assess where applicable:

- `go test ./...` and `go vet ./...`; add project-appropriate static analyzers such as Staticcheck when available and useful
- `govulncheck ./...` for reachable Go vulnerability analysis, plus dependency inventory from `go list -m -json all` or equivalent
- `go test -race` on supported targets for concurrent components; report exercised workloads because the race detector only finds executed races and is not a production build mode
- built-in Go fuzzing for parsers, protocol handlers, file formats, decoders, validation code, and other untrusted-input boundaries
- all uses of `unsafe`, cgo (`import "C"`), handwritten assembly, `//go:linkname`, raw syscalls, reflection-based mutation/dispatch, and native callback boundaries
- cgo pointer-passing/lifetime rules, ownership across C/Go heaps, callback lifetime, thread affinity, errno/error translation, and whether C dependencies receive their own native hardening/sanitizer review
- whether cgo is actually required; reducing it can reduce native attack surface, but do not disable required integrations merely to satisfy the audit
- goroutine lifecycle, cancellation, channel closure, lock ordering, atomic usage, map access, timer/ticker cleanup, unbounded goroutine creation, retry loops, and memory/CPU amplification
- module integrity and provenance: `go.mod`, `go.sum`, `replace`/`exclude` directives, private-module settings, checksum database/proxy exceptions, vendored modules, and local filesystem replacements
- cryptographic randomness and key/token generation: security-sensitive randomness must not use non-cryptographic PRNG APIs
- nondefault `GODEBUG` or runtime knobs that materially change security, parsing, TLS, HTTP, or compatibility behavior
- optional pointer/check instrumentation in dedicated validation builds where the active Go version/target supports it; record exact flags used rather than relying on version-specific defaults
- emitted PE/ELF/Mach-O hardening and actual build mode. Do not assume Go binaries are PIE or have the desired platform hardening solely because they were built by Go; inspect the release artifact and record internal vs external linking/cgo effects where relevant

#### C# / .NET

Managed memory safety does not remove deserialization, reflection, dynamic-loading, authorization, native interop, dependency, JIT, or runtime-configuration risks. Audit the actual deployment model: framework-dependent, self-contained, single-file, trimmed, ReadyToRun, or Native AOT.

Assess where applicable:

- SDK/runtime/target-framework version, support status, publish mode, runtime identifier, and whether the shipped app depends on a separately serviced runtime
- compiler warnings and .NET analyzers; verify `EnableNETAnalyzers`/analysis level behavior as applicable and review analyzer suppressions. Use `TreatWarningsAsErrors` or targeted warning-as-error policy where sustainable; do not hide security analyzer findings to keep builds green
- nullable-reference analysis for codebases where it is practical, especially security-sensitive APIs, configuration, deserialization, authorization, and boundary code
- `unsafe` blocks, pointers, `stackalloc`, `fixed`, function pointers, `MemoryMarshal`, `Unsafe` APIs, `Span<T>` lifetime escapes, P/Invoke, COM, native callbacks, and custom marshalling
- native handle/resource ownership, preferring safe lifetime abstractions such as `SafeHandle` over unmanaged raw handles where applicable
- integer overflow/truncation in allocation, indexing, offsets, protocol lengths, and native interop; use checked arithmetic or explicit validation where fail-closed behavior is required rather than assuming the default arithmetic context is sufficient
- reflection, expression compilation, `Reflection.Emit`, runtime code generation, `Assembly.Load*`, `AssemblyLoadContext`, `NativeLibrary.Load`, plugin discovery, and user-controlled type/member resolution
- dangerous or legacy deserialization and polymorphic type activation, including any path where untrusted input can select runtime types, constructors, converters, binders, or executable code
- exception filters, finalizers/disposal, async cancellation, task lifetime, synchronization, thread-pool starvation, and unbounded allocation/task creation where security or availability relevant
- NuGet dependency auditing during restore/build. Explicitly audit transitive packages rather than relying on SDK defaults that differ by target framework/SDK; establish policy for NU1901-NU1904 and treat high/critical advisories as release-impacting according to reachability and exploitability
- package source configuration, source mapping, lock files/locked restore where used, local feeds, package signatures/trust policy where applicable, and package/build targets that execute during restore/build
- runtime and framework configuration that changes TLS, globalization, diagnostics, assembly loading, JIT, GC, or compatibility behavior where it materially affects security
- ASP.NET Core security controls where applicable, including authentication/authorization ordering, forwarded-header trust, antiforgery/CSRF, CORS, request-size limits, data-protection key handling, secure cookies, proxy assumptions, and error/detail exposure

For .NET JIT deployments, Windows Dynamic Code Prohibition is generally incompatible with normal JIT code generation. Record this as a runtime requirement instead of falsely scoring the process as unhardened without context. For applications compatible with **Native AOT**, assess it as an optional hardening/deployment choice rather than a universal requirement. Native AOT eliminates runtime code generation, restricts reflection/dynamic assembly behavior, and can support additional native mitigations such as Windows Control Flow Guard; current .NET Native AOT Windows publishing also supports CET shadow-stack compatibility. Verify the emitted native binary and runtime process policies rather than inferring them from the project property alone.

#### Other managed or memory-safe languages

For Java/Kotlin/JVM, Python, JavaScript/TypeScript/Node.js, Swift, and other production languages, apply the same principle: use ecosystem-specific analyzers and dependency tooling, audit unsafe/native extensions and dynamic code loading, and inspect emitted/bundled native artifacts where applicable. At minimum:

- **JVM:** dependency advisories, deserialization, reflection/class loading, JNI/JNA/native libraries, SecurityManager-independent privilege assumptions, TLS/provider configuration, parser/resource-exhaustion risks, and JVM flags that weaken verification or expose diagnostics
- **Python:** dependency locking/auditing, `eval`/`exec`/pickle-style deserialization, subprocess/shell use, import-path/plugin loading, native extension modules, virtual-environment/package-source integrity, and resource-exhaustion/concurrency risks
- **JavaScript/TypeScript/Node.js:** lockfile integrity, lifecycle/install scripts, dependency advisories, prototype pollution, unsafe dynamic evaluation, child processes, SSRF/path handling, native addons, permission/sandbox model where used, and runtime flags
- **Swift:** unsafe pointer/interop use, Objective-C/C bridges, concurrency isolation assumptions, package dependencies, and emitted Mach-O/runtime hardening

A project using a language not listed above must still receive language-appropriate build, analyzer, dependency, unsafe/native-boundary, fuzzing, runtime, and binary-hardening coverage. If the audit environment lacks expertise or tooling for a production language, lower confidence explicitly rather than silently applying another language's checklist.

Platform-specific binary hardening checks should include, where applicable:

- **Windows x64/ARM64:** MSVC or clang-cl warning level such as `/W4`; `/WX` where feasible; `/sdl`; `/GS`; `/NXCOMPAT`; ASLR with `/DYNAMICBASE`; `/HIGHENTROPYVA` for applicable 64-bit targets; Control Flow Guard with `/guard:cf` at compile and link time; `/guard:ehcont` where supported; `/CETCOMPAT` / hardware-enforced stack-protection compatibility where supported; safe DLL search behavior; manifest/UAC expectations; runtime library consistency; PDB/debug-symbol handling.
- **Linux x64/ARM64:** PIE; full RELRO; immediate binding where appropriate; non-executable `PT_GNU_STACK`; no `RWE` load segments or unintended writable+executable mappings; `_FORTIFY_SOURCE` at the strongest compatible level; `-fstack-protector-strong`; `-fstack-clash-protection` where supported; x86 CET such as `-fcf-protection=full` and corresponding ELF GNU properties where supported; ARM64 branch protection such as `-mbranch-protection=standard` (BTI/PAC) and newer guarded-control-stack support where supported; safe `RPATH`/`RUNPATH`; no `DT_TEXTREL`; expected glibc/musl/libstdc++ compatibility; stripped symbols where appropriate. GCC `-fhardened` may be used on supported GNU/Linux toolchains, but record the effective expanded protections because the exact set can change between GCC major versions.
- **macOS x64/ARM64:** hardened runtime expectations where applicable; PIE; stack protector; safe `@rpath`/`@loader_path`/`@executable_path` usage; entitlement assumptions; sandbox expectations where applicable; universal-binary slice parity; deployment target compatibility; debug-symbol handling.

### Required Windows process-mitigation verification

For supported Windows release targets, verify the effective process mitigation policy for representative release processes, not only linker flags. Use `GetProcessMitigationPolicy`, a trusted equivalent inspector, or project-documented tooling. `Get-ProcessMitigation` may be used as supplemental configuration evidence, but do not substitute policy configuration for runtime evidence when the distinction matters.

Assess at minimum, where compatible and applicable:

| Mitigation | Required audit expectation | Important compatibility note |
|---|---|---|
| DEP / NX | DEP enabled; for 32-bit processes verify it is permanent when the product can set/require permanent DEP; verify `/NXCOMPAT` where applicable. For 64-bit native Windows processes, record the OS guarantee that hardware DEP is always enabled rather than requiring an unsupported 32-bit DEP setter. | Old ATL thunk behavior and unusual legacy code may conflict. |
| ASLR | `/DYNAMICBASE`; high-entropy ASLR on applicable 64-bit images; verify effective ASLR policy and bottom-up randomization where available. | Do not claim high entropy for architectures/targets where the option is not applicable. |
| Dynamic code | `ProcessDynamicCodePolicy.ProhibitDynamicCode=1`, with thread opt-out and remote downgrade disabled, **when the process does not require JIT/runtime code generation**. | JIT engines, managed runtimes, browsers, profilers, hot-patching, and some instrumentation may require executable code generation. |
| Strict handle checks | `RaiseExceptionOnInvalidHandleReference=1` and `HandleExceptionsPermanentlyEnabled=1` where compatible. | Can expose latent handle-lifetime bugs as fail-fast crashes; validate normal workflows and third-party modules. |
| Extension points | `DisableExtensionPoints=1` where compatible. | Legacy shell/UI/IME/AppInit-style integrations may depend on extension points. |
| Control Flow Guard | Binary CFG instrumentation and load-config metadata present; runtime CFG enabled. Consider strict CFG only when all executable modules loaded by the process are compatible. | Plugins or third-party DLLs without CFG can break strict CFG. |
| Stack protection | `/GS` enabled for native code; add `/guard:ehcont` and CET/hardware-enforced stack-protection compatibility where supported. | Hardware-enforced stack protection requires compatible hardware/OS/modules and can expose incompatible legacy components. |

Record each mitigation as `Enabled`, `Disabled`, `Not supported`, `N/A — incompatible with required feature`, or `Evidence unavailable`. Do not collapse these into a single "Windows hardening enabled" result.

Recommended Windows evidence includes, as available:

- `dumpbin /headers /loadconfig <binary>` or equivalent PE inspection for NX compatibility, ASLR/high-entropy flags, CFG metadata, EH continuation metadata, and related load-config information
- `GetProcessMitigationPolicy` / trusted runtime inspection for DEP, ASLR, Dynamic Code, Strict Handle Check, Extension Point Disable, CFG, and other applicable process policies
- explicit inspection of every shipped executable and security-sensitive DLL, not only the primary EXE
- module inventory for strict-CFG/CET compatibility and unexpected unsigned/unhardened executable modules where that is in scope

### Linux equivalents and nearest analogues

Linux does not provide one-to-one equivalents for every Windows process mitigation. Audit the actual primitive instead of claiming parity by name.

| Windows concept | Linux equivalent / nearest analogue | Required audit evidence |
|---|---|---|
| DEP / NX | NX page permissions, non-executable `PT_GNU_STACK`, no unintended executable data, and no `RWE` load segments | `readelf -lW`, `objdump -p`, `checksec` if trusted/available, and runtime map inspection where useful |
| ASLR / high entropy | PIE plus kernel ASLR; full userspace randomization uses `kernel.randomize_va_space=2`. Entropy is kernel/architecture controlled; where runtime-host settings are in scope, record `vm.mmap_rnd_bits` / `vm.mmap_rnd_compat_bits` when available. | ELF type/PIE evidence plus applicable sysctl/runtime-host evidence; do not call PIE alone "high-entropy ASLR" |
| Dynamic code prohibited / ACG | Prefer Linux Memory-Deny-Write-Execute (`prctl(PR_SET_MDWE, PR_MDWE_REFUSE_EXEC_GAIN, ...)`) on kernels that support it and applications that do not require JIT. Once set, MDWE protection bits cannot be changed. Service-manager W^X controls, seccomp, or LSM policy may be used as compensating controls where appropriate. | Query MDWE with `PR_GET_MDWE` or trusted helper; inspect runtime mappings for W+X; document JIT/plugin compatibility |
| Strict handle checks | **No direct kernel equivalent.** Invalid file descriptors normally fail with `EBADF` rather than forcing process termination. | Audit FD ownership/lifetime, close-on-exec, duplication/inheritance, stale-FD reuse, and error handling; use fail-fast assertions/testing where justified, but do not label this an OS-equivalent mitigation |
| Extension points disabled | **No direct equivalent.** Nearest concern is blocking unintended loader/plugin injection (`LD_PRELOAD`, `LD_AUDIT`, unsafe `LD_LIBRARY_PATH`, unsafe `RPATH`/`RUNPATH`, untrusted plugin directories) and constraining privileged/service environments. | Loader environment, ELF dynamic tags, plugin search paths, service configuration, and runtime module inventory |
| CFG | On x86, CET indirect-branch/shadow-stack support such as `-fcf-protection=full` plus GNU properties; on ARM64, BTI/PAC such as `-mbranch-protection=standard`; Clang CFI with LTO may provide stronger type-based CFI where practical. | Build flags plus `readelf -nW`/ELF property evidence and runtime/platform support; distinguish compile-time compatibility from active enforcement |
| Stack protection | `-fstack-protector-strong` plus `-fstack-clash-protection` where supported; hardware return-address protection via CET shadow stack on x86 or PAC/GCS on ARM64 where supported | Build flags, symbol/relocation evidence where useful, ELF GNU properties, and architecture/runtime compatibility |

Also assess these Linux-specific process/runtime controls when applicable to the threat model, especially for long-running services or parsers exposed to untrusted input:

- `PR_SET_NO_NEW_PRIVS` / `NoNewPrivileges=yes`
- seccomp filtering and whether the actual filter is active for the running process
- capability bounding/dropping and absence of unnecessary ambient/effective capabilities
- user/group privilege separation and unnecessary setuid/setgid behavior
- mount/filesystem restrictions or service sandboxing where part of the shipped runtime configuration
- `/proc/<pid>/maps` for unexpected writable+executable mappings
- loader environment and runtime-loaded module inventory

Do not score system-wide Linux sysctls, service-manager sandboxing, container policy, or host configuration when deployment/infrastructure is explicitly out of scope. In that case, record them only as runtime assumptions or unverified environmental dependencies unless the project itself ships or requires that configuration.


### Source-level SAST, secrets, and dependency baseline

Before relying on binary or runtime analysis alone, run or inspect source-level baseline checks where applicable.

Use language/ecosystem-appropriate tools. Examples:

| Tool | Category | Use when applicable |
|---|---|---|
| `semgrep` | SAST / structural vulnerability scanning | General source trees, especially web/API/auth/parser/security-sensitive code |
| `flawfinder` | C/C++ risky API scanning | C/C++ codebases |
| `clang-tidy` / compiler analyzers | Native static analysis | C/C++ codebases where supported |
| `gitleaks` | secrets scanning | Source tree and Git history where available |
| `trufflehog` | deeper secrets scanning | High-sensitivity repositories or when history scanning is needed |
| `osv-scanner` | dependency vulnerability scanning | Repositories with lockfiles/manifests |
| `cargo clippy` | Rust correctness/lint analysis | Rust crates/workspaces |
| `cargo-audit` | RustSec dependency advisories | Rust projects with `Cargo.lock` or resolved dependency graph |
| `cargo-deny` | Rust dependency policy | Rust projects using advisory/source/license/duplicate policy |
| Miri | Rust undefined-behavior/interpreter checks | Suitable unsafe-heavy Rust code; target/API support permitting |
| `go vet` | Go static analysis | Go modules |
| `govulncheck` | Go vulnerability analysis | Go modules |
| `go list -m -json all` | Go dependency inventory | Go modules |
| Go race detector | Go concurrency dynamic analysis | Concurrent Go code on supported targets |
| .NET analyzers / Roslyn CA rules | C#/.NET static analysis | C#/.NET projects |
| NuGet audit (`dotnet restore`) | .NET dependency vulnerability audit | NuGet-based .NET projects; include transitives explicitly |
| `npm audit` | Node dependency advisories | Node projects with `package-lock.json` or similar |
| `pip-audit` | Python dependency advisories | Python projects with requirements or lockfiles |
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
- Rust Miri/sanitizer runs where supported and meaningful, with `unsafe`/FFI-heavy paths prioritized
- Go `-race` runs and realistic concurrent workloads on supported targets
- C#/.NET stress, native-interop, checked-boundary, and publish-mode tests; include Native AOT validation when that mode is shipped or specifically proposed as a hardening control

Dynamic-analysis findings in security-sensitive paths should be treated as high risk until root-caused. A dynamic tool's lack of findings is evidence only for the code paths, target, runtime, features, and workload actually exercised.

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

The final report must contain no more than **15 total fix/improvement recommendations**. Include all Critical and release-blocking High findings first, then the highest-risk remaining findings. Group Low/Informational items only when they share root cause and remediation. Put additional validated issues in a concise deferred table.

## Output requirements

The report must contain exactly:
1. Executive Summary and Overall Security Rating
2. Security Scorecard
3. Findings and Recommendations
4. Security Production-Readiness Assessment
5. Implementation Plan
6. Implementation Rules
7. Final Verification Checklist

# 1. Executive Summary and Overall Security Rating

Include the audited target/ref and coverage, verdict, weighted score, confidence, top risks/blockers, material authentication/authorization/business-logic/privacy/secrets/crypto/dependency/runtime/native/binary/domain risks, manual and automated review coverage, relevant local-tool/evidence gaps, high-assurance posture where applicable, major non-regression concerns, and out-of-scope areas not scored.

Verdict values: **Ready to ship / Ready to ship with minor fixes / Not ready to ship / Blocked**.

# 2. Security Scorecard

Score each applicable category 0–10 using integers or one decimal place. Use `N/A` only when genuinely inapplicable. If an applicable area is incompletely assessed, score the observed state and lower confidence rather than treating missing evidence as a pass. High scores require concrete evidence.

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
| Static/dynamic analysis, fuzzing, local audit-tool availability, and security tooling | 4% | | | |
| Security tests, regression hardening, and quality gates | 4% | | | |
| GUI/UI high-blast-radius safety, if applicable | N/A or adjusted | | | |
| Domain-specific safety/failsafes, if applicable | N/A or adjusted | | | |
| High-assurance component design, if applicable | N/A or adjusted | | | |

If GUI/UI, domain safety, or high-assurance component safety is central, assign positive weight and reduce less relevant weights so the total remains 100%.

Weighted total = `sum(score × applicable positive weight) / sum(applicable positive weights)`. Show brief arithmetic.

Verdict guidance:
- **Ready to ship:** no Critical/High release blockers and release-critical security paths are sufficiently verified.
- **Ready to ship with minor fixes:** no Critical blocker; remaining issues are bounded and not release-blocking.
- **Not ready to ship:** unresolved release-blocking risk or insufficient confidence in a release-critical area.
- **Blocked:** essential prerequisites/evidence are unavailable or a Critical condition prevents meaningful release assessment.

# 3. Findings and Recommendations

Use deterministic IDs `F-[CATEGORY_NUMBER]-[SEQUENTIAL_NUMBER]`. Each finding must contain:

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

Evidence should identify concrete source/artifact locations and relevant reproduction, build/test/analyzer/sanitizer/fuzzer/scanner/dependency/binary/runtime/manual-review results. If evidence is unavailable, say so and lower confidence; do not promote an unverified concern into a material confirmed finding.

For each recommended fix, state any meaningful feature, compatibility, platform, resource, latency, or user-visible impact. Severity reflects supported impact and likelihood, not the mere presence of native code, `unsafe`, reflection, FFI, or a missing optional mitigation.

# 4. Security Production-Readiness Assessment

State whether the project is security-ready to ship, what must be fixed before shipping, what can follow or defer, residual risks, material coverage gaps, central/high-risk components, and areas that appear acceptable. Explicitly note any proposed mitigation that removes behavior or imposes a compatibility/performance tradeoff.

Do not assess out-of-scope deployment, signing, packaging, infrastructure, distribution, or operational-process readiness unless requested.

# 5. Implementation Plan

Group selected findings into the fewest practical phases, ordered by severity and dependency. For each phase include finding IDs, tasks, affected files/modules/artifacts, dependencies, validation, non-regression checks, release requirement, and order. Do not emit empty canned phases.

# 6. Implementation Rules

For later fixes:
- make the smallest safe root-cause change
- preserve intended behavior, APIs, formats, ABI/configuration/persistence contracts, supported platforms, and central workflows unless they are themselves unsafe
- do not substitute feature disablement, broad suppression, or avoidable performance/availability regressions for a real fix
- keep refactors tied to a selected finding or material security-risk reduction
- preserve useful diagnostics and generated-binary hardening; keep suppressions narrow and justified
- validate each fix with the original reproducer or abuse case and focused automated regression tests when practical
- recheck affected unsafe/native/FFI, parser, concurrency, privilege, auth, tenancy, dynamic-loading, and other high-blast-radius boundaries

# 7. Final Verification Checklist

Report `Passed / Failed / Partial / Not run / N/A`, evidence, and limitations for the applicable areas below:

- supported release targets/configurations and central security workflows
- known exploit/crash reproducers and selected findings
- relevant language/toolchain checks defined above, including unsafe/native/FFI boundaries
- authentication, authorization, tenancy, business logic, sensitive-data handling, cryptography, injection/parser/filesystem/network risks implicated by the target
- static/dynamic analysis, dependency/secrets scanning, fuzzing, malformed-input and abuse-case coverage where applicable
- release binaries/artifacts: hardening, loader/dependency behavior, embedded sensitive data, target/ABI compatibility, and runtime mitigation evidence where applicable
- regression/non-regression validation for proposed fixes
- unavailable tools, targets, symbols, binaries, logs, dumps, or other evidence and their effect on coverage/confidence
- confirmation that project-specific diagnostics were applied only to matching subsystems and out-of-scope operational areas were not scored

Do not restate the entire audit prompt as a checklist. Summarize the evidence actually obtained.
