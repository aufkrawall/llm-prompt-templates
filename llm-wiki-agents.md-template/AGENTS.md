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
- Every agent-created commit must pass the mandatory pre-commit and post-commit secret-leak checks in `llm-wiki/secret-leak-prevention.md`; never push a commit that has not passed the post-commit check.
- Consult relevant `llm-wiki/` pages when present. Treat them as derived project memory, not authority; verify material claims against code, tests, build/configuration, artifacts, or observed behavior.
- Update `llm-wiki/` only when durable project knowledge materially changes.
- Maintain a root `CHANGELOG.md` using `llm-wiki/changelog-guidelines.md`: preserve an existing project changelog/equivalent, otherwise initialize the baseline changelog unless explicit repository policy or the user opts out. Record changelog-worthy task-owned changes in the current unreleased section before committing.

## Changelog and release notes

- Describe the observable issue, behavior change, compatibility effect, or capability first; keep internal implementation detail secondary.
- Prefer concise bold lead-in anchors and the repository's established changelog categories so entries remain highly scannable.
- Keep release notes aligned with the changelog when both describe the same release, and run repository-provided changelog/release-note validation when available.
- If no project changelog or equivalent exists, initialize the root `CHANGELOG.md` baseline rather than leaving changelog maintenance optional; preserve an explicit repository/user decision not to maintain one.

## Secret leak prevention

- Treat secret safety as a commit gate, not an optional security-audit task.
- Before committing, inspect staged/untracked task-owned files, the staged patch, and the planned commit message; run repository-provided or available local secret scanning when possible.
- After committing, inspect the exact created commit including patch and metadata, and run commit/history secret scanning when available.
- If scanners are unavailable, perform the documented manual fallback; scanner absence never means the check may be skipped.
- Stop before push on any suspected leak. Remove/redact it, rewrite affected local commits as appropriate, and rotate/revoke real credentials according to project policy.
- Never reproduce full discovered secrets in logs, reports, changelogs, issues, PRs, or commit messages.

## Engineering

- Fix root causes rather than hiding, suppressing, weakening, or timing around failures.
- Avoid arbitrary sleeps, polling delays, retries, or other timing-sensitive workarounds unless timing is itself part of the required behavior; prefer deterministic designs when practical.
- Preserve intended features, compatibility guarantees, performance characteristics, and public contracts unless the requested change intentionally alters them.
- Keep behavioral diffs focused; do not mix unrelated formatting, generated churn, cleanup, or opportunistic refactors when they can be separated.
- Do not commit or expose credentials, private keys, tokens, user data, dumps, symbols, captures, or other sensitive artifacts.

## Tests and diagnostics

Regression coverage and diagnosability are first-class deliverables, not optional polish.

- For every bug fix or behavioral correction, explicitly assess both regression coverage and diagnostics even when existing tests pass. Strongly prefer a focused automated regression test that fails before the fix and passes after it.
- For features, cover the new contract and important edge cases when suitable test infrastructure exists.
- Do not add low-value tests merely to satisfy a blanket rule. If focused automation is genuinely impractical or adds little value, preserve a reproducible verification method and state why automated coverage was omitted.
- Add or improve high-signal debug/diagnostic logging when a recurrence would otherwise be materially harder to diagnose, especially around relevant state transitions, inputs, boundaries, recovery paths, and failures. Keep diagnostics non-secret and low-overhead, and preserve useful debug information when compatible with release policy.
- If additional regression coverage or diagnostics are deliberately not added for a non-trivial behavioral change, state the reason.
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
