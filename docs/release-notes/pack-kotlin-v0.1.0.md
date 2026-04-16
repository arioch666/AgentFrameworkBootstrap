# `pack-kotlin-v0.1.0` (branch: `kotlin`)

## Summary

Initial pinned release for the **Kotlin** language agent pack layered on top of the trunk framework.

## Prerequisite

Vendor the trunk framework from `develop` using a `framework-v*` tag (start with `framework-v0.1.0` unless superseded).

## What to copy into a downstream project (Kotlin pack)

From the tagged `kotlin` commit:

- `docs/kotlin-agent-pack.md` (human overview)
- Kotlin advisor agents:
  - `.agents/kotlin-architecture-advisor/`
  - `.agents/kotlin-testing-and-test-writing-advisor/`
  - `.agents/kotlin-debugging-advisor/`
  - `.agents/kotlin-data-fixtures-advisor/`
  - `.agents/kotlin-style-and-packaging-advisor/`
- Kotlin skills:
  - `.agents/.skills/kotlin-architecture-guidance.md`
  - `.agents/.skills/kotlin-testing-test-writing-guidance.md`
  - `.agents/.skills/kotlin-debugging-guidance.md`
  - `.agents/.skills/kotlin-data-fixtures-guidance.md`
  - `.agents/.skills/kotlin-style-packaging-guidance.md`

## Registry merge checklist

Merge into your project `agents.yml`:

- append Kotlin agent entries under `agents:`
- append Kotlin agent ids under `delegation_matrix.orchestration.can_delegate_to`

## GitHub Release (paste)

Title: `pack-kotlin-v0.1.0`

Body:

- Initial Kotlin language advisor pack scaffolding (agents + skills).
- Includes README integration steps for manual vendoring on branch `kotlin`.
