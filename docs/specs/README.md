# Specs Index

This directory is an index for functional specifications created via Spec Kit.

Authoritative spec artifacts are stored here:

- `.specify/specs/<FeatureId>/spec.md`

For each initiative, follow the naming convention described in [`../conventions.md`](../conventions.md).

## Adding a new spec

1. Decide your `FeatureId` (shared across spec/plan/tasks).
2. Ask the Spec Kit-capable agent to run:
   - `/speckit-constitution` (only if governance/principles changed)
   - `/speckit-specify` to generate the initial `spec.md`
3. Review the produced `spec.md` for:
   - user stories / requirements clarity
   - explicit acceptance criteria
   - any missing assumptions

