#!/usr/bin/env bash
# Verify that every active GRUB live kernel/initrd reference exists in the
# binary tree before live-build packages the ISO.
set -Eeuo pipefail

BINARY_DIR="${1:-binary}"
LIVE_DIR="$BINARY_DIR/live"
GRUB_CONFIG="$BINARY_DIR/boot/grub/grub.cfg"

if [[ ! -d "$LIVE_DIR" ]]; then
  echo "Missing live kernel directory: $LIVE_DIR" >&2
  exit 1
fi
if [[ ! -s "$GRUB_CONFIG" ]]; then
  echo "Missing generated GRUB configuration: $GRUB_CONFIG" >&2
  exit 1
fi

mapfile -t KERNEL_PATHS < <(
  awk '$1 == "linux" && $2 ~ /^\/live\/vmlinuz-/ { print $2 }' "$GRUB_CONFIG" | sort -u
)
mapfile -t INITRD_PATHS < <(
  awk '$1 == "initrd" && $2 ~ /^\/live\/initrd\.img-/ { print $2 }' "$GRUB_CONFIG" | sort -u
)

if [[ ${#KERNEL_PATHS[@]} -eq 0 ]]; then
  echo "Generated GRUB configuration has no /live/vmlinuz kernel entry." >&2
  exit 1
fi
if [[ ${#INITRD_PATHS[@]} -eq 0 ]]; then
  echo "Generated GRUB configuration has no /live/initrd.img entry." >&2
  exit 1
fi

for path in "${KERNEL_PATHS[@]}"; do
  if [[ ! -s "$BINARY_DIR$path" ]]; then
    echo "GRUB references missing kernel: $BINARY_DIR$path" >&2
    exit 1
  fi
  suffix="${path#/live/vmlinuz-}"
  expected_initrd="/live/initrd.img-$suffix"
  if [[ ! " ${INITRD_PATHS[*]} " == *" $expected_initrd "* ]]; then
    echo "No matching initrd entry for kernel $path (expected $expected_initrd)." >&2
    exit 1
  fi
done

for path in "${INITRD_PATHS[@]}"; do
  if [[ ! -s "$BINARY_DIR$path" ]]; then
    echo "GRUB references missing initrd: $BINARY_DIR$path" >&2
    exit 1
  fi
done

printf 'Verified %s GRUB kernel reference(s) and %s initrd reference(s) against %s.\n' \
  "${#KERNEL_PATHS[@]}" "${#INITRD_PATHS[@]}" "$LIVE_DIR"
