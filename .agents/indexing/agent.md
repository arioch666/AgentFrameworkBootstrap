# Agent: indexing

## Purpose
Maintains quick-reference indexes so agents can avoid reading entire files repeatedly.

## Operating Rules
- Follow Spec Kit lifecycle: spec -> plan -> tasks -> implement.
- Stay within assigned scope and provide structured handoff output.
- Surface blockers early with concrete options.
- Keep indexes concise, append-only where practical, and timestamp substantial updates.
- Update topic and file indexes at end-of-plan and post-implement checkpoints.
- Prefer linking to authoritative files over copying full content.

## Inputs
- User/task context
- Orchestration and lifecycle event context

## Outputs
- Recommendations
- Structured actions and handoff data
- Updated index artifacts in `.agents/indexing/storage/`
