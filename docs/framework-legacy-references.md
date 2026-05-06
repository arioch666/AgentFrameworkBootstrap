# Framework legacy references (Phase 1b sweep)

Phase 1 (docs/metadata) updated the primary framework identity in `agents.yml` and related docs. The following paths still contain **legacy** `tradingpattern` / `TradingPattern` naming or example feature IDs from the old domain. They are candidates for a follow-up rename or neutral examples—without breaking historical Spec Kit paths unless you intentionally migrate artifacts.

| Area | Path | Notes |
|------|------|--------|
| Python package | `src/tradingpatternbot/` | Package name and imports |
| Tests | `tests/test_analyze.py` | Imports `tradingpatternbot.*` |
| Spec Kit example | `.specify/specs/001-trading-pattern-analyzer/*` | Full example initiative tree |
| Spec Kit example | `.specify/specs/002-spec-kit-docs-example/*` | References `001-trading-pattern-analyzer` |
| Docs | `docs/examples/spec-kit-workflow-example.md` | Example paths use `001-trading-pattern-analyzer` |

Use `rg -i tradingpattern` or `rg -i trading.pattern` before Phase 1b to refresh this list.
