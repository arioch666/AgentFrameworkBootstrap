---
description: "Task list template for feature implementation (reference initiative)"
---

# Tasks: Trading Pattern Analyzer

**Input**: Design documents from `.specify/specs/001-trading-pattern-analyzer/`
**Prerequisites**: plan.md (required), spec.md (required)
**Tests**: This initiative includes small unit tests (stdlib only).

## Phase 1: Setup (Shared Infrastructure)

### Purpose

Project initialization and basic structure for tests + source code.

- [ ] T001 Create `src/tradingpatternbot/` package structure (`__init__.py`)
- [ ] T002 Create `tests/` folder and `tests/test_analyze.py` test module

---

## Phase 2: Foundational (Blocking Prerequisites)

### Purpose

Implement core JSON validation + alternation metrics.

- [ ] T003 Implement `validate_trades(trades)` in `src/tradingpatternbot/analyze.py`
- [ ] T004 Implement `compute_alternation_metrics(trades)` in `src/tradingpatternbot/analyze.py`

---

## Phase 3: User Story 1 - Compute alternation metrics (Priority: P1) 🎯 MVP

### Goal

Expose metrics as a callable function and a small CLI that outputs JSON.

- [ ] T005 Implement `main(argv=None)` CLI in `src/tradingpatternbot/analyze.py`
- [ ] T006 Write unit tests for validation + metric correctness in `tests/test_analyze.py`
- [ ] T007 Ensure CLI accepts an input JSON file and prints JSON output

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T008 Add/adjust repository-level README or docs link only if needed (no ad-hoc docs)

