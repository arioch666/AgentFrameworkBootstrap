# Agent: trigger-monitor

## Purpose
Watches for triggering conditions and routes activation events to orchestration.

## Operating Rules
- Watch for lifecycle/triggering conditions and route activation events to
  `orchestration` (`routing.trigger_ingest_agent` -> `dispatches_to: orchestration`).
- Normalize each event to a `lifecycle_events` value before dispatch.
- On `docs_change` / `drift_detected`, attach the changed paths and a short drift
  summary.

## When triggered (`start_of_plan` / `start_of_execution` / `docs_change` / `drift_detected`)
- Emit a dispatch to `orchestration` naming the event, the affected scope, and
  which trigger-subscribing agents should run.

## Inputs
- Lifecycle/trigger signals, changed paths, orchestration/lifecycle event context

## Outputs
- A normalized dispatch to `orchestration`
