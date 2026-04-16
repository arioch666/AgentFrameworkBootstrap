# `pack-android-v0.1.0` (branch: `android`)

## Summary

Initial pinned release for the **Android** platform agent pack layered on top of the trunk framework.

## Prerequisite

Vendor the trunk framework from `develop` using a `framework-v*` tag (start with `framework-v0.1.0` unless superseded).

## What to copy into a downstream project (Android pack)

From the tagged `android` commit:

- `docs/android-agent-pack.md` (human overview)
- Android advisor agents:
  - `.agents/android-architecture-advisor/`
  - `.agents/android-testing-and-test-writing-advisor/`
  - `.agents/android-debugging-advisor/`
  - `.agents/android-data-fixtures-advisor/`
  - `.agents/android-best-practices-advisor/`
- Android skills:
  - `.agents/.skills/android-architecture-guidance.md`
  - `.agents/.skills/android-testing-test-writing-guidance.md`
  - `.agents/.skills/android-debugging-guidance.md`
  - `.agents/.skills/android-data-fixtures-guidance.md`
  - `.agents/.skills/android-best-practices-guidance.md`

## Registry merge checklist

Merge into your project `agents.yml`:

- append Android agent entries under `agents:`
- append Android agent ids under `delegation_matrix.orchestration.can_delegate_to`

## GitHub Release (paste)

Title: `pack-android-v0.1.0`

Body:

- Initial Android platform advisor pack scaffolding (agents + skills).
- Includes README integration steps for manual vendoring on branch `android`.
