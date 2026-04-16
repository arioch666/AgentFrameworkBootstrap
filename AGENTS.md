# AGENTS

## Framework Model

This project uses a hybrid agent architecture:

- **Global registry** in `agents.yml`
- **Per-agent machine config** in `.agents/<agent-name>/agent.yml`
- **Per-agent behavior doc** in `.agents/<agent-name>/agent.md`
- **Per-agent persistent memory** in `.agents/<agent-name>/.memory/memory.md`
- **Optional storage** in `.agents/<agent-name>/storage/`
- **Shared skills** in `.agents/.skills/*.md`

This trunk is intentionally language-agnostic and platform-agnostic. Language or
platform specialization should live on dedicated branches, not on `develop`.

## Core Workflow

For meaningful work, maintain Spec Kit ordering:

`spec -> plan -> tasks -> implement`

The planning agent must append a final indexing task owned by `indexing`.

## Onboarding

- `onboarding` helps new users understand the framework, docs, and first commands.
- Start with:
  - `docs/README.md`
  - `docs/agents-framework.md`
  - `docs/agent-lifecycle-examples.md`
  - `docs/downstream-import-contract.md`

## Trigger and Continuity Highlights

- `trigger-monitor` routes lifecycle trigger events to `orchestration`.
- `quota-monitor` warns around 80% quota and initiates continuity flow.
- `scheduler` + `continuity-coordinator` resume work after quota refresh windows.
- `heartbeat-watchdog` escalates missed resume windows.

## End-of-Execution Reviews

- `observer` emits recommendation summaries:
  - candidate new agents
  - candidate reusable skills
  - candidate parallelization patterns
- `architecture-advisor` emits architecture-flow improvements at end-of-plan/end-of-run.

## Branching Guidance

- `develop` is the shared trunk.
- Language/platform agent packs are expected on dedicated branches such as:
  - `kotlin`
  - `android`
  - `kmp`
  - `python`
- Shared fixes should land in `develop` first whenever possible.

