#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SMOKE_TEST="$ROOT/scripts/vm-smoke-test.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Missing arguments must fail with usage information, not start QEMU.
set +e
usage_output="$(bash "$SMOKE_TEST" 2>&1)"
usage_status=$?
set -e
[[ "$usage_status" -eq 2 ]]
grep -Fq 'Usage:' <<<"$usage_output"

# An empty ISO must be rejected before checking host QEMU dependencies.
: > "$TMP/empty.iso"
set +e
empty_output="$(bash "$SMOKE_TEST" "$TMP/empty.iso" "$TMP/evidence" 2>&1)"
empty_status=$?
set -e
[[ "$empty_status" -eq 2 ]]
grep -Fq 'ISO is missing or empty:' <<<"$empty_output"
[[ ! -e "$TMP/evidence/qemu-monitor.sock" ]]

# Preserve the immediate post-timeout screen for GRUB timer diagnosis.
grep -Fq 'grub-after-timeout.ppm' "$SMOKE_TEST"
grep -Fq 'grub-after-timeout.txt' "$SMOKE_TEST"

# LUMEN may cover XFCE desktop icons; verify panel/live-user and app content.
grep -Fq 'desktop-top-panel.ppm' "$SMOKE_TEST"
grep -Fq 'crop-ppm-top-panel.py' "$SMOKE_TEST"
grep -Fq 'verify-vm-desktop-markers.py' "$SMOKE_TEST"
grep -Fq 'Nexus LUMEN UI content marker' "$SMOKE_TEST"
grep -Fq 'lumen-window.txt' "$SMOKE_TEST"
! grep -Fq "grep -Eqi 'Home'" "$SMOKE_TEST"
! grep -Fq "grep -Eqi 'File System'" "$SMOKE_TEST"

echo "VM smoke-test argument and desktop-marker validation tests passed."
