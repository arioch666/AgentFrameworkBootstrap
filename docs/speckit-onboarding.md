# Spec Kit onboarding (`speckit-onboarding`)

First-time tutorial for the Spec Kit lifecycle in this repository. **Any AI provider** can run it by following one portable command file.

## Canonical command

**[`.specify/templates/commands/onboarding.md`](../.specify/templates/commands/onboarding.md)**

The assistant must execute that file phase by phase (stop gates, hands-on sub-commands, cleanup).

## How to invoke

| Provider | What to do |
|----------|------------|
| **Any chat / agent** | Paste: *Follow `.specify/templates/commands/onboarding.md` step by step. Run shell commands when you can.* |
| **Cursor** | Same as above, or reference `.agents/.skills/speckit-onboarding.md` |
| **Claude / Gemini / Copilot** | Add the command path to your project context, or paste the prompt above |
| **Framework agents** | Load `.agents/.skills/speckit-onboarding.md` |

Slash-command names (e.g. `/speckit-onboarding`) are optional wrappers; the **markdown command file** is the source of truth.

## Prerequisites

- Git repository with `.specify/` present (constitution, templates, specs layout).
- Ability to create/delete branches and run `speckit-specify`, `speckit-plan`, `speckit-tasks`, and `speckit-implement` (however your environment maps those names to command files or skills).

If `.specify/` is missing, bootstrap first — see [`afb-init.md`](./afb-init.md).

## What the tutorial does

1. Creates a **practice branch** `onboarding/speckit-lab-<date-or-slug>` (not for merging to `develop`).
2. Walks through **spec → plan → tasks → implement** using FeatureId **`099-speckit-onboarding-lab`**.
3. Writes practice files only under `.specify/specs/099-speckit-onboarding-lab/sandbox/`.
4. **Deletes** the lab folder and drops the practice branch.

## What you must not do

- **Do not** open a PR from the lab branch into `develop`.
- **Do not** keep `099-speckit-onboarding-lab` after the tutorial — cleanup is required.
- **Do not** edit production paths (`src/`, `agents.yml`, etc.) during the lab.

## Abort recovery

If you stop mid-tutorial:

```bash
git checkout develop
git branch -D onboarding/speckit-lab-<your-slug>
```

Remove `.specify/specs/099-speckit-onboarding-lab/` if it still exists.

## After onboarding

- Start a real initiative: new `FeatureId` on a normal feature branch — see [`conventions.md`](./conventions.md) and [`examples/spec-kit-workflow-example.md`](./examples/spec-kit-workflow-example.md).
- Framework structure and agents: [`.agents/onboarding/agent.md`](../.agents/onboarding/agent.md).
- Vendoring this framework into another repo: [`afb-init.md`](./afb-init.md).

## Downstream projects

When you run `afb_init`, the `.specify/templates/commands/` folder (including `onboarding.md`) is copied into your project so the same tutorial works without Cursor.
