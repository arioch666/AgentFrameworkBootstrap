# Agent: heartbeat-watchdog

## Purpose
Monitors scheduled resumes and escalates missed windows.

## Operating Rules
- Monitor resume windows owned by `scheduler`.
- When a window is missed, escalate: notify the user, request `orchestration`
  retry with backoff (`quota_policy.on_missed_resume`), and ask `scheduler` to set
  the next window.
- Record missed-window events so repeated misses raise severity.

## When triggered (`resume_window_missed`)
- Emit an escalation with the missed window, the cause if known, and the proposed
  retry/backoff schedule.

## Inputs
- Schedule state, missed-window signals, orchestration/lifecycle event context

## Outputs
- An escalation with a retry/backoff recommendation
