#!/usr/bin/env python3
"""Crop the top rows of a QEMU P6 PPM screenshot for desktop-panel OCR."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def read_token(stream) -> str:
    """Read one ASCII PPM header token, including comment handling."""
    while True:
        char = stream.read(1)
        if not char:
            raise ValueError("unexpected end of file in PPM header")
        if char == b"#":
            stream.readline()
            continue
        if char in b" \t\r\n\v\f":
            continue
        break

    token = bytearray(char)
    while True:
        char = stream.read(1)
        if not char:
            break
        if char in b" \t\r\n\v\f":
            if char == b"\r":
                following = stream.read(1)
                if following != b"\n" and following:
                    stream.seek(-1, 1)
            break
        if char == b"#":
            stream.readline()
            break
        token.extend(char)
    return token.decode("ascii")


def crop_top_panel(source: Path, destination: Path, requested_height: int) -> None:
    if requested_height < 1:
        raise ValueError("crop height must be at least 1")

    with source.open("rb") as stream:
        magic = read_token(stream)
        width = int(read_token(stream))
        height = int(read_token(stream))
        maximum = int(read_token(stream))
        pixels = stream.read()

    if magic != "P6":
        raise ValueError(f"expected binary P6 PPM, got {magic!r}")
    if width < 1 or height < 1:
        raise ValueError(f"invalid PPM dimensions: {width}x{height}")
    if maximum != 255:
        raise ValueError(f"expected 8-bit PPM samples (maxval 255), got {maximum}")

    expected_bytes = width * height * 3
    if len(pixels) != expected_bytes:
        raise ValueError(
            f"invalid PPM raster size: expected {expected_bytes} bytes, got {len(pixels)}"
        )

    crop_height = min(height, requested_height)
    crop_bytes = width * crop_height * 3
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("wb") as stream:
        stream.write(f"P6\n{width} {crop_height}\n255\n".encode("ascii"))
        stream.write(pixels[:crop_bytes])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument("height", type=int, nargs="?", default=64)
    args = parser.parse_args()

    try:
        crop_top_panel(args.source, args.destination, args.height)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"PPM crop failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
