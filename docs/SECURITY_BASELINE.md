# Nexus OS 3000 — Initial Security Baseline

## Scope and status

The image includes a conservative sysctl.d baseline at
/etc/sysctl.d/99-nexus-hardening.conf. It is intended to reduce kernel
information exposure, restrict cross-process inspection, protect shared
temporary-directory operations, and reject network redirects/source routes.

**Status: staged for image build; runtime behavior is not yet verified.**
Do not describe this as a hardened OS, antivirus, firewall, or security
certification. The first successful ISO must be boot-tested before these
settings can be marked verified.

## Included controls

- Kernel pointer and dmesg visibility restrictions.
- Yama ptrace scope set to the standard restricted mode.
- Unprivileged eBPF disabled where supported by the Debian kernel.
- SUID core dumps disabled.
- Protected hardlinks, symlinks, FIFOs and regular files.
- IPv4/IPv6 redirect acceptance disabled; IPv4 source routing disabled.

The baseline deliberately does not install a default-deny firewall policy,
disable IPv6, force a DNS provider, or block user applications from network
access. Those changes can break connectivity and require a separate,
user-visible policy design.

## Verification after boot

Run these checks in a test VM:

```sh
sysctl kernel.kptr_restrict kernel.dmesg_restrict kernel.yama.ptrace_scope
sysctl kernel.unprivileged_bpf_disabled fs.suid_dumpable
sysctl fs.protected_hardlinks fs.protected_symlinks
sysctl fs.protected_fifos fs.protected_regular
sysctl net.ipv4.conf.all.accept_redirects net.ipv6.conf.all.accept_redirects
```

Expected values are respectively 2, 1, 1, 1, 0, 1, 1, 2, 2, 0, 0.
If a key is unavailable on a supported kernel, record the kernel version and
the exact warning; do not silently claim that control is active.

Check systemd application and errors:

```sh
systemctl status systemd-sysctl --no-pager
journalctl -b -u systemd-sysctl --no-pager
```

Also test normal networking, VPN connectivity, developer tooling, suspend,
reboot, and shutdown. A failed or unsupported sysctl must be corrected or
explicitly documented before release.

## Next security gates

1. Verify this baseline in the live VM and capture test evidence.
2. Confirm AppArmor is enabled and profiles are loaded; package installation
   alone is not proof of enforcement.
3. Design a user-visible nftables policy with safe recovery and no lockout.
4. Add signed build provenance, SBOM and release checksum verification.
5. Review the complete system with threat modeling and compatibility tests.
