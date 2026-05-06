# Project memory (canonical)

**Single source of truth** for durable facts, decisions, and continuity across assistants (Cursor, Claude, Gemini, Copilot, etc.). Keep content safe to commit—no secrets, no credentials.

## Rules

- Prefer **append-only** dated entries under [Log](#log).
- Per-agent folders under `.agents/<agent-id>/.memory/` are for **pointers or ephemeral notes** only; long-lived truth lives **in this file**.
- Do **not** treat vendor device-local memory as authoritative for project facts that should be shared via git.

## Log

- YYYY-MM-DD — Initialized via `afb_init` (template).
