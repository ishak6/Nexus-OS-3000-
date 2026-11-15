import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("pulse_system_info", ROOT / "system_info.py")
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)
SystemInfo = MODULE.SystemInfo


class SystemInfoTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.proc = self.root / "proc"
        self.etc = self.root / "etc"
        self.proc.mkdir()
        self.etc.mkdir()
        (self.etc / "os-release").write_text(
            'NAME="Nexus OS 3000"\nPRETTY_NAME="Nexus OS 3000 Development"\n'
            'ID=nexus\nVERSION_ID=0.1\nVERSION_CODENAME=trixie\n',
            encoding="utf-8",
        )
        (self.etc / "hostname").write_text("nexus-test\n", encoding="utf-8")
        (self.proc / "meminfo").write_text(
            "MemTotal:       1024 kB\nMemAvailable:    256 kB\n",
            encoding="ascii",
        )
        (self.proc / "cpuinfo").write_text(
            "processor : 0\nmodel name : Test CPU 9000\n",
            encoding="ascii",
        )
        (self.proc / "uptime").write_text("123.45 100.00\n", encoding="ascii")

    def tearDown(self):
        self.tmp.cleanup()

    def test_collects_os_identity_and_hardware_metadata(self):
        data = SystemInfo(self.proc, self.etc).collect()
        self.assertEqual(data["os"]["name"], "Nexus OS 3000 Development")
        self.assertEqual(data["os"]["id"], "nexus")
        self.assertEqual(data["os"]["codename"], "trixie")
        self.assertEqual(data["host"]["hostname"], "nexus-test")
        self.assertEqual(data["host"]["cpu_model"], "Test CPU 9000")
        self.assertEqual(data["memory"]["total_bytes"], 1024 * 1024)
        self.assertEqual(data["memory"]["available_bytes"], 256 * 1024)
        self.assertEqual(data["memory"]["used_bytes"], 768 * 1024)
        self.assertEqual(data["uptime_seconds"], 123.45)
        self.assertTrue(data["read_only"])
        self.assertEqual(data["schema_version"], 1)

    def test_missing_proc_metadata_is_reported_as_unknown(self):
        (self.proc / "meminfo").unlink()
        (self.proc / "cpuinfo").unlink()
        (self.proc / "uptime").write_text("invalid", encoding="ascii")
        data = SystemInfo(self.proc, self.etc).collect()
        self.assertIsNone(data["memory"]["total_bytes"])
        self.assertIsNone(data["host"]["cpu_model"])
        self.assertIsNone(data["uptime_seconds"])

    def test_output_is_json_serializable(self):
        data = SystemInfo(self.proc, self.etc).collect()
        self.assertIsInstance(json.loads(json.dumps(data)), dict)


if __name__ == "__main__":
    unittest.main()
