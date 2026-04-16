import io
import json
import pathlib
import sys
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from tradingpatternbot.analyze import compute_alternation_metrics
from tradingpatternbot.analyze import validate_trades


class TestAnalyze(unittest.TestCase):
    def test_validate_trades_normalizes(self):
        trades = [{"side": "BUY", "price": 100}]
        validated = validate_trades(trades)
        self.assertEqual(validated, [{"side": "buy", "price": 100.0}])

    def test_strict_alternation_true(self):
        trades = [
            {"side": "buy", "price": 100},
            {"side": "sell", "price": 101},
            {"side": "buy", "price": 102},
            {"side": "sell", "price": 103},
        ]
        metrics = compute_alternation_metrics(trades)
        self.assertTrue(metrics["strict_alternation"])
        self.assertEqual(metrics["alternation_count"], 3)

    def test_strict_alternation_false(self):
        trades = [
            {"side": "buy", "price": 100},
            {"side": "buy", "price": 101},
            {"side": "sell", "price": 102},
        ]
        metrics = compute_alternation_metrics(trades)
        self.assertFalse(metrics["strict_alternation"])
        self.assertEqual(metrics["alternation_count"], 1)

    def test_cli_like_flow(self):
        # Validates the file->compute path (CLI uses the same compute function).
        trades = [{"side": "buy", "price": 100}, {"side": "sell", "price": 101}]
        with tempfile.TemporaryDirectory() as td:
            td_path = pathlib.Path(td)
            input_path = td_path / "trades.json"
            input_path.write_text(json.dumps(trades), encoding="utf-8")

            from tradingpatternbot.analyze import main

            # Capture stdout by temporarily replacing sys.stdout.
            old_stdout = sys.stdout
            try:
                sys.stdout = io.StringIO()
                rc = main(["--input", str(input_path)])
                self.assertEqual(rc, 0)
                out = sys.stdout.getvalue().strip()
            finally:
                sys.stdout = old_stdout

            metrics = json.loads(out)
            self.assertEqual(metrics["trade_count"], 2)
            self.assertTrue(metrics["strict_alternation"])


if __name__ == "__main__":
    unittest.main()

