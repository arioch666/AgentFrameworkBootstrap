# Feature Specification: Trading Pattern Analyzer

**Feature Branch**: `001-trading-pattern-analyzer`
**Created**: 2026-04-16
Status: Draft
Input: User description: "Create a small Python analyzer that reads a list of trades (buy/sell + price) from JSON and outputs alternation metrics."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Compute alternation metrics (Priority: P1)

Users can pass a JSON array of trades (each with `side` = `buy` or `sell` and `price` as a number) to a CLI. The tool returns alternation metrics that capture how strictly consecutive trade sides alternate.

**Why this priority**: This is the smallest end-to-end slice (data validation + core metrics + CLI output) that proves the workflow works.

**Independent Test**: This can be fully tested by running the analyzer function directly in unit tests (and validating CLI output for a single input fixture).

**Acceptance Scenarios**:

1. **Given** a sequence `buy, sell, buy, sell`
   **When** the analyzer runs
   **Then** it reports `strict_alternation = true` and `alternation_count = 3`.

2. **Given** a sequence `buy, buy, sell`
   **When** the analyzer runs
   **Then** it reports `strict_alternation = false` and `alternation_count = 1`.

---
## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST accept input trades as JSON containing an array of objects.
- **FR-002**: Each trade MUST contain `side` (allowed values: `buy`, `sell`) and numeric `price`.
- **FR-003**: The system MUST compute `alternation_count` as the number of index transitions where side changes.
- **FR-004**: The system MUST report `strict_alternation = true` only when side alternates on every consecutive transition.
- **FR-005**: The CLI MUST output results as JSON.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Unit tests cover validation + metric correctness for at least two fixtures.
- **SC-002**: CLI run produces a JSON object containing `alternation_count` and `strict_alternation`.

## Assumptions

- Trade pricing is numeric and already normalized by the caller.
- This initiative implements alternation metrics only (no pairing/PnL calculation yet).

