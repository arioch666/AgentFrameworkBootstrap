# Docs

- `docs/agents-framework.md` - architecture, routing, triggers, and continuity model for `.agents`.
- `docs/agent-lifecycle-examples.md` - example execution patterns for planning, quota pause/resume, and end-of-run reviews.
- `docs/language-branch-strategy.md` - trunk-first branching and rebase model for language/platform agent packs.
- `docs/downstream-import-contract.md` - how other projects consume this framework and extend `agents.yml`.
- `docs/afb-init.md` - `afb_init` / `afb_bootstrap` (one-time copy + commit; agents, Spec Kit scaffold, canonical memory; optional GitHub zip download).
- `docs/speckit-onboarding.md` - first-time Spec Kit tutorial (`speckit-onboarding` command; any AI provider).
- `docs/framework-legacy-references.md` - remaining legacy naming to clean in a follow-up sweep.
- `docs/releases.md` - tag naming, GitHub Releases expectations, and consumer-facing upgrade notes.
- `docs/release-notes/README.md` - copy/paste release note templates for GitHub Releases.
- `docs/open-source-readiness.md` - future release-readiness checklist and documentation plan.

## Spec Kit Structure

Spec Kit generated artifacts live under:

- `.specify/memory/` (project constitution)
- `.specify/specs/<FeatureId>/spec.md` (functional spec)
- `.specify/specs/<FeatureId>/plan.md` (technical plan)
- `.specify/specs/<FeatureId>/tasks.md` (actionable tasks)

The `docs/` directory remains a human-friendly index + conventions layer:

- [Conventions](./conventions.md)
- [Specs Index](./specs/README.md)
- [Plans Index](./plans/README.md)
- [Tasks Index](./tasks/README.md)
- [Spec Kit Workflow Example](./examples/spec-kit-workflow-example.md)
