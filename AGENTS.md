# Agent Guidance (Spec Kit)

This repo uses [GitHub Spec Kit](https://github.com/github/spec-kit) to ensure changes follow a
spec-driven workflow instead of ad-hoc edits.

## Spec -> Plan -> Tasks workflow (required)

For any non-trivial change (feature, bugfix, or documentation update):

1. Read the governing principles:
   - `.specify/memory/constitution.md`
2. Identify (or create) the initiative spec:
   - Spec: `.specify/specs/<FeatureId>/spec.md`
3. Generate (or update) the implementation plan:
   - Plan: `.specify/specs/<FeatureId>/plan.md`
4. Generate (or update) tasks:
   - Tasks: `.specify/specs/<FeatureId>/tasks.md`
5. Execute tasks via Spec Kit:
   - `/speckit-implement`
6. If you discover requirement drift, update artifacts and re-run the relevant phase.

## FeatureId (linking contract)

All spec/plan/task artifacts for an initiative must share the same `FeatureId`:

- `NNN-kebab-case-short-name`

Spec Kit writes:

- `.specify/specs/<FeatureId>/spec.md`
- `.specify/specs/<FeatureId>/plan.md`
- `.specify/specs/<FeatureId>/tasks.md`

## Documentation changes are first-class

Treat documentation like code:

- Write a spec that describes the documentation change and acceptance criteria
- Generate a plan and tasks from that spec
- Implement docs changes during `/speckit-implement`

## Good agent habits

- Do not make "one-off" edits that are not covered by `tasks.md`.
- Prefer small, verifiable steps and keep tasks tightly scoped to file paths.
- When a task is done, ensure it is reflected in the Spec Kit artifacts (no phantom [X] checkmarks).

