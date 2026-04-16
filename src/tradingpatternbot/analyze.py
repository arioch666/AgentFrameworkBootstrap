from __future__ import annotations

import argparse
import json
from typing import Any


ALLOWED_SIDES = {"buy", "sell"}


def validate_trades(trades: Any) -> list[dict[str, Any]]:
    """
    Validate the input trades structure.

    Expected format:
      [
        {"side": "buy"|"sell", "price": <number>},
        ...
      ]
    """

    if not isinstance(trades, list):
        raise ValueError("trades must be a JSON array (list)")

    validated: list[dict[str, Any]] = []
    for i, trade in enumerate(trades):
        if not isinstance(trade, dict):
            raise ValueError(f"trade[{i}] must be an object")

        side = trade.get("side")
        price = trade.get("price")

        if not isinstance(side, str):
            raise ValueError(f"trade[{i}].side must be a string")
        side_norm = side.strip().lower()
        if side_norm not in ALLOWED_SIDES:
            raise ValueError(f"trade[{i}].side must be one of {sorted(ALLOWED_SIDES)}")

        if not isinstance(price, (int, float)) or isinstance(price, bool):
            raise ValueError(f"trade[{i}].price must be a number")

        validated.append({"side": side_norm, "price": float(price)})

    return validated


def _longest_alternation_run(sides: list[str]) -> int:
    """
    Longest contiguous run where adjacent items alternate (no repeated side).
    Example: buy, sell, buy, buy => run lengths: 3
    """

    if not sides:
        return 0
    if len(sides) == 1:
        return 1

    best = 1
    current = 1
    for i in range(1, len(sides)):
        if sides[i] != sides[i - 1]:
            current += 1
        else:
            best = max(best, current)
            current = 1
    best = max(best, current)
    return best


def compute_alternation_metrics(trades: Any) -> dict[str, Any]:
    """
    Compute alternation metrics for a sequence of validated trades.
    Input is validated internally to keep the public surface small.
    """

    validated = validate_trades(trades)
    sides = [t["side"] for t in validated]

    n = len(sides)
    if n < 2:
        alternations = 0
        strict_alternation = True
        longest_run = n
    else:
        alternations = sum(1 for i in range(1, n) if sides[i] != sides[i - 1])
        strict_alternation = alternations == n - 1
        longest_run = _longest_alternation_run(sides)

    return {
        "trade_count": n,
        "alternation_count": alternations,
        "strict_alternation": strict_alternation,
        "longest_alternation_run": longest_run,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Trading Pattern Analyzer (reference initiative)")
    parser.add_argument("--input", required=True, help="Path to JSON file containing an array of trades")
    parser.add_argument("--output", required=False, help="Path to write JSON metrics (defaults to stdout)")

    args = parser.parse_args(argv)

    with open(args.input, "r", encoding="utf-8") as f:
        trades = json.load(f)

    metrics = compute_alternation_metrics(trades)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(metrics, f, indent=2, sort_keys=True)
    else:
        print(json.dumps(metrics, indent=2, sort_keys=True))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

