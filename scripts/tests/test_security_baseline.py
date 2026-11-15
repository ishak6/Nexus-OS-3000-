#!/usr/bin/env python3
"""Ensure the read-only security audit agrees with the shipped sysctl baseline."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / "config/includes.chroot/etc/sysctl.d/99-nexus-hardening.conf"
AUDIT = ROOT / "scripts/security-audit.sh"
DOC = ROOT / "docs/SECURITY_BASELINE.md"


def assignments(text):
    values = {}
    for line in text.splitlines():
        match = re.match(r"^\s*([A-Za-z0-9_.]+)\s*=\s*(\S+)\s*$", line)
        if match and not line.lstrip().startswith("#"):
            values[match.group(1)] = match.group(2)
    return values


class SecurityBaselineConsistencyTests(unittest.TestCase):
    def test_every_audited_sysctl_matches_the_shipped_configuration(self):
        configured = assignments(CONFIG.read_text(encoding="utf-8"))
        audit = AUDIT.read_text(encoding="utf-8")
        checks = re.findall(r"^check_sysctl\s+([A-Za-z0-9_.]+)\s+(\S+)\s*$", audit, re.M)
        self.assertTrue(checks, "No sysctl checks found in security audit")
        for key, expected in checks:
            with self.subTest(key=key):
                self.assertIn(key, configured, f"{key} is audited but not configured")
                self.assertEqual(expected, configured[key], f"{key} audit expectation differs from shipped config")

    def test_documented_fifos_value_matches_configuration(self):
        configured = assignments(CONFIG.read_text(encoding="utf-8"))
        documented = DOC.read_text(encoding="utf-8")
        self.assertEqual(configured.get("fs.protected_fifos"), "2")
        self.assertIn("fs.protected_fifos", documented)
        self.assertIn("fs.protected_fifos", AUDIT.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
