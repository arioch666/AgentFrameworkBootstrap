# `pack-kmp-v0.1.0` (branch: `kmp`)

## Summary

Initial pinned release for the **Kotlin Multiplatform (KMP)** agent pack layered on top of the trunk framework.

## Prerequisite

Vendor the trunk framework from `develop` using a `framework-v*` tag (start with `framework-v0.1.0` unless superseded).

## What to copy into a downstream project (KMP pack)

From the tagged `kmp` commit:

- `docs/kmp-agent-pack.md` (human overview)
- KMP advisor agents:
  - `.agents/kmp-architecture-advisor/`
  - `.agents/kmp-testing-and-test-writing-advisor/`
  - `.agents/kmp-debugging-advisor/`
  - `.agents/kmp-data-fixtures-advisor/`
  - `.agents/kmp-platform-boundary-advisor/`
- KMP skills:
  - `.agents/.skills/kmp-architecture-guidance.md`
  - `.agents/.skills/kmp-testing-test-writing-guidance.md`
  - `.agents/.skills/kmp-debugging-guidance.md`
  - `.agents/.skills/kmp-data-fixtures-guidance.md`
  - `.agents/.skills/kmp-platform-boundary-guidance.md`

## Registry merge checklist

Merge into your project `agents.yml`:

- append KMP agent entries under `agents:`
- append KMP agent ids under `delegation_matrix.orchestration.can_delegate_to`

## GitHub Release (paste)

Title: `pack-kmp-v0.1.0`

Body:

- Initial KMP advisor pack scaffolding (agents + skills).
- Includes README integration steps for manual vendoring on branch `kmp`.
