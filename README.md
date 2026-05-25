# AgentFrameworkBootstrap

AgentFrameworkBootstrap provides a language-agnostic, platform-agnostic,
Spec Kit-aligned multi-agent framework for planning and delivery. Downstream
projects adopt the registry and markdown assets to standardize agent workflows,
delegation, continuity, and Spec Kit governance.

## What This Repo Contains

- A hybrid agent system for Cursor/Gemini/GPT-style workflows
- Shared routing and delegation in `agents.yml`
- Per-agent definitions under `.agents/`
- Agent memory and optional storage for long-running continuity
- Documentation for architecture, lifecycle, onboarding, branching, import, and future open-source readiness

## Agent Framework Layout

- Global registry: `agents.yml`
- Per-agent machine config: `.agents/<agent-name>/agent.yml`
- Per-agent behavior instructions: `.agents/<agent-name>/agent.md`
- Per-agent memory: `.agents/<agent-name>/.memory/memory.md`
- Optional per-agent storage: `.agents/<agent-name>/storage/`
- Shared reusable skills: `.agents/.skills/*.md`

## How Work Gets Done (Spec Kit)

This repo uses [GitHub Spec Kit](https://github.com/github/spec-kit) to drive all meaningful changes (code and documentation) through the same lifecycle:

1. Establish governance/principles (only when needed)
   - `.specify/memory/constitution.md`
2. Create/update the initiative spec
   - `.specify/specs/<FeatureId>/spec.md`
3. Generate/update a technical plan
   - `.specify/specs/<FeatureId>/plan.md`
4. Generate/update actionable tasks
   - `.specify/specs/<FeatureId>/tasks.md`
5. Execute tasks
   - `/speckit-implement`

All initiative artifacts should use the same `FeatureId` (`NNN-kebab-case-short-name`).

## Current Agent Capabilities

- Core workflow agents: orchestration, planning, parallelization, observer, indexing
- Governance/quality agents: compliance-guard, quality-gate, deduplication-observer
- Continuity agents: quota-monitor, scheduler, continuity-coordinator, state-checkpoint, heartbeat-watchdog
- Evolution agents: architecture-advisor, agent-factory, speckit-best-practices
- Onboarding agents: onboarding

## Start Here

- `AGENTS.md`
- `docs/README.md`
- `docs/agents-framework.md`
- `docs/agent-lifecycle-examples.md`
- `docs/language-branch-strategy.md`
- `docs/downstream-import-contract.md`
- `docs/releases.md`
- `docs/open-source-readiness.md`

## Hybrid adoption model (template + vendoring)

This repo is intentionally **not a runtime library** (no package import). Downstream projects adopt it by **copying markdown assets** (`.agents/`, `.agents/.skills/`, and merging `agents.yml`).

We support a **hybrid** adoption path:

- **Greenfield / new repo (optional accelerator)**: use GitHub **Template repository** settings on this repo so users can click **Use this template** to bootstrap a new repository with the folder structure.
  - Templates are a **one-time scaffold**. Upgrades still require copying/merging updated files from a pinned trunk version (see `docs/releases.md`).
- **Brownfield / existing repo (canonical path)**: **manual vendoring** (copy files + additive YAML merges), pinned to a **tag** (recommended) or a commit SHA.

Read the full contract and merge rules in `docs/downstream-import-contract.md` and the release/tag playbook in `docs/releases.md`.

### Scripted bootstrap (`afb_init`)

Use **`afb_init`** once (or when you deliberately refresh) to vendor trunk (and optional pack checkouts) into a downstream repo: `.agents/`, additive `agents.yml` merge, Spec Kit scaffold when `.specify/` is missing, optional `.cursor/` rules/skills, and **`ai/memory/memory.md`** as canonical memory. **Commit those files** and work only in your repo afterward; rerun `afb_init` only when you want to merge upstream changes again.

There is **no npm/PyPI/Maven package** for this flow: obtain a **pinned tag** (clone or zip), run `scripts/afb_init.ps1` against your project root, then **one-time copy + commit** — or run **`scripts/afb_bootstrap.ps1`** to download the tagged release archives from GitHub and invoke `afb_init` for you ([`docs/afb-init.md`](docs/afb-init.md#download-release-zip--run-afb_bootstrapps1)). A Git submodule or build task is **optional** convenience, not required.

### Manual integration (recommended)

1. Pick a **pinned trunk version** from `develop` (prefer a `framework-v*` tag; see `docs/releases.md`).
2. Copy the trunk framework assets into your project:
   - `.agents/` (shared agents + skills)
   - `agents.yml` (merge into your project registry; prefer additive merges)
   - (optional) `AGENTS.md` and relevant `docs/` pages
3. If you need a language/platform pack, pick a **pinned pack version** from the corresponding branch (`kotlin`, `python`, `android`, `kmp`) and copy:
   - `.agents/<pack-agent-id>/`
   - `.agents/.skills/<pack-skill-*.md>`
4. Merge pack additions into your `agents.yml`:
   - append pack agent entries under `agents:`
   - append pack agent ids under `delegation_matrix.orchestration.can_delegate_to`
5. Keep Spec Kit artifacts local to your project under `.specify/` (this framework does not replace your project specs).

### When to choose template vs manual vendoring

- Choose **template** when you are creating a **new** repo and want the baseline structure immediately.
- Choose **manual vendoring** when you already have a repo, or when you want **selective** adoption (only some agents/skills).

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

### 1.5) Onboard To The Framework

**New to Spec Kit?** Run the guided tutorial: [`docs/speckit-onboarding.md`](docs/speckit-onboarding.md) (command file: `.specify/templates/commands/onboarding.md`). Works with any AI assistant; lab work stays off `develop`.

Use the framework onboarding materials when you need agents and docs:

1. Read `docs/README.md`
2. Read `docs/agents-framework.md`
3. Read `docs/agent-lifecycle-examples.md`
4. Read `docs/downstream-import-contract.md`
5. Use the onboarding agent prompts in `.agents/onboarding/agent.md`

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

## Branch Model

`develop` is the agnostic trunk. Language/platform-specific agent packs should be
branched from this trunk and rebased from it regularly:

- `kotlin`
- `android`
- `kmp`
- `python`

Those branches should contain only language/platform-specific agents and skills,
not runtime project code or framework dependencies.
