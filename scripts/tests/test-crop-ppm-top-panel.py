#!/usr/bin/env python3
"""Regression tests for the QEMU PPM top-panel crop helper."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "scripts" / "crop-ppm-top-panel.py"


class CropPpmTopPanelTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.directory = Path(self.temp_dir.name)
        self.source = self.directory / "source.ppm"
        self.destination = self.directory / "top.ppm"

    def run_helper(self, height: int = 64) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(HELPER), str(self.source), str(self.destination), str(height)],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_crops_requested_rows_and_preserves_rgb_bytes(self) -> None:
        pixels = bytes(range(4 * 3 * 3))
        self.source.write_bytes(b"P6\n4 3\n255\n" + pixels)

        result = self.run_helper(2)

        self.assertEqual(result.returncode, 0, result.stderr)
        output = self.destination.read_bytes()
        header = b"P6\n4 2\n255\n"
        self.assertTrue(output.startswith(header))
        self.assertEqual(output[len(header):], pixels[:4 * 2 * 3])

    def test_crop_height_is_clamped_to_image_height(self) -> None:
        pixels = bytes(range(2 * 2 * 3))
        self.source.write_bytes(b"P6\n2 2\n255\n" + pixels)

        result = self.run_helper(64)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.destination.read_bytes().startswith(b"P6\n2 2\n255\n"))

    def test_rejects_truncated_raster_without_creating_output(self) -> None:
        self.source.write_bytes(b"P6\n4 3\n255\n" + bytes(8))

        result = self.run_helper()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("invalid PPM raster size", result.stderr)
        self.assertFalse(self.destination.exists())

    def test_rejects_ascii_ppm(self) -> None:
        self.source.write_bytes(b"P3\n1 1\n255\n0 0 0\n")

        result = self.run_helper()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expected binary P6 PPM", result.stderr)
        self.assertFalse(self.destination.exists())

    def test_rejects_zero_crop_height(self) -> None:
        self.source.write_bytes(b"P6\n1 1\n255\n" + bytes(3))

        result = self.run_helper(0)

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("crop height must be at least 1", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
