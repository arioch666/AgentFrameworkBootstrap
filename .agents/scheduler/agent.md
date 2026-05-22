# Agent: scheduler

## Purpose
Schedules automatic resume windows and deferred tasks without user intervention.

## Operating Rules
- Schedule resume windows and deferred tasks; persist the schedule to
  `.agents/scheduler/storage/` so it survives sessions.
- On an open window, hand control to `continuity-coordinator` / `orchestration`.
- On a missed window, hand off to `heartbeat-watchdog`
  (`delegation_matrix.scheduler.missed_window_handler`).

## When triggered
- `resume_at_time` / `resume_window_open` -> signal resume and hand off to
  `continuity-coordinator`.
- `resume_window_missed` -> notify `heartbeat-watchdog` and propose the next
  window.

## Inputs
- Continuity mini-plan, resume timing, orchestration/lifecycle event context

## Outputs
- A persisted resume schedule and resume/missed-window signals
