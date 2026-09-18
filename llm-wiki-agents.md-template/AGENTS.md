<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Agent Instructions Template

Use this file as a project-level baseline. Add only repository-specific constraints that materially change how work should be performed.

## Workflow

- Follow the repository's declared platform priority, build system, package manager, toolchain, and pinned/project-local tools.
- After code changes, run the smallest relevant build, test, lint, and/or static-analysis commands that meaningfully verify the change. Broaden validation when impact or repository policy requires it.
- Confirm the changed behavior or artifact when practical; do not infer success from exit status alone.
- Keep large logs, generated output, traces, dumps, and minified files out of working context unless needed; inspect targeted ranges or summaries and retain full output only as evidence.
- Do not push, publish, deploy, release, alter remote state, or create commits unless the user or repository workflow requires it.
- Before committing, review the diff and verification results and follow the repository's commit-message convention.
- Consult relevant `llm-wiki/` pages when present. Treat them as derived project memory, not authority; verify material claims against code, tests, build/configuration, artifacts, or observed behavior.
- Update `llm-wiki/` only when durable project knowledge materially changes.

## Engineering

- Fix root causes rather than hiding, suppressing, weakening, or timing around failures.
- Avoid arbitrary sleeps, polling delays, retries, or other timing-sensitive workarounds unless timing is itself part of the required behavior; prefer deterministic designs when practical.
- Preserve intended features, compatibility guarantees, performance characteristics, and public contracts unless the requested change intentionally alters them.
- Keep behavioral diffs focused; do not mix unrelated formatting, generated churn, cleanup, or opportunistic refactors when they can be separated.
- Do not commit or expose credentials, private keys, tokens, user data, dumps, symbols, captures, or other sensitive artifacts.

## Tests and diagnostics

- For bug fixes and behavioral changes, explicitly assess regression coverage and diagnostics even when existing tests pass; add or improve focused coverage when practical, preferably tests that fail before the fix and pass after it.
- For features, cover the new contract and important edge cases when suitable test infrastructure exists.
- Do not add low-value tests merely to satisfy a blanket rule. If useful automation is impractical, preserve a reproducible manual verification method and state the limitation.
- Improve diagnostics only when they materially aid recurrence diagnosis. Keep them high-signal, non-secret, low-overhead, and preserve useful debug information when compatible with release policy.
- Do not introduce sleeps or timing assumptions into tests unless timing is the behavior under test and the test remains deterministic.

## Project-specific constraints

When copying this template, record only non-negotiable repository constraints, such as:

- supported platforms and architectures
- required APIs or implementation technologies
- compatibility guarantees
- performance or latency limits
- required validation scenarios
- behavior that must not be disabled to avoid fixing defects
- prohibited implementation shortcuts

Keep incident history and one-off debugging details in `llm-wiki/`, not here.

## Debugging and binary analysis

- Inspect relevant dumps, logs, traces, symbols, and produced artifacts when they can establish the reported failure or its root cause.
- Prefer project-documented debugger and symbol-path guidance.
- When `tools/discover-debug-tools.ps1` and `debug-tool-manifest.json` exist on Windows, use the manifest as machine-specific path evidence instead of duplicating SDK/MSVC discovery logic.
- Verify tool availability before relying on documented paths. Treat hardcoded paths as examples unless the repository declares them mandatory.
- Do not mutate global debugger flags, registry/system settings, binaries, symbols, or persistent environment state unless explicitly requested and justified.

## `llm-wiki/` workflow

- For substantial work, start with `llm-wiki/index.md` when present, read only relevant topic pages, then consult `llm-wiki/log/recent.md` for active or stale-risk areas.
- Read archives only when historical context is needed or explicitly linked.
- Skip broad wiki loading for trivial localized edits unless the area is unfamiliar or likely stale.
- If substantial work would benefit from durable project memory and the core wiki pages are missing, create a minimal `llm-wiki/index.md`, `llm-wiki/overview.md`, and `llm-wiki/log/recent.md` after inspecting the repository.
- Verify material wiki claims against primary project evidence; mark uncertainty as an open question, stale-risk, or unverified claim.
- Prefer updating existing topic pages; create new pages only for reusable topics. Keep current understanding on topic pages and chronology or partial investigations in `llm-wiki/log/recent.md`.
- Do not copy raw logs or long command output into durable wiki pages unless the output itself is reusable evidence.
- After substantial wiki changes, check for stale or contradictory claims, duplicates, broken links, and obsolete pages.
