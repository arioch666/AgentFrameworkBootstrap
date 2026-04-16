# KMP Agent Pack

This branch contains language/platform-specific agent and skill guidance as a library.

## Includes
- Language-specific advisors (see `.agents/<agent-id>/`)
- Language-specific skills (see `.agents/.skills/`)

## Downstream Usage
Downstream projects should:
1. Copy/import the relevant `.agents/` and `.agents/.skills/` content from this branch.
2. Add/merge the language-specific agent entries into the project’s `agents.yml`.
3. Run the normal Spec Kit flow (`spec -> plan -> tasks -> implement`).
4. Let orchestration delegate to these language advisors during planning/execution.

## Branching Policy
This branch should be periodically rebased from `develop` to inherit trunk improvements.
