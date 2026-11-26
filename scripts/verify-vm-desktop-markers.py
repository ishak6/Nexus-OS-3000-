#!/usr/bin/env python3
"""Validate OCR evidence for XFCE and visible Nexus LUMEN workspace content."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def verify(desktop_text: str, panel_text: str, lumen_text: str) -> list[str]:
    """Return missing evidence markers; an empty list means the screen is verified."""
    missing: list[str] = []
    panel = panel_text.casefold()
    combined = (desktop_text + "\n" + lumen_text).casefold()

    if not re.search(r"\bapplications\b|\bwhisker menu\b", panel):
        missing.append("XFCE top-panel Applications/Whisker menu")
    if "debian live user" not in panel:
        missing.append("XFCE panel Debian Live user indicator")
    if "nexus lumen" not in combined:
        missing.append("Nexus LUMEN window title")
    content_markers = ("a calmer space", "cpu load", "nexus os 3000")
    found = [marker for marker in content_markers if marker in combined]
    if len(found) < 2:
        missing.append("at least two visible LUMEN workspace/card content markers")
    return missing


def main(argv: list[str]) -> int:
    if len(argv) != 4:
        print(
            "Usage: verify-vm-desktop-markers.py <desktop.txt> <top-panel.txt> <lumen-window.txt>",
            file=sys.stderr,
        )
        return 2
    try:
        texts = [Path(path).read_text(encoding="utf-8", errors="replace") for path in argv[1:]]
    except OSError as error:
        print(f"Could not read VM OCR evidence: {error}", file=sys.stderr)
        return 2

    missing = verify(*texts)
    if missing:
        for marker in missing:
            print(f"Missing VM desktop evidence: {marker}", file=sys.stderr)
        return 1
    print("PASS: XFCE panel/live-user markers and visible Nexus LUMEN workspace content detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
