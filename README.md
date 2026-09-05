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
3. Integrate `llm-wiki-agents.md-template/llm-wiki/debug-tools.md` under the target project's `llm-wiki/`.
4. Adapt both files to the target repository using evidence from its build files, docs, source tree, existing instructions, and available tooling.
5. **Merge; do not blindly overwrite** existing `AGENTS.md`, `llm-wiki/`, or equivalent project knowledge.
6. Preserve useful existing project-specific rules and diagnostics.
7. Do **not** install the general audit template, security-audit bundle, CI, or system/global tools unless the user explicitly asks for them or clearly requests a full/audit installation.
8. Do not run mutating tool installers merely as part of the default integration.

`INSTALL.md` is authoritative if there is any ambiguity.

## Contents

| Path | Purpose |
|---|---|
| `audit-template/audit-template-v3-polyglot.md` | Broad application/code/runtime/artifact quality audit across multiple languages and platforms. |
| `security-audit-template/security-audit-template.md` | Detailed security/privacy audit with language-, platform-, runtime-, binary-, and tooling-specific coverage. |
| `security-audit-template/security-audit-sast-addendum.md` | SAST, secrets, dependency scanning, and Linux/macOS tooling guidance. |
| `security-audit-template/llm-wiki/debug-tools-security-audit.md` | Generic local security/debug/binary-analysis tool inventory to customize per project. |
| `security-audit-template/install-security-audit-tools.ps1` | Windows audit-tool detection/optional installation helper. |
| `security-audit-template/install-security-audit-tools.sh` | Linux/macOS audit-tool detection/optional installation helper. |
| `llm-wiki-agents.md-template/AGENTS.md` | Generic project-level coding-agent instruction baseline. |
| `llm-wiki-agents.md-template/llm-wiki/debug-tools.md` | Generic project-local debugger/binary-tool inventory. |

## Usage

### Default project integration

For a new or existing project, the shortest intended request is simply:

```text
Add this to our project: https://github.com/aufkrawall/llm-prompt-templates
```

An agent should follow `INSTALL.md`, inspect the project, merge the generic `AGENTS.md` and `llm-wiki` baseline, customize them to the project, and avoid unrelated audit/tool installation.

### General quality audit

Copy or provide `audit-template/audit-template-v3-polyglot.md` to the auditing agent and point it at the target repository.

The template defaults to audit-only behavior and writes one audit report under `audit/` unless another output path is requested.

### Security audit

For full intended coverage, copy the entire `security-audit-template/` bundle into or alongside the target repository rather than copying only the main prompt.

The main template can use:

```text
security-audit-template.md
security-audit-sast-addendum.md
llm-wiki/debug-tools-security-audit.md
tool-paths.env                    # optional local-only overrides
security-audit-tool-manifest.json # optional generated evidence
```

The installer/detector scripts are optional. Tool absence should be reported as an audit coverage/confidence limitation; it is not automatically a vulnerability in the audited product.

### Agent instructions / llm-wiki

Copy `llm-wiki-agents.md-template/` into a project and then customize:

- project build/test commands and platform priorities
- non-negotiable technical constraints
- local debugger, symbol, artifact, log, and capture paths
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

## License

MIT. See `LICENSE`.
