# Docs Structure (Spec Kit)

This repository uses [GitHub Spec Kit](https://github.com/github/spec-kit) for spec-driven development.

Spec Kit writes the generated artifacts into:

- `.specify/memory/` (project constitution)
- `.specify/specs/<FeatureId>/spec.md` (functional spec)
- `.specify/specs/<FeatureId>/plan.md` (technical plan)
- `.specify/specs/<FeatureId>/tasks.md` (actionable tasks)

The `docs/` directory is a human-friendly index + conventions layer that points back to the authoritative `.specify/` files.

- [Conventions](./conventions.md)
- [Specs Index](./specs/README.md)
- [Plans Index](./plans/README.md)
- [Tasks Index](./tasks/README.md)
- [Spec Kit Workflow Example](./examples/spec-kit-workflow-example.md)

