import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "telemetry.py"
SPEC = importlib.util.spec_from_file_location("pulse_telemetry", SOURCE)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


class PulseTelemetryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.proc = Path(self.tmp.name)
        (self.proc / "net").mkdir()
        (self.proc / "stat").write_text("cpu 100 0 50 850 0 0 0 0 0 0\n", encoding="ascii")
        (self.proc / "meminfo").write_text(
            "MemTotal: 1000 kB\nMemFree: 200 kB\nMemAvailable: 600 kB\n",
            encoding="ascii")
        (self.proc / "net" / "dev").write_text(
            "Inter-| Receive | Transmit\n"
            " face |bytes packets errs drop fifo frame compressed multicast|bytes packets errs drop fifo colls carrier compressed\n"
            " lo: 100 1 0 0 0 0 0 0 200 1 0 0 0 0 0 0\n",
            encoding="ascii")

    def tearDown(self):
        self.tmp.cleanup()

    def test_first_sample_is_explicitly_unknown_for_cpu_delta(self):
        sample = MODULE.ProcTelemetry(self.proc).sample()
        self.assertIsNone(sample["cpu"]["usage_percent_since_previous_sample"])
        self.assertEqual(sample["memory"]["total_bytes"], 1024000)
        self.assertEqual(sample["memory"]["available_bytes"], 614400)
        self.assertTrue(sample["read_only"])

    def test_second_sample_calculates_cpu_and_network_deltas(self):
        sampler = MODULE.ProcTelemetry(self.proc)
        sampler.sample()
        (self.proc / "stat").write_text("cpu 150 0 75 875 0 0 0 0 0 0\n", encoding="ascii")
        (self.proc / "net" / "dev").write_text(
            "Inter-| Receive | Transmit\n"
            " face |bytes packets errs drop fifo frame compressed multicast|bytes packets errs drop fifo colls carrier compressed\n"
            " lo: 150 1 0 0 0 0 0 0 260 1 0 0 0 0 0 0\n",
            encoding="ascii")
        sample = sampler.sample()
        self.assertEqual(sample["cpu"]["usage_percent_since_previous_sample"], 75.0)
        self.assertEqual(sample["network"]["deltas"]["lo"]["rx_bytes_per_interval"], 50)
        self.assertEqual(sample["network"]["deltas"]["lo"]["tx_bytes_per_interval"], 60)


if __name__ == "__main__":
    unittest.main()
