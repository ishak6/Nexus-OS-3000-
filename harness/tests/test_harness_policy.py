import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "harness" / "policy" / "validate_manifest.py"
SPEC = importlib.util.spec_from_file_location("validate_manifest", SOURCE)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


def valid_manifest():
    return {
        "schema_version": 1, "id": "sample-hello",
        "name": "Sample Hello App", "version": "1.0.0",
        "capabilities": [],
        "execution": {"auto_execute": False, "sandbox_required": True, "privileged": False},
    }


class HarnessManifestTests(unittest.TestCase):
    def test_valid_manifest(self):
        self.assertEqual(MODULE.validate(valid_manifest()), [])

    def test_auto_execution_rejected(self):
        item = valid_manifest()
        item["execution"]["auto_execute"] = True
        self.assertTrue(any("auto_execute" in e for e in MODULE.validate(item)))

    def test_privileged_execution_rejected(self):
        item = valid_manifest()
        item["execution"]["privileged"] = True
        self.assertTrue(any("privileged" in e for e in MODULE.validate(item)))

    def test_unknown_capability_rejected(self):
        item = valid_manifest()
        item["capabilities"] = ["system.root"]
        self.assertTrue(any("unsupported capability" in e for e in MODULE.validate(item)))

    def test_duplicate_capability_rejected(self):
        item = valid_manifest()
        item["capabilities"] = ["network.client", "network.client"]
        self.assertTrue(any("unique" in e for e in MODULE.validate(item)))

    def test_unknown_fields_rejected(self):
        item = valid_manifest()
        item["silent_mode"] = True
        self.assertTrue(any("unknown top-level" in e for e in MODULE.validate(item)))


if __name__ == "__main__":
    unittest.main()
