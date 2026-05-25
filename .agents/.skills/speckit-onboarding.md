# Skill: speckit-onboarding

Use when the user is new to Spec Kit or asks how the `spec -> plan -> tasks -> implement` workflow works in this project.

## Canonical command

Read and execute **every phase** in:

`.specify/templates/commands/onboarding.md`

Do not improvise a shorter tutorial; the command file defines stop gates, the lab FeatureId (`099-speckit-onboarding-lab`), branch naming, sandbox-only edits, and **mandatory cleanup** (lab artifacts must not merge to `develop`).

## Quick invoke (any provider)

Tell the assistant:

> Follow `.specify/templates/commands/onboarding.md` step by step. Use shell commands when available.

## Related

- Human guide: `docs/speckit-onboarding.md`
- Framework/docs onboarding (different topic): `.agents/onboarding/agent.md`
- Workflow example: `docs/examples/spec-kit-workflow-example.md`
