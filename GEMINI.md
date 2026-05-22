# GEMINI.md

This repository uses the **AgentFrameworkBootstrap** multi-agent framework.

**Before doing meaningful work, read [`AGENTS.md`](AGENTS.md) and follow its
"Activation Protocol".** It explains how to load the agent registry
(`agents.yml`), enter through the `orchestration` agent, adopt individual agents
by reading `.agents/<id>/agent.md`, follow the Spec Kit lifecycle
(`spec -> plan -> tasks -> implement`), and honor quota-aware continuity.

Durable, shareable project facts live in
[`ai/memory/memory.md`](ai/memory/memory.md) — read it first and record decisions
there rather than in device-local memory.
