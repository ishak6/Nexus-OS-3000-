import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "harness" / "inspection" / "inspect_archive.py"
SPEC = importlib.util.spec_from_file_location("inspect_archive", SOURCE)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


class ArchiveInspectorTests(unittest.TestCase):
    def test_safe_zip_is_reported_without_execution(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "safe.zip"
            with zipfile.ZipFile(path, "w") as archive:
                archive.writestr("docs/readme.txt", "hello")
            report = MODULE.inspect(path)
            self.assertEqual(report["decision"], "NO_STATIC_RED_FLAGS")
            self.assertFalse(report["execution_performed"])
            self.assertFalse(report["extraction_performed"])

    def test_parent_traversal_is_flagged(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "unsafe.zip"
            with zipfile.ZipFile(path, "w") as archive:
                archive.writestr("../escape.txt", "not extracted")
            report = MODULE.inspect(path)
            self.assertEqual(report["decision"], "REVIEW_REQUIRED")
            self.assertTrue(any("unsafe path" in item for item in report["findings"]))

    def test_absolute_path_is_unsafe(self):
        self.assertTrue(MODULE.unsafe_path("/etc/passwd"))

    def test_windows_drive_path_is_unsafe(self):
        self.assertTrue(MODULE.unsafe_path("C:\\Windows\\system.ini"))

    def test_parent_component_is_unsafe(self):
        self.assertTrue(MODULE.unsafe_path("folder/../outside"))


if __name__ == "__main__":
    unittest.main()
