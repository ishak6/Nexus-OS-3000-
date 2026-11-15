#!/usr/bin/env bash
# Copy Debian live-build's GRUB theme and make the default live entry boot
# automatically after a short, visible menu timeout.
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <stock-grub-pc-template-dir> <target-grub-pc-config-dir>" >&2
  exit 2
fi

SOURCE_DIR="$1"
TARGET_DIR="$2"
SOURCE_CONFIG="$SOURCE_DIR/config.cfg"
TARGET_CONFIG="$TARGET_DIR/config.cfg"

if [[ ! -s "$SOURCE_CONFIG" ]]; then
  echo "Missing Debian GRUB template: $SOURCE_CONFIG" >&2
  exit 2
fi

mkdir -p "$TARGET_DIR"
cp -a "$SOURCE_DIR/." "$TARGET_DIR/"

python3 - "$TARGET_CONFIG" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
lines = text.splitlines()

# Replace any active timeout settings instead of appending conflicting values.
lines = [
    line
    for line in lines
    if not re.match(r"^\s*set\s+timeout(?:_style)?\s*=", line)
]
while lines and not lines[-1].strip():
    lines.pop()
lines.extend(["", "set timeout_style=menu", "set timeout=5"])
path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

grep -Fxq 'set timeout_style=menu' "$TARGET_CONFIG"
grep -Fxq 'set timeout=5' "$TARGET_CONFIG"
echo "Configured GRUB menu to boot the default live entry after five seconds."
