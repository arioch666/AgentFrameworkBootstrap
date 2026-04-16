# tradingpatternbot

Identify patterns in trading activity.

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

The `docs/` folder is a human-friendly index and convention layer:

- `docs/README.md`
- `docs/conventions.md`
- `AGENTS.md`

## Cursor integration

After running `specify init` with Cursor support, the Spec Kit agent skills are installed under `.cursor/skills/`.

When you are using the Cursor agent in this repo, start from:

- `AGENTS.md`
- `.specify/memory/constitution.md`

Then use the `/speckit-*` commands for each initiative.

## FeatureId naming contract

All artifacts for an initiative must share the same `FeatureId`:

`NNN-kebab-case-short-name`

Spec Kit writes:

- `.specify/specs/<FeatureId>/spec.md`
- `.specify/specs/<FeatureId>/plan.md`
- `.specify/specs/<FeatureId>/tasks.md`

