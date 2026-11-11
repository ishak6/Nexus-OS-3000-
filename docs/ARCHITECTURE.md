# Nexus OS 3000 Architecture

## System layers

1. **Hardware and firmware** — CPU, memory, storage, graphics, network and device firmware.
2. **Linux kernel and drivers** — hardware abstraction, scheduling, memory, devices and networking.
3. **OS security boundary** — user separation, mandatory access control, namespaces, seccomp, cgroups, filesystem permissions and firewall enforcement.
4. **System services** — init, login, networking, audio, storage, updates and logging.
5. **Nexus Harness** — application manifest validation, capability policy, future runtime selection and execution audit.
6. **Nexus LUMEN** — desktop shell, Living Space, Orbit, Pulse, Security Center and Settings.
7. **Applications and optional local AI** — user workloads subject to the same OS security boundaries.

## Current implementation

- Base: Debian 13 (trixie) live-build, amd64.
- Kernel: Debian-supported Linux kernel package.
- Initial desktop: XFCE as a temporary bootable baseline.
- Security baseline: staged sysctl configuration; runtime state not yet verified.
- Harness: strict capability manifest, deny-by-default policy and metadata validator.
- Archive inspection: static ZIP/TAR metadata scanner; no extraction, script execution or malware verdict.
- Security diagnostics: read-only shell report of selected sysctl and service state.
- CI: repository checks, JSON parsing, Python compilation, Harness tests and shell syntax validation.

## Planned technology choices

- Future shell: Qt 6 / QML on Wayland, subject to prototype and compatibility testing.
- Isolation: evaluate Bubblewrap, AppArmor, seccomp and cgroups.
- Network policy: nftables, with a carefully designed user-facing policy service.
- Secrets: OS-managed credential storage; never log tokens or API keys.
- Local intelligence: optional, transparent and resource-bounded.

## Trust boundaries

- UI components display policy and request actions; they do not independently grant privileged access.
- The Harness coordinates policy but is not a replacement for kernel-enforced isolation.
- Untrusted archives and scripts are treated as data until inspected.
- Static inspection is only a triage signal; it cannot establish that an archive is benign.
- Sandboxed execution must use established OS mechanisms and restrictive defaults.
- Privileged changes require authenticated authorization and an auditable result.
- AI suggestions are untrusted input. Sensitive actions require preview and user approval.

These are implementation proposals and staged foundations, not claims that all components are already integrated. The initial ISO is a development image and must not be treated as a hardened production OS.
