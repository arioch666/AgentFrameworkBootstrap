# Downstream Import Contract

## Purpose

This framework is a reusable library of agents and skills, not an app template.

Downstream projects should be able to adopt only the pieces they need.

## Expected Downstream Workflow

1. Copy or import selected `.agents/` content
2. Copy or import selected `.agents/.skills/` content
3. Create project-local `.specify/`
4. Create project-specific agents or skills as needed
5. Append project-specific entries into `agents.yml`

## Language/Platform Agent Packs

The language/platform agent packs live on dedicated branches:

- `kotlin`
- `python`
- `android`
- `kmp`

Each pack branch is a library extension of the trunk contract (the framework “core” stays language-agnostic on `develop`).
Pack branches add language-specific agent folders under `.agents/<agent-id>/`, language-specific skills under `.agents/.skills/`, and additive registry entries under `agents.yml` so `orchestration` can delegate to the new advisors.

Downstream projects should:

1. Start from the trunk import (the core framework contract).
2. Copy/import only the needed pack content from the selected language branch:
   - `.agents/<lang-specific-agent-id>/`
   - `.agents/.skills/<lang-specific-skill-*.md>`
   - (optionally) the pack’s `docs/<lang>-agent-pack.md` for human guidance
3. Merge the pack’s additions into the project `agents.yml`:
   - append the new `agents:` entries for the copied `.agents/<lang-specific-agent-id>/` folders
   - append the pack’s language advisor ids into `delegation_matrix.orchestration.can_delegate_to`
4. Keep the copied shared skills (for example `.agents/.skills/spec-kit-workflow.md`) consistent with the trunk.

## Rebase / Upgrade Policy

When you update to newer framework versions:
rebase your language-pack working state from `develop` (matching the framework upgrade cadence), then re-run the additive `agents.yml` merge step.

## Registry Extension Rules

The root `agents.yml` defines the shared contract:

- agent ids
- paths
- routing ownership
- delegation matrix
- lifecycle events

A downstream project may append:

- new agent entries under `agents`
- additional routing metadata
- project-local delegation rules
- project-local trigger handling

Downstream projects should avoid mutating shared agent ids unless intentionally overriding them.

## Local Override Pattern

Recommended pattern:

- keep shared framework agents under imported `.agents/`
- define project-specific additions under the local project structure
- extend `agents.yml` with additive entries when possible

## Spec Kit Integration

Downstream projects are expected to create `.specify/` locally and keep project plans/specs/tasks visible there.

This framework provides the agent system around that workflow; it does not replace project-local Spec Kit artifacts.
