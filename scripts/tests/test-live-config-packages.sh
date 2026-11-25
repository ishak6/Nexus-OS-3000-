#!/usr/bin/env bash
# Ensure the live image includes the generic live-config components, its systemd
# backend, and the user-setup helper. The ISO disables APT recommends.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACKAGE_LIST="$ROOT/config/package-lists/nexus.list.chroot"
AUTOSTART_FILE="$ROOT/config/includes.chroot/etc/xdg/autostart/nexus-lumen.desktop"

required_packages=(
  live-config
  live-config-systemd
  user-setup
)

for package in "${required_packages[@]}"; do
  if ! awk -v package="$package" '$1 == package && $1 !~ /^#/ { found=1 } END { exit !found }' "$PACKAGE_LIST"; then
    echo "Required live boot package is missing from $PACKAGE_LIST: $package" >&2
    exit 1
  fi
done

# LUMEN runs as an application inside XFCE; it does not replace the login shell.
if [[ ! -s "$AUTOSTART_FILE" ]]; then
  echo "LUMEN XFCE autostart entry is missing: $AUTOSTART_FILE" >&2
  exit 1
fi
for entry in \
  'Exec=/usr/bin/env QT_QUICK_BACKEND=software /usr/bin/nexus-lumen' \
  'TryExec=/usr/bin/nexus-lumen' \
  'OnlyShowIn=XFCE;' \
  'X-GNOME-Autostart-enabled=true'; do
  if ! grep -Fxq "$entry" "$AUTOSTART_FILE"; then
    echo "LUMEN XFCE autostart entry is missing required setting: $entry" >&2
    exit 1
  fi
done

echo "Live boot packages and XFCE-scoped LUMEN autostart entry are explicitly staged."
