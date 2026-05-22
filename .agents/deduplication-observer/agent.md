# Agent: deduplication-observer

## Purpose
Detects duplicated or conflicting documentation and guidance.

## Operating Rules
- Scan docs, skills, and agent definitions for duplicated or conflicting guidance.
- Report exact file/section pairs that overlap; recommend a single canonical home
  and links from the rest.
- Prefer linking over copying; flag drift between vendored `.agents/.skills/*` and
  the trunk versions.

## When triggered (`end_of_plan` / `end_of_execution`)
- Emit a dedup report: duplicate/conflict pairs, the proposed canonical source,
  and the merge/redirect actions.

## Inputs
- Docs/skills/agent definitions, task context, orchestration/lifecycle context

## Outputs
- A dedup report with canonical-source decisions and redirect actions
