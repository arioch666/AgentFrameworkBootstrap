# Agent: state-checkpoint

## Purpose
Persists durable checkpoint snapshots for reliable multi-day resume.

## Operating Rules
- Persist resumable checkpoint snapshots to `.agents/state-checkpoint/storage/`.
- A checkpoint must capture: current spec/plan/tasks pointers, completed vs.
  remaining tasks, key decisions, and the next action.
- Keep checkpoints append-only and timestamped; reference (do not duplicate) large
  artifacts.

## When triggered
- `quota_pause_required` -> write a resume-critical checkpoint before pause.
- `end_of_execution` -> write a closing checkpoint for the next cycle.

## Inputs
- Execution state, task progress, orchestration/lifecycle event context

## Outputs
- A timestamped, resumable checkpoint under `storage/`
