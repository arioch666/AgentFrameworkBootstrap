# Spec Kit Workflow Rule

When working in this repository:

- Follow the `spec -> plan -> tasks -> implement` lifecycle for any meaningful change.
- Use the artifacts under `.specify/` as the source of truth.
- Ensure documentation updates are represented as a spec initiative (not an afterthought).

**First time with Spec Kit?** Follow [`docs/speckit-onboarding.md`](../../docs/speckit-onboarding.md) and execute [`.specify/templates/commands/onboarding.md`](../../.specify/templates/commands/onboarding.md) (any AI provider).

If you are unsure what to do next, start from:

1. `.specify/memory/constitution.md`
2. `.specify/specs/<FeatureId>/spec.md`
3. `.specify/specs/<FeatureId>/plan.md`
4. `.specify/specs/<FeatureId>/tasks.md`

## Project memory

Record durable, shareable context in [`ai/memory/memory.md`](../../ai/memory/memory.md). Prefer repo-local memory over device-local vendor memory for facts that belong in git.
