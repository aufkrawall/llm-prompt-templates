<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Agent Instructions Template

Use this file as a project-level agent instruction baseline. Replace or extend the project-specific placeholders and constraints when copying it into a repository.

## Critical workflow

- Respect the repository's declared host/platform priority, build system, package manager, and toolchain. Prefer project-local or repository-pinned tools over unrelated global alternatives.
- After code changes, run the smallest relevant build, test, lint, and/or static-analysis commands that provide meaningful verification. Run broader validation when the change has broad impact or the repository requires it.
- Do not claim success from command exit status alone; inspect relevant diagnostics and confirm the changed behavior or artifact when practical.
- For large logs, compiler/test output, generated files, minified bundles, traces, or dumps, start with targeted searches, relevant line ranges, summaries, or head/tail views instead of loading thousands of irrelevant lines into working context. Preserve or reference complete output when it is needed as evidence.
- Do not push, publish, deploy, release, or alter remote state unless explicitly requested or clearly required by the repository workflow.
- Commit changes only when the user or repository workflow explicitly expects agent-created commits. Before committing, review the diff and verification results, and follow the target repository's established commit-message convention when one exists.
- Consult `llm-wiki/` for code, bug, build, test, config, debugging, or behavior work when it exists and the topic is relevant.
- Treat `llm-wiki/` as derived project memory, not as an authoritative source. Verify important claims against code, tests, build scripts, configuration, artifacts, or observed behavior.
- Update `llm-wiki/` when durable project knowledge materially changes. Do not update it for trivial edits with no future-useful context.

## Engineering rules

- Prefer root-cause fixes over workarounds. Do not hide, suppress, weaken, or paper over failures merely to make validation pass.
- Avoid timing bandaids such as arbitrary sleeps, polling delays, or retry loops when they merely mask races or lifecycle defects.
- Do not introduce racy, timing-sensitive, or fragile behavior when a deterministic design is practical.
- Preserve intended features, compatibility guarantees, performance characteristics, and public contracts unless the requested change explicitly alters them.
- Keep code cohesive and maintainable. Split files or modules when size or responsibility materially harms reviewability or correctness; follow project-specific size conventions when documented.
- Avoid bundling unrelated formatting, cleanup, generated churn, or opportunistic refactoring with a behavioral fix when the changes can be separated. Keep diffs focused enough that the root-cause change and its verification remain reviewable.
- Treat dumps, logs, captures, credentials, private keys, tokens, symbols, user data, and other sensitive artifacts carefully. Do not commit or expose them.

## Tests and diagnostics

- For bug fixes, add or improve regression coverage when a focused test can meaningfully prevent recurrence.
- For features, add or adjust tests for the new contract and important edge cases when the project has suitable test infrastructure.
- Do not create low-value tests solely to satisfy a blanket testing rule. Prefer tests that would have failed before the fix or that validate an important invariant.
- Improve diagnostic logging only when it materially helps explain state transitions, failure modes, or future regressions. Avoid noisy logs and do not log secrets or unnecessary sensitive data.
- Preserve useful debug information for diagnosable builds when this is compatible with the project's release policy.
- Do not introduce sleeps or timing assumptions into tests unless timing itself is the behavior being tested and the test remains deterministic.

## Project-specific constraints

Document non-negotiable repository constraints here when copying this template, for example:

- supported platforms and architectures
- required native APIs or implementation technologies
- compatibility guarantees
- performance or latency limits
- behavior that must not be disabled to avoid fixing defects
- required validation scenarios
- prohibited implementation shortcuts

Keep these constraints specific enough to guide work, but avoid embedding stale incident history or one-off debugging details that belong in `llm-wiki/`.

## Debugging and binary analysis

- Inspect available crash dumps, logs, traces, symbols, and produced artifacts when they are relevant to the reported failure.
- Prefer project-documented debugger and symbol-path guidance from `llm-wiki/debug-tools.md` or equivalent local documentation.
- Verify tool availability before relying on documented paths. Treat hardcoded paths as examples unless the project explicitly declares them mandatory.
- Do not mutate global debugger flags, system settings, binaries, symbols, registry state, or persistent environment state unless explicitly requested and justified.

## `llm-wiki/` workflow

- `llm-wiki/` is canonical LLM-maintained derived memory for the repository, but not the sole source of truth.
- For substantial work, start with `llm-wiki/index.md` when present, read only relevant topic pages, then consult `llm-wiki/log/recent.md` for active or stale-risk areas.
- Read archives only when historical context is needed or explicitly linked.
- For trivial localized edits, skip broad wiki loading unless the area is unfamiliar or stale-risk is likely.
- If substantial work would benefit from durable project memory and `llm-wiki/` is missing, consider creating a minimal structure such as `index.md`, `overview.md`, and `log/recent.md` after inspecting the repository.
- Verify important wiki claims against primary project evidence. Mark uncertainty explicitly as an open question, stale-risk, or unverified claim.
- Prefer updating existing pages over creating new ones; create new pages only for reusable topics.
- Keep topic pages focused on current best understanding. Put chronology, partial investigations, and temporary notes in `llm-wiki/log/recent.md`.
- Do not dump raw logs or long command output into durable wiki pages unless the output itself establishes reusable knowledge.
- Update the wiki when durable knowledge changes: architecture, behavior, build/test/package/deploy/debug workflows, root causes, invariants, conventions, rejected approaches, or important follow-ups.
- After substantial wiki changes, check for contradictions, stale claims, duplicates, orphan pages, broken links, missing source anchors, and merge/delete/archive candidates.
