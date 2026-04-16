# tradingpatternbot

TradingPatternBot is a pattern-analysis project that now includes a cross-platform,
Spec Kit-aligned multi-agent execution framework for planning and delivery.

## What This Repo Contains

- A hybrid agent system for Cursor/Gemini/GPT-style workflows
- Shared routing and delegation in `agents.yml`
- Per-agent definitions under `.agents/`
- Agent memory and optional storage for long-running continuity
- Documentation for architecture, lifecycle, and usage patterns

## Agent Framework Layout

- Global registry: `agents.yml`
- Per-agent machine config: `.agents/<agent-name>/agent.yml`
- Per-agent behavior instructions: `.agents/<agent-name>/agent.md`
- Per-agent memory: `.agents/<agent-name>/.memory/memory.md`
- Optional per-agent storage: `.agents/<agent-name>/storage/`
- Shared reusable skills: `.agents/.skills/*.md`

## Current Agent Capabilities

- Core workflow agents: orchestration, planning, parallelization, observer, indexing
- Governance/quality agents: compliance-guard, quality-gate, deduplication-observer
- Continuity agents: quota-monitor, scheduler, continuity-coordinator, state-checkpoint, heartbeat-watchdog
- Evolution agents: architecture-advisor, agent-factory, speckit-best-practices

## Workflow Principles

- Keep work in Spec Kit order: `spec -> plan -> tasks -> implement`
- Append an index update task at the end of each plan
- Emit end-of-execution recommendations (observer + architecture-advisor)
- Support multi-day execution with quota-aware pause/resume continuity

## Start Here

- `AGENTS.md`
- `docs/README.md`
- `docs/agents-framework.md`
- `docs/agent-lifecycle-examples.md`

## Quick Start

### 1) Add a New Agent

Create the standard folder structure:

```text
.agents/<agent-name>/
  agent.yml
  agent.md
  .memory/memory.md
  storage/            # optional
```

Then register the agent in `agents.yml`:

- add an entry under `agents:`
- define routing/delegation updates in `routing` and/or `delegation_matrix`
- add lifecycle triggers in the agent's `agent.yml`

### 2) Run a Plan Cycle

Use the standard Spec Kit flow:

1. Define/update spec
2. Generate plan
3. Generate tasks
4. Implement tasks
5. Run end-of-execution reviews (`observer`, `architecture-advisor`)
6. Execute final index update task (`indexing`)

### 3) Handle Long-Running Work (Quota-Aware)

When quota approaches threshold (default 80%):

1. `quota-monitor` triggers continuity flow
2. `planning` produces a continuity mini-plan
3. `state-checkpoint` persists resumable state
4. `scheduler` sets resume window
5. `continuity-coordinator` resumes from checkpoint after refresh
