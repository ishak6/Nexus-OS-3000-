#!/usr/bin/env bash
# Read-only posture report. This script never changes system configuration.
set -u

pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }

check_command() {
  if command -v "$1" >/dev/null 2>&1; then pass "$1 is installed"; else warn "$1 is not installed"; fi
}

check_sysctl() {
  local key="$1" expected="$2" actual
  if ! command -v sysctl >/dev/null 2>&1; then warn "sysctl command unavailable"; return; fi
  actual="$(sysctl -n "$key" 2>/dev/null || true)"
  if [[ "$actual" == "$expected" ]]; then
    pass "$key=$expected"
  else
    warn "$key expected $expected, observed ${actual:-unavailable}"
  fi
}

printf '%s\n' 'Nexus OS 3000 — read-only security posture'
printf '%s\n' 'This is a diagnostic report, not a security certification.'

for tool in apparmor_status aa-status nft bwrap; do check_command "$tool"; done

check_sysctl kernel.kptr_restrict 2
check_sysctl kernel.dmesg_restrict 1
check_sysctl kernel.yama.ptrace_scope 1
check_sysctl fs.suid_dumpable 0
check_sysctl fs.protected_hardlinks 1
check_sysctl fs.protected_symlinks 1

if command -v systemctl >/dev/null 2>&1; then
  if systemctl is-active --quiet apparmor; then
    pass 'AppArmor service is active'
  else
    warn 'AppArmor service is not active (package presence is not enforcement)'
  fi
else
  warn 'systemctl unavailable; service state not checked'
fi

if command -v nft >/dev/null 2>&1; then
  if nft list ruleset >/dev/null 2>&1; then
    pass 'nftables ruleset can be queried'
  else
    warn 'nftables ruleset could not be queried'
  fi
fi

printf '%s\n' 'Review every warning on the target system; no settings were modified.'
