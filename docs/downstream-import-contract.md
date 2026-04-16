# Downstream Import Contract

## Purpose

This framework is a reusable library of agents and skills, not an app template.

Downstream projects should be able to adopt only the pieces they need.

## Expected Downstream Workflow

1. Copy or import selected `.agents/` content
2. Copy or import selected `.agents/.skills/` content
3. Create project-local `.specify/`
4. Create project-specific agents or skills as needed
5. Append project-specific entries into `agents.yml`

## Registry Extension Rules

The root `agents.yml` defines the shared contract:

- agent ids
- paths
- routing ownership
- delegation matrix
- lifecycle events

A downstream project may append:

- new agent entries under `agents`
- additional routing metadata
- project-local delegation rules
- project-local trigger handling

Downstream projects should avoid mutating shared agent ids unless intentionally overriding them.

## Local Override Pattern

Recommended pattern:

- keep shared framework agents under imported `.agents/`
- define project-specific additions under the local project structure
- extend `agents.yml` with additive entries when possible

## Spec Kit Integration

Downstream projects are expected to create `.specify/` locally and keep project plans/specs/tasks visible there.

This framework provides the agent system around that workflow; it does not replace project-local Spec Kit artifacts.
