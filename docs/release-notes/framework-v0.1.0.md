# `framework-v0.1.0` (trunk / `develop`)

## Summary

Initial pinned release for the **language/platform-agnostic trunk** after documenting:

- hybrid adoption (GitHub Template + manual vendoring) in `README.md`
- downstream import contract updates in `docs/downstream-import-contract.md`
- releases playbook in `docs/releases.md`

## What to copy into a downstream project (minimum)

From the tagged `develop` commit:

- `.agents/` (shared agents + skills)
- `agents.yml` (merge additively into your project registry)
- (optional) `AGENTS.md`
- (optional) selected `docs/` pages, especially:
  - `docs/downstream-import-contract.md`
  - `docs/releases.md`

## GitHub Release (paste)

Title: `framework-v0.1.0`

Body:

- Documents hybrid adoption (template + manual vendoring) for file-based framework consumption.
- Adds `docs/releases.md` with tag naming + GitHub Releases expectations.
- Extends `docs/downstream-import-contract.md` with pinning/upgrade guidance + merge hotspots.

Consumer upgrade note:

- If you vendored without pinning, pick this tag (or newer `framework-v*`) and diff `.agents/` + `agents.yml` before merging updates.
