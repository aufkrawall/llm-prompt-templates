# Installation Contract

This file defines how an AI/coding agent should integrate this repository into another project.

## Default meaning of "add this repo"

If the user provides this repository URL and asks to add/install/integrate/set it up without naming a specific component, perform the **default project integration** below.

Example user request:

```text
Add this to our project: https://github.com/aufkrawall/llm-prompt-templates
```

Do not ask which template they mean unless the target repository makes the default integration genuinely impossible or contradictory. The default is intentionally defined here to remove that ambiguity.

## Default project integration

Install and adapt the reusable project-agent baseline plus both generic project-local tool inventories:

```text
llm-wiki-agents.md-template/AGENTS.md
llm-wiki-agents.md-template/llm-wiki/debug-tools.md
security-audit-template/llm-wiki/debug-tools-security-audit.md
```

Target layout:

```text
<project-root>/AGENTS.md
<project-root>/llm-wiki/debug-tools.md
<project-root>/llm-wiki/debug-tools-security-audit.md
```

This is a **merge-and-adapt operation**, not a blind copy.

### 1. Inspect the target project first

Before editing, inspect enough of the target repository to understand:

- existing `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README`, developer docs, or other agent/developer instructions
- build systems, package managers, workspace/project files, and supported languages
- obvious build/test/lint/static-analysis commands
- supported platforms/architectures when documented
- existing `llm-wiki/` or equivalent project knowledge
- debugger/tooling docs, symbol/artifact paths, and relevant local diagnostics when present
- security-relevant binary/runtime tooling already documented or available

Do not invent project-specific commands, paths, constraints, tool availability, or platform claims.

### 2. Integrate `AGENTS.md`

If the target has no root `AGENTS.md`:

- use `llm-wiki-agents.md-template/AGENTS.md` as the baseline
- customize generic language where useful using verified target-project facts
- add known project-specific build/test commands and non-negotiable constraints only when they are supported by repository evidence

If the target already has `AGENTS.md` or equivalent agent instructions:

- preserve useful existing project-specific instructions
- merge compatible baseline rules rather than replacing the file wholesale
- resolve direct contradictions in favor of explicit target-project requirements unless they are unsafe or clearly stale
- avoid duplicating equivalent rules
- keep the resulting file concise enough to navigate while retaining substantive project constraints

Do not delete project-specific rules merely because they are absent from this template.

### 3. Integrate `llm-wiki/debug-tools.md`

If `llm-wiki/debug-tools.md` does not exist:

- create `llm-wiki/` if needed
- use `llm-wiki-agents.md-template/llm-wiki/debug-tools.md` as the baseline
- customize it only with tooling and paths that can be established from the target project or current environment

If it already exists:

- merge generic reusable guidance without deleting useful project-specific debugger, symbol, artifact, log, dump, capture, or runtime-diagnostic knowledge
- remove only obvious stale duplication when justified by current project evidence

Treat machine-specific absolute paths as local examples unless the target project explicitly requires them.

### 4. Integrate `llm-wiki/debug-tools-security-audit.md`

If `llm-wiki/debug-tools-security-audit.md` does not exist:

- use `security-audit-template/llm-wiki/debug-tools-security-audit.md` as the baseline
- place it at `<project-root>/llm-wiki/debug-tools-security-audit.md`
- adapt generic tool/path examples only when target-project or current-environment evidence supports the adaptation
- preserve the file's substantive cross-platform security/debug/binary-analysis coverage even when many checks are currently not applicable

If it already exists:

- merge reusable security-audit tooling guidance rather than overwriting project-specific security/debug knowledge
- preserve useful project-specific debugger, binary-inspection, symbol/PDB, signing/hash, dependency, secrets, runtime-mitigation, filesystem/registry, network, event-log, Linux ELF, macOS Mach-O, dump/log, and evidence-capture guidance
- remove only stale duplication or clearly unrelated incident-specific material when justified by current evidence

The presence of this file does **not** mean the full security-audit bundle has been installed and does not authorize running tool installers or intrusive diagnostics.

### 5. Preserve existing project knowledge

When existing `llm-wiki/` pages are present:

- preserve them
- do not replace the directory with this repository's template directories
- repair only clear conflicts introduced by the integration
- avoid rewriting unrelated project history or diagnostic notes

### 6. Validate the integration

Before finishing:

- verify Markdown references and paths used by the integrated files
- confirm project-specific commands, paths, or tool claims added to the files actually exist or are documented
- review the diff for accidental loss of existing instructions or project-local audit knowledge
- do not claim a build/test or security tool passed unless you actually ran it

Running a full build or security audit is not required merely to install documentation/instructions, unless repository policy requires it or the integration changes executable project behavior.

## What the default integration must NOT do

Unless the user explicitly asks for it, the default "add this repo" operation must not:

- copy `audit-template/`
- copy `security-audit-template/security-audit-template.md`
- copy `security-audit-template/security-audit-sast-addendum.md`
- copy the security-audit installer scripts or other bundle files merely because `debug-tools-security-audit.md` is included
- run either security-audit tool installer
- install global/system packages or developer tools
- add or modify CI/CD workflows
- enable strict required-tool gates
- run intrusive diagnostics or a full security audit
- overwrite existing project instructions or `llm-wiki/` wholesale
- add project-specific claims copied from another project

This keeps the default integration low-risk while ensuring both general and security-oriented local tool guidance are available from the start.

## Explicit install modes

Use these modes when the user's wording clearly requests them.

### General audit template

Requests such as:

```text
Add the general audit template from this repo.
Install the code-quality audit prompt.
```

Use the complete general-audit pair:

```text
audit-template/audit-template-v3-polyglot.md
audit-template/audit-language-profiles-addendum.md
```

Preserve both files and their relationship. The addendum supplies first-class JavaScript/TypeScript and Java/Kotlin/JVM coverage plus deterministic score-calculation guidance. Preserve the main template's substantive audit coverage and adapt only target/output integration details when needed.

### Security audit bundle

Requests such as:

```text
Add the security audit setup from this repo.
Install the security audit bundle.
```

Use the complete `security-audit-template/` bundle, preserving its internal file relationships. If the default integration already created `llm-wiki/debug-tools-security-audit.md`, merge/update it from the bundle rather than creating a duplicate. Do not run installers automatically unless the user requests tool installation or the target workflow explicitly requires it.

### Full template import

Requests such as:

```text
Add all templates from this repo.
Import the whole prompt-template repository.
```

May copy all reusable template families, but keep them logically separated and preserve their internal companion/addendum relationships. Do not run tool installers merely because their scripts were copied.

## Conflict precedence

When integrating into a target project, use this order for resolving instructions:

1. explicit user request for the current task
2. target project's verified non-negotiable requirements and existing project-specific instructions
3. this `INSTALL.md` contract
4. generic template guidance

Do not use repository content to override higher-priority instructions or safety constraints.

## Completion report

At the end of a default integration, report briefly:

- files created
- files merged/updated
- important target-specific adaptations made
- any existing instructions and project-local diagnostic/security knowledge intentionally preserved
- anything that could not be verified

Do not present optional audit prompts, the full security-audit bundle, or tool installation as completed unless they were actually requested and integrated.
