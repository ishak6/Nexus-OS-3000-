#!/usr/bin/env python3
"""Regression tests for XFCE/LUMEN VM OCR marker validation."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts" / "verify-vm-desktop-markers.py"


class VmDesktopMarkerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.desktop = self.root / "desktop.txt"
        self.panel = self.root / "panel.txt"
        self.lumen = self.root / "lumen.txt"

    def run_check(self, desktop: str, panel: str, lumen: str) -> subprocess.CompletedProcess[str]:
        self.desktop.write_text(desktop, encoding="utf-8")
        self.panel.write_text(panel, encoding="utf-8")
        self.lumen.write_text(lumen, encoding="utf-8")
        return subprocess.run(
            [sys.executable, str(CHECKER), str(self.desktop), str(self.panel), str(self.lumen)],
            check=False,
            capture_output=True,
            text=True,
        )

    def test_build_47_ocr_passes_without_uncovered_desktop_icons(self) -> None:
        # Build #47 screenshot: LUMEN covers desktop icons, while XFCE panel
        # and visible workspace/card content remain present.
        desktop = """Nexus LUMEN
NEXUS OS 3000
A calmer space for focused work.
CPU LOAD MEMORY
"""
        panel = "Applications\nDebian Live user\n"
        lumen = "Nexus LUMEN\nOverview\nA calmer space for focused work.\nCPU LOAD\n"
        result = self.run_check(desktop, panel, lumen)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("PASS:", result.stdout)

    def test_rejects_missing_xfce_panel_menu(self) -> None:
        result = self.run_check(
            "Nexus LUMEN\nA calmer space\nCPU LOAD",
            "Debian Live user",
            "Nexus LUMEN\nNEXUS OS 3000",
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("Applications/Whisker menu", result.stderr)

    def test_rejects_missing_live_user_indicator(self) -> None:
        result = self.run_check(
            "Nexus LUMEN\nA calmer space\nCPU LOAD",
            "Applications",
            "Nexus LUMEN\nNEXUS OS 3000",
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("Debian Live user", result.stderr)

    def test_rejects_missing_lumen_title(self) -> None:
        result = self.run_check(
            "A calmer space\nCPU LOAD",
            "Applications\nDebian Live user",
            "NEXUS OS 3000",
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("window title", result.stderr)

    def test_rejects_insufficient_lumen_content(self) -> None:
        result = self.run_check(
            "Nexus LUMEN\nA calmer space",
            "Applications\nDebian Live user",
            "Nexus LUMEN",
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("at least two visible", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
