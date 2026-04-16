# Spec Kit Workflow Example

This page is a concrete example of how this repo expects work to flow using Spec Kit:

`spec.md -> plan.md -> tasks.md -> /speckit-implement`

## Reference initiative (code feature)

- Specs/Plan/Tasks artifacts:
  - `.specify/specs/001-trading-pattern-analyzer/spec.md`
  - `.specify/specs/001-trading-pattern-analyzer/plan.md`
  - `.specify/specs/001-trading-pattern-analyzer/tasks.md`

## Checklist (how to run an initiative)

1. **Read governing principles**
   - `.specify/memory/constitution.md`

2. **Create or update the initiative spec**
   - `spec.md` is the authoritative "what/why" artifact.
   - Example artifact: `.specify/specs/001-trading-pattern-analyzer/spec.md`

3. **Generate the technical implementation plan**
   - `plan.md` is the authoritative "how/architecture" artifact.
   - Example artifact: `.specify/specs/001-trading-pattern-analyzer/plan.md`

4. **Generate tasks from the plan**
   - `tasks.md` is the authoritative execution checklist.
   - Example artifact: `.specify/specs/001-trading-pattern-analyzer/tasks.md`

5. **Execute tasks**
   - Use your Spec Kit-capable agent to run: `/speckit-implement`
   - Ensure your changes match the file paths listed in `tasks.md`.

6. **Keep artifacts aligned**
   - If implementation reveals missing requirements or drift, update the affected spec(s)/plan(s)/tasks(s) and re-run the relevant phase.

## Documentation changes follow the same pattern

For doc-only changes, treat the documentation update as an initiative:

- Example artifacts:
  - `.specify/specs/002-spec-kit-docs-example/spec.md`
  - `.specify/specs/002-spec-kit-docs-example/plan.md`
  - `.specify/specs/002-spec-kit-docs-example/tasks.md`

Then run `/speckit-implement` so the docs changes are produced as part of the tracked task execution (not as an afterthought).

