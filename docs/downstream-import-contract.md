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

## Hybrid adoption (template + vendoring)

Downstream adoption is intentionally **file-based** (markdown + YAML), not a package import.

- **Template repository (optional)**: good for **greenfield** repos that want the baseline structure quickly.
- **Vendoring (canonical)**: copy/merge framework files into an existing project and keep updates under control.

### Pinning strategy (recommended)

Pin versions using **git tags** (see `docs/releases.md`):

- **Trunk pin**: a `framework-v*` tag on `develop`
- **Pack pin** (optional): a `pack-<ecosystem>-v*` tag on the relevant long-lived branch (`kotlin`, `python`, `android`, `kmp`)

When copying files, record the pinned tag(s) in your downstream repo (for example in `AGENTS.md` or an internal `FRAMEWORK_VERSIONS.md`).

### Upgrade strategy

1. Pick a newer trunk tag on `develop` and diff what changed under `.agents/` and `agents.yml`.
2. If you use a language pack, pick a newer pack tag on the pack branch and diff pack-only paths.
3. Re-run additive merges into your project `agents.yml` (avoid accidental duplication).

### Merge conflict hotspots (`agents.yml`)

Watch for:

- duplicate `agents[].id` entries
- duplicated `delegation_matrix.orchestration.can_delegate_to` entries
- accidental edits to shared agent ids you intended to treat as upstream-owned
- drift between copied `.agents/.skills/spec-kit-workflow.md` and newer trunk versions

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
