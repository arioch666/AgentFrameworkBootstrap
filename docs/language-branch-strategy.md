# Language Branch Strategy

## Trunk First

`develop` is the language-agnostic and platform-agnostic trunk for this framework.

It should contain only shared framework concepts such as:

- orchestration
- planning
- indexing
- onboarding
- architecture review
- continuity and quota management
- generic Spec Kit guidance

## Long-Lived Branches

Language/platform-specific agent packs are created from `develop`:

- `kotlin`
- `android`
- `kmp`
- `python`

## What Belongs On Branches

Each language/platform branch should contain:

- specialized agents
- shared and branch-local skills
- branch-specific architecture guidance
- testing, debugging, and data-creation guidance
- optional onboarding supplements for that ecosystem

Each branch should avoid:

- runtime application code
- build dependencies
- SDK installation logic inside the framework

## Rebase Policy

- `develop` is the source of truth.
- Rebase language/platform branches from `develop` regularly.
- Land shared fixes in `develop` first when practical.
- Keep branch-only changes limited to language/platform-specific packs.
