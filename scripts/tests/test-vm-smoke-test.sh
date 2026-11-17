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

echo "VM smoke-test argument and input validation tests passed."
