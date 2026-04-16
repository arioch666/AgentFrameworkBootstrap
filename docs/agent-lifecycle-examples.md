# Agent Lifecycle Examples

## Example: Normal Planning Run

1. `orchestration` receives request
2. `planning` produces plan aligned to Spec Kit flow
3. `planning` appends final `Index Update` task (`indexing` owner)
4. `parallelization` refines execution ordering
5. `observer` and `architecture-advisor` append end-of-run recommendations

## Example: Quota-Constrained Multi-Day Run

1. `quota-monitor` emits `quota_warn_80`
2. `planning` generates continuity mini-plan
3. `state-checkpoint` writes checkpoint snapshot
4. `scheduler` sets resume window
5. execution pauses
6. on refresh, `continuity-coordinator` validates state
7. `orchestration` resumes from checkpoint

## Example: Missed Resume Window

1. `scheduler` emits `resume_window_missed`
2. `heartbeat-watchdog` escalates
3. `orchestration` retries with backoff and publishes status update

