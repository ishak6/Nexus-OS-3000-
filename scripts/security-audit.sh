#!/usr/bin/env bash
# Read-only posture report. This script never changes system configuration.
set -u

pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1 is installed"
  else
    warn "$1 is not installed"
  fi
}

check_sysctl() {
  local key="$1" expected="$2" actual
  if ! command -v sysctl >/dev/null 2>&1; then
    warn "sysctl command unavailable; cannot verify $key"
    return
  fi
  actual="$(sysctl -n "$key" 2>/dev/null || true)"
  if [[ "$actual" == "$expected" ]]; then
    pass "$key=$expected"
  else
    warn "$key expected $expected, observed ${actual:-unavailable}"
  fi
}

check_apparmor() {
  local enabled=""
  if [[ -r /sys/module/apparmor/parameters/enabled ]]; then
    enabled="$(tr -d '[:space:]' </sys/module/apparmor/parameters/enabled)"
  fi
  if [[ "$enabled" == "Y" ]]; then
    pass "AppArmor kernel module is enabled"
  else
    warn "AppArmor kernel module is not confirmed enabled"
  fi

  if command -v aa-status >/dev/null 2>&1; then
    if aa-status --enabled >/dev/null 2>&1; then
      pass "AppArmor reports enabled"
    else
      warn "AppArmor reports disabled or status unavailable"
    fi
    aa-status 2>&1 | sed -n '1,8p'
  elif command -v apparmor_status >/dev/null 2>&1; then
    apparmor_status 2>&1 | sed -n '1,8p'
  else
    warn "AppArmor status utility is unavailable"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet apparmor; then
      pass "AppArmor service is active"
    else
      warn "AppArmor service is not active"
    fi
  fi
}

printf '%s\n' 'Nexus OS 3000 — read-only security posture'
printf '%s\n' 'This is a diagnostic report, not a security certification.'

for tool in aa-status apparmor_status nft bwrap; do check_command "$tool"; done

# Values match docs/SECURITY_BASELINE.md. Unsupported keys are reported, not hidden.
check_sysctl kernel.kptr_restrict 2
check_sysctl kernel.dmesg_restrict 1
check_sysctl kernel.yama.ptrace_scope 1
check_sysctl kernel.unprivileged_bpf_disabled 1
check_sysctl fs.suid_dumpable 0
check_sysctl fs.protected_hardlinks 1
check_sysctl fs.protected_symlinks 1
check_sysctl fs.protected_fifos 1
check_sysctl fs.protected_regular 2
check_sysctl net.ipv4.conf.all.accept_redirects 0
check_sysctl net.ipv6.conf.all.accept_redirects 0
check_sysctl net.ipv4.conf.all.accept_source_route 0

check_apparmor

if command -v nft >/dev/null 2>&1; then
  if nft list ruleset >/dev/null 2>&1; then
    pass 'nftables ruleset can be queried (inspect policy separately)'
  else
    warn 'nftables ruleset could not be queried; privileges may be required'
  fi
fi

printf '%s\n' 'Review every warning on the target system; no settings were modified.'
