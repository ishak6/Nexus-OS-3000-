#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIGURATOR="$ROOT/scripts/configure-live-bootloader.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Existing indefinite/hidden timeout values must be replaced, not duplicated.
mkdir -p "$TMP/stock-existing"
cat > "$TMP/stock-existing/config.cfg" <<'EOF'
insmod all_video
set timeout_style=hidden
set timeout=0
EOF
printf 'menuentry "Live system" { true; }\n' > "$TMP/stock-existing/grub.cfg"
bash "$CONFIGURATOR" "$TMP/stock-existing" "$TMP/output-existing"
grep -Fxq 'set timeout_style=menu' "$TMP/output-existing/config.cfg"
grep -Fxq 'set timeout=5' "$TMP/output-existing/config.cfg"
[[ "$(grep -Ec '^[[:space:]]*set[[:space:]]+timeout_style=' "$TMP/output-existing/config.cfg")" -eq 1 ]]
[[ "$(grep -Ec '^[[:space:]]*set[[:space:]]+timeout=' "$TMP/output-existing/config.cfg")" -eq 1 ]]
cmp "$TMP/stock-existing/grub.cfg" "$TMP/output-existing/grub.cfg"

# Templates without explicit timeout settings must receive the same safe defaults.
mkdir -p "$TMP/stock-empty"
printf 'insmod gfxterm\n' > "$TMP/stock-empty/config.cfg"
bash "$CONFIGURATOR" "$TMP/stock-empty" "$TMP/output-empty"
grep -Fxq 'set timeout_style=menu' "$TMP/output-empty/config.cfg"
grep -Fxq 'set timeout=5' "$TMP/output-empty/config.cfg"

echo "GRUB live boot configuration tests passed."
