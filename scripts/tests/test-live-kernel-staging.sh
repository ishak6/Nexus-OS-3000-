#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATOR="$ROOT/scripts/verify-live-kernel-staging.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make_fixture() {
  local dir="$1"
  mkdir -p "$dir/live" "$dir/boot/grub"
  printf 'kernel-fixture\n' > "$dir/live/vmlinuz-test"
  printf 'initrd-fixture\n' > "$dir/live/initrd.img-test"
  cat > "$dir/boot/grub/grub.cfg" <<'EOF'
menuentry "Live system" {
  linux /live/vmlinuz-test boot=live
  initrd /live/initrd.img-test
}
menuentry "Live system fail-safe" {
  linux /live/vmlinuz-test boot=live failsafe
  initrd /live/initrd.img-test
}
EOF
}

make_fixture "$TMP/valid"
bash "$VALIDATOR" "$TMP/valid"

make_fixture "$TMP/missing-kernel"
rm "$TMP/missing-kernel/live/vmlinuz-test"
if bash "$VALIDATOR" "$TMP/missing-kernel" >"$TMP/kernel.log" 2>&1; then
  echo "Validator accepted a missing kernel." >&2
  exit 1
fi
grep -Fq "GRUB references missing kernel" "$TMP/kernel.log"

make_fixture "$TMP/missing-initrd"
rm "$TMP/missing-initrd/live/initrd.img-test"
if bash "$VALIDATOR" "$TMP/missing-initrd" >"$TMP/initrd.log" 2>&1; then
  echo "Validator accepted a missing initrd." >&2
  exit 1
fi
grep -Fq "GRUB references missing initrd" "$TMP/initrd.log"

make_fixture "$TMP/mismatched-pair"
sed -i 's/initrd.img-test/initrd.img-other/' "$TMP/mismatched-pair/boot/grub/grub.cfg"
printf 'other-initrd\n' > "$TMP/mismatched-pair/live/initrd.img-other"
if bash "$VALIDATOR" "$TMP/mismatched-pair" >"$TMP/pair.log" 2>&1; then
  echo "Validator accepted a kernel/initrd version mismatch." >&2
  exit 1
fi
grep -Fq "No matching initrd entry for kernel" "$TMP/pair.log"

echo "Live kernel staging regression tests passed."
