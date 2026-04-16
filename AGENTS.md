# AGENTS

## Framework Model

This project uses a hybrid agent architecture:

- **Global registry** in `agents.yml`
- **Per-agent machine config** in `.agents/<agent-name>/agent.yml`
- **Per-agent behavior doc** in `.agents/<agent-name>/agent.md`
- **Per-agent persistent memory** in `.agents/<agent-name>/.memory/memory.md`
- **Optional storage** in `.agents/<agent-name>/storage/`
- **Shared skills** in `.agents/.skills/*.md`

## Core Workflow

For meaningful work, maintain Spec Kit ordering:

`spec -> plan -> tasks -> implement`

The planning agent must append a final indexing task owned by `indexing`.

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

