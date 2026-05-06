# Conventions (Spec -> Plan -> Tasks)

## FeatureId naming

Every initiative (feature or documentation change) must use a shared `FeatureId` so links remain stable across spec, plan, and tasks.

Use the format:

`NNN-kebab-case-short-name`

Examples:

- `001-agent-bootstrap-onboarding`
- `002-pattern-signals-api`
- `003-docs-contributor-workflow`

## Where Spec Kit writes artifacts

For an initiative with `FeatureId`:

- Spec: `.specify/specs/<FeatureId>/spec.md`
- Plan: `.specify/specs/<FeatureId>/plan.md`
- Tasks: `.specify/specs/<FeatureId>/tasks.md`

## How to work on an initiative

1. Update your principles (only when governance changes)
   - Constitution: `.specify/memory/constitution.md`
2. Create the spec (what/why + acceptance criteria)
   - `spec.md` lives under `.specify/specs/<FeatureId>/`
3. Generate a technical plan
   - `plan.md` lives under `.specify/specs/<FeatureId>/`
4. Generate tasks from the plan
   - `tasks.md` lives under `.specify/specs/<FeatureId>/`
5. Execute tasks and then reconcile any drift

## Documentation expectations

Because your work includes documentation, treat documentation improvements as first-class initiatives:

- write a spec describing the documentation changes
- generate a plan
- generate tasks
- implement and verify (linking back to the docs/artifacts)

