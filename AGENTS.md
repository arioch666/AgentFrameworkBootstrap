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

## Activation Protocol (any AI — read this first)

These agents are **markdown + YAML instruction sets, not a runtime service**.
Nothing executes them automatically: the AI assistant working in this repo *is*
the runtime. Whatever assistant you are (Claude, Cursor, Gemini, Copilot, GPT,
or another), activate the framework as follows.

1. **Load the registry.** Read `agents.yml` for the agent list, `routing`,
   `delegation_matrix`, `quota_policy`, and `lifecycle_events`.
2. **Load shared memory.** Read `ai/memory/memory.md` before acting and record
   durable decisions there — it is the single source of truth across assistants.
3. **Enter through orchestration.** For any non-trivial request, adopt the
   `orchestration` role first (`routing.entrypoint_agent`). It selects which
   agent(s) handle the work using `delegation_matrix`.
4. **Adopt an agent by reading its files.** To "run" an agent, read
   `.agents/<id>/agent.md` (behavior), `.agents/<id>/agent.yml` (triggers,
   inputs/outputs), and `.agents/<id>/.memory/memory.md` (agent memory), then act
   under those instructions.
5. **Delegation = role-switching for a single AI.** If you are one model without
   sub-agents, "delegating to agent X" means adopting X's instructions for that
   step, then returning to `orchestration`. If your runtime supports sub-agents,
   you may dispatch them in parallel as advised by `parallelization`.
6. **Follow the Spec Kit lifecycle** for meaningful work:
   `spec -> plan -> tasks -> implement`. `planning` must append a final indexing
   task owned by `indexing`.
7. **React to lifecycle events via triggers.** Each `agent.yml` lists `triggers`;
   map the current event to the agents subscribed to it. For example:
   - `start_of_plan` -> planning, parallelization, speckit-best-practices, trigger-monitor
   - `end_of_plan` -> compliance-guard, architecture-advisor, agent-factory, deduplication-observer, indexing
   - `end_of_execution` -> observer, architecture-advisor, quality-gate, handoff-summarizer, state-checkpoint
   - `post_implement` -> quality-gate, indexing
8. **Honor quota continuity.** Near `quota_policy.warning_threshold_percent`
   (default 80%): `quota-monitor` warns -> `planning` writes a continuity
   mini-plan -> `state-checkpoint` persists state -> `scheduler` sets a resume
   window -> pause. On refresh, `continuity-coordinator` re-validates drift and
   resumes from the checkpoint; `heartbeat-watchdog` escalates missed windows.

If you cannot honor a step (e.g. no scheduling capability), say so explicitly and
fall back to `routing.fallback_agent` (`handoff-summarizer`) to produce a
resumable handoff.

## Core Workflow

For meaningful work, maintain Spec Kit ordering:

`spec -> plan -> tasks -> implement`

The planning agent must append a final indexing task owned by `indexing`.

For non-trivial work, follow the same Spec Kit artifact flow:

- `.specify/memory/constitution.md`
- `.specify/specs/<FeatureId>/spec.md`
- `.specify/specs/<FeatureId>/plan.md`
- `.specify/specs/<FeatureId>/tasks.md`

## FeatureId Contract

All initiative artifacts must share the same `FeatureId` format:

- `NNN-kebab-case-short-name`

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
