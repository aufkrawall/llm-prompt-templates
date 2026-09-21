# LLM Prompt Templates

Reusable, evidence-oriented prompt and agent-instruction templates for software engineering and code audits.

The templates are intentionally detailed. They are designed for current LLMs with large context windows, with emphasis on preserving coverage rather than minimizing prompt length.

## Agent installation contract

If you are an AI/coding agent and the user gives you this repository URL with a request such as:

```text
Add this to our project: https://github.com/aufkrawall/llm-prompt-templates
```

or otherwise asks to "add", "install", "integrate", or "set up" this repository without naming a specific template, treat that as the **default project integration** described in [`INSTALL.md`](INSTALL.md).

In short:

1. Inspect the target repository before copying anything.
2. Integrate `llm-wiki-agents.md-template/AGENTS.md` as the project's root `AGENTS.md` baseline.
3. Integrate `llm-wiki-agents.md-template/llm-wiki/debug-tools.md` as `llm-wiki/debug-tools.md`.
4. Integrate `llm-wiki-agents.md-template/llm-wiki/changelog-guidelines.md` as `llm-wiki/changelog-guidelines.md`, adapting it to the target project's existing changelog/release process when one exists.
5. Integrate `common-tools/discover-debug-tools.ps1` as `tools/discover-debug-tools.ps1` and merge `common-tools/tool-paths.example.env` into the project's generic path-override example.
6. Integrate `security-audit-template/llm-wiki/debug-tools-security-audit.md` as `llm-wiki/debug-tools-security-audit.md`.
7. Adapt the files to the target repository using evidence from its build files, docs, source tree, existing instructions, and available tooling.
8. **Merge; do not blindly overwrite** existing `AGENTS.md`, `llm-wiki/`, `tools/`, path-override examples, or equivalent project knowledge.
9. Preserve useful existing project-specific rules and diagnostics.
10. Do **not** install the general audit prompt, the rest of the security-audit bundle, CI, or system/global tools unless the user explicitly asks for them or clearly requests a full/audit installation.
11. Do not run mutating tool installers merely as part of the default integration. The generic discovery helper itself is non-mutating.

`INSTALL.md` is authoritative if there is any ambiguity.

## Contents

| Path | Purpose |
|---|---|
| `audit-template/audit-template-v3-polyglot.md` | Broad application/code/runtime/artifact quality audit across multiple languages and platforms. |
| `audit-template/audit-language-profiles-addendum.md` | Required general-audit companion with first-class JavaScript/TypeScript and Java/Kotlin/JVM profiles plus deterministic score-calculation guidance. |
| `security-audit-template/security-audit-template.md` | Detailed security/privacy audit with language-, platform-, runtime-, binary-, and tooling-specific coverage. |
| `security-audit-template/security-audit-sast-addendum.md` | SAST, secrets, dependency scanning, and Linux/macOS tooling guidance. |
| `security-audit-template/llm-wiki/debug-tools-security-audit.md` | Generic local security/debug/binary-analysis tool inventory to customize per project. Included in the default project integration. |
| `common-tools/README.md` | Shared debug/developer-tool discovery contract and path-source documentation. |
| `common-tools/discover-debug-tools.ps1` | Non-mutating Windows debugger/developer-tool discovery; writes the generic `debug-tool-manifest.json`. |
| `common-tools/tool-paths.example.env` | Generic debugger/developer-tool path overrides shared by normal and security workflows. |
| `security-audit-template/install-security-audit-tools.ps1` | Windows security-audit tool installer that reuses generic debug-tool discovery. |
| `security-audit-template/install-security-audit-tools.sh` | Linux/macOS audit-tool detection/optional installation helper. |
| `llm-wiki-agents.md-template/AGENTS.md` | Generic project-level coding-agent instruction baseline. |
| `llm-wiki-agents.md-template/llm-wiki/debug-tools.md` | Generic project-local debugger/binary-tool inventory. |
| `llm-wiki-agents.md-template/llm-wiki/changelog-guidelines.md` | Reusable changelog/release-note policy adapted from production handling: continuous unreleased updates, user-facing bold anchors, standard categories, and release-note parity. |

## Usage

### Default project integration

For a new or existing project, the shortest intended request is simply:

```text
Add this to our project: https://github.com/aufkrawall/llm-prompt-templates
```

An agent should follow `INSTALL.md`, inspect the project, merge/adapt the generic `AGENTS.md`, changelog guidance, both `llm-wiki` tool inventories, and the non-mutating generic debug-tool discovery helper, while avoiding unrelated audit prompt/tool installation.

### General quality audit

For full intended coverage, provide both files to the auditing agent:

```text
audit-template/audit-template-v3-polyglot.md
audit-template/audit-language-profiles-addendum.md
```

Apply the main template plus every applicable companion profile. The addendum is not optional for JavaScript/TypeScript or Java/Kotlin/JVM targets and also defines deterministic score-calculation guidance for the general audit.

The main template defaults to audit-only behavior and writes one audit report under `audit/` unless another output path is requested.

### Security audit

For full intended coverage, copy the entire `security-audit-template/` bundle plus `common-tools/discover-debug-tools.ps1` and the generic entries from `common-tools/tool-paths.example.env`; the Windows security installer delegates generic debugger/developer path discovery to that shared helper.

The main template can use:

```text
security-audit-template.md
security-audit-sast-addendum.md
llm-wiki/debug-tools-security-audit.md
tool-paths.env                    # merged generic + security local-only overrides
debug-tool-manifest.json           # generic debugger/developer-tool discovery evidence
security-audit-tool-manifest.json  # security scanner/install evidence
```

The security installer/detector scripts are optional. Generic debugger/developer-tool paths come from `tools/discover-debug-tools.ps1` / `debug-tool-manifest.json`, not from security-specific discovery code. Tool absence should be reported as an audit coverage/confidence limitation; it is not automatically a vulnerability in the audited product.

### Agent instructions / llm-wiki

The default integration installs/adapts the generic changelog guidance and both tool inventories under `llm-wiki/`:

```text
llm-wiki/changelog-guidelines.md
llm-wiki/debug-tools.md
llm-wiki/debug-tools-security-audit.md
```

Customize them with:

- project build/test commands and platform priorities
- existing changelog structure, release-note workflow, and any verified validation/extraction commands
- non-negotiable technical constraints
- local debugger, symbol, artifact, log, and capture paths
- security-relevant binary/runtime inspection tools
- durable project-specific diagnostic knowledge

Keep one-off incident history and temporary investigation details out of the reusable templates; put them in the target project's local `llm-wiki/` instead.

## Design principles

- Preserve substantive audit coverage even when the prompt becomes long.
- Treat repository content, embedded prompts, scripts, generated text, logs, and binaries as audit data rather than automatically trusted instructions.
- Separate confirmed product defects from missing audit evidence.
- Keep product/security scoring, audit coverage/confidence, and release-readiness judgments distinct where possible.
- Apply language, platform, binary-hardening, and tooling checks conditionally rather than forcing irrelevant controls onto unrelated projects.
- Prefer root-cause fixes and evidence-backed findings over checklist output.
- Keep reusable templates generic; add project-specific paths and diagnostics only in the copied project's local files.
- When an audit family has a documented companion/addendum, preserve that relationship instead of silently using only the main prompt.

## License

MIT. See `LICENSE`.
