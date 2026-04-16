# Cross-Platform `.agents` Framework

## Purpose

Provide a reusable multi-agent architecture for Cursor, Gemini, GPT, and other runtimes with:

- centralized discovery and routing
- per-agent ownership and memory
- trigger-driven orchestration
- quota-aware multi-day continuity

This trunk is intentionally language-agnostic and platform-agnostic. Language or
platform specialization belongs on dedicated branches, not on `develop`.

## Structure

- `agents.yml`
- `.agents/.skills/*.md`
- `.agents/<agent-name>/agent.yml`
- `.agents/<agent-name>/agent.md`
- `.agents/<agent-name>/.memory/memory.md`
- `.agents/<agent-name>/storage/*` (optional)

## Key Agents

Requested agents:

- `observer`
- `orchestration`
- `parallelization`
- `planning`
- `agent-factory`
- `deduplication-observer`
- `indexing`
- `speckit-best-practices`

Support agents:

- `compliance-guard`
- `handoff-summarizer`
- `quality-gate`
- `trigger-monitor`
- `quota-monitor`
- `scheduler`
- `continuity-coordinator`
- `state-checkpoint`
- `heartbeat-watchdog`
- `architecture-advisor`
- `onboarding`

## Quota Continuity

Default warning threshold is 80%.

When threshold is reached:

1. notify user
2. create continuity mini-plan
3. persist checkpoint
4. schedule resume window
5. pause execution

On refresh, orchestration resumes from checkpoint after drift validation.

## Onboarding

The `onboarding` agent provides:

- what to read first
- sample prompts/commands
- quick-start guidance
- links to branch strategy and downstream import documentation

