---
description: Activate the AgentFrameworkBootstrap agents and enforce the Spec Kit lifecycle.
alwaysApply: true
---

# Agent Framework + Spec Kit Workflow Rule

When working in this repository:

## Activate the agent framework

- Read [`AGENTS.md`](../../AGENTS.md) and follow its **Activation Protocol** before
  meaningful work: load the registry in [`agents.yml`](../../agents.yml), enter
  through the `orchestration` agent, and adopt individual agents by reading
  `.agents/<id>/agent.md`.
- Delegation for a single assistant means role-switching: adopt the target
  agent's instructions for that step, then return to `orchestration`.

## Spec Kit lifecycle

- Follow the `spec -> plan -> tasks -> implement` lifecycle for any meaningful change.
- Use the artifacts under `.specify/` as the source of truth.
- Ensure documentation updates are represented as a spec initiative (not an afterthought).
- Every plan must end with an index-update task owned by the `indexing` agent.

If you are unsure what to do next, start from:

1. `.specify/memory/constitution.md`
2. `.specify/specs/<FeatureId>/spec.md`
3. `.specify/specs/<FeatureId>/plan.md`
4. `.specify/specs/<FeatureId>/tasks.md`

## Project memory

Record durable, shareable context in [`ai/memory/memory.md`](../../ai/memory/memory.md).
Prefer repo-local memory over device-local vendor memory for facts that belong in git.
