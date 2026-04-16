# `pack-python-v0.1.0` (branch: `python`)

## Summary

Initial pinned release for the **Python** language agent pack layered on top of the trunk framework.

## Prerequisite

Vendor the trunk framework from `develop` using a `framework-v*` tag (start with `framework-v0.1.0` unless superseded).

## What to copy into a downstream project (Python pack)

From the tagged `python` commit:

- `docs/python-agent-pack.md` (human overview)
- Python advisor agents:
  - `.agents/python-architecture-advisor/`
  - `.agents/python-testing-and-test-writing-advisor/`
  - `.agents/python-debugging-advisor/`
  - `.agents/python-data-fixtures-advisor/`
  - `.agents/python-project-layout-advisor/`
- Python skills:
  - `.agents/.skills/python-architecture-guidance.md`
  - `.agents/.skills/python-testing-test-writing-guidance.md`
  - `.agents/.skills/python-debugging-guidance.md`
  - `.agents/.skills/python-data-fixtures-guidance.md`
  - `.agents/.skills/python-project-layout-guidance.md`

## Registry merge checklist

Merge into your project `agents.yml`:

- append Python agent entries under `agents:`
- append Python agent ids under `delegation_matrix.orchestration.can_delegate_to`

## GitHub Release (paste)

Title: `pack-python-v0.1.0`

Body:

- Initial Python language advisor pack scaffolding (agents + skills).
- Includes README integration steps for manual vendoring on branch `python`.
