#!/usr/bin/env bash
# Ensure the live image includes the generic live-config components, its systemd
# backend, and the user-setup helper. The ISO disables APT recommends.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACKAGE_LIST="$ROOT/config/package-lists/nexus.list.chroot"

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

echo "Live-config, systemd backend, and live user setup packages are explicitly staged."
