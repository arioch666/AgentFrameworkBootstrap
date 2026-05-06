# Releases (tags + GitHub Releases)

This repository ships **framework assets** (mostly markdown under `.agents/` plus `agents.yml`). Releases exist to give downstream consumers a **stable pin** for copying/vendoring files.

Consumers may run **`afb_init`** from a pinned checkout to automate that vendoring flow; see `docs/afb-init.md`.

## What gets released

- **Trunk (`develop`)**: the language/platform-agnostic framework contract and shared agents/skills.
- **Language pack branches** (`kotlin`, `python`, `android`, `kmp`): optional ecosystem-specific advisor agents and skills layered on top of trunk.

Trunk and packs are versioned **independently**.

## Tag naming convention

Use SemVer tags with explicit prefixes:

- **Trunk**: `framework-vMAJOR.MINOR.PATCH` (created from `develop`)
- **Kotlin pack**: `pack-kotlin-vMAJOR.MINOR.PATCH` (created from `kotlin`)
- **Python pack**: `pack-python-vMAJOR.MINOR.PATCH` (created from `python`)
- **Android pack**: `pack-android-vMAJOR.MINOR.PATCH` (created from `android`)
- **KMP pack**: `pack-kmp-vMAJOR.MINOR.PATCH` (created from `kmp`)

Tags should point to commits that are **rebased/merged onto the latest trunk policy** whenever practical (pack branches should track `develop` regularly; see `docs/language-branch-strategy.md`).

## Published pins (initial)

These tags exist to pin the first documented hybrid adoption + pack README integration workflow:

- `framework-v0.1.0` on `develop`
- `pack-kotlin-v0.1.0` on `kotlin`
- `pack-python-v0.1.0` on `python`
- `pack-android-v0.1.0` on `android`
- `pack-kmp-v0.1.0` on `kmp`

Copy/paste release note templates live under `docs/release-notes/` (start at `docs/release-notes/README.md`).

Note: during early adoption iterations, tags may be **force-updated** to keep `v0.1.0` aligned with the branch tips that include the README + release-notes templates. Prefer pinning the **peeled commit SHA** (`git rev-parse <tag>^{}`) in downstream repos if you want immutability even if a tag moves.

## GitHub Releases policy

For each tag:

- Create a **GitHub Release** from the tag (even if there are no binary assets).
- Write release notes for **downstream consumers**, not maintainers:
  - what changed in `agents.yml` (especially breaking routing/delegation changes)
  - which `.agents/` folders/skills were added/changed/removed
  - how to upgrade an existing vendored copy (high-level diff guidance)

## Maintainer release checklist

1. Ensure the branch is up to date with the intended trunk baseline (`develop` for trunk; `develop` merged/rebased into pack branches for packs).
2. Confirm docs are accurate for adoption (`README.md`, `docs/downstream-import-contract.md`).
3. Draft consumer-facing notes (start from `docs/release-notes/` templates when available).
4. Choose the next SemVer version:
   - **MAJOR**: breaking contract changes (agent id renames, routing ownership changes, incompatible `agents.yml` schema expectations)
   - **MINOR**: additive agents/skills, new delegation targets, new docs capabilities
   - **PATCH**: clarifications, non-breaking fixes, small skill text tweaks
5. Create an annotated tag on the correct branch tip:
   - `git tag -a framework-vX.Y.Z -m "framework vX.Y.Z"`
   - `git tag -a pack-kotlin-vX.Y.Z -m "kotlin pack vX.Y.Z"` (example)
6. Push tags: `git push origin <tagname>`
7. Create the GitHub Release from the tag and paste consumer-facing notes.

## Relationship to `agents.yml` `version:` field

The `version:` field in `agents.yml` is part of the contract surface area. When you ship a **MAJOR** framework release, consider bumping `agents.yml` `version:` in the same release (document the mapping in the GitHub Release notes).
