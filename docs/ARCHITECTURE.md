# Nexus OS 3000 Architecture

## Proposed layers

1. **Hardware and firmware** — CPU, memory, storage, graphics, network and device firmware.
2. **Linux kernel and drivers** — hardware abstraction, process scheduling, memory, device and network primitives.
3. **OS security boundary** — user separation, mandatory access controls, namespaces, seccomp, cgroups, filesystem permissions and firewall enforcement.
4. **System services** — init, login, networking, audio, storage, updates and logging.
5. **Nexus Harness** — application launch policy, capability grants, runtime selection and execution audit.
6. **Nexus LUMEN** — desktop shell, Living Space, Orbit and Settings.
7. **Applications and optional local AI** — user-facing workloads subject to the same OS security boundaries.

## Trust boundaries

- UI components display policy and request actions; they do not independently grant privileged access.
- The Harness coordinates policy but is not a replacement for kernel-enforced isolation.
- Untrusted archives and scripts are treated as data until inspected.
- Sandboxed execution uses established OS mechanisms and restrictive defaults.
- Privileged changes require authenticated authorization and an auditable result.
- AI suggestions are untrusted input. Sensitive actions require preview and user approval.

## Initial implementation choices

- Base: Debian 13 (trixie) live-build, amd64.
- Kernel: Debian-supported Linux kernel package.
- Initial desktop: XFCE as a temporary bootable baseline.
- Future shell: Qt 6 / QML on Wayland, subject to prototype and compatibility testing.
- Isolation: evaluate Bubblewrap, AppArmor, seccomp and cgroups.
- Network policy: nftables, with a carefully designed user-facing policy service.

These are implementation proposals, not claims that all components are already integrated. The initial ISO is a development image and must not be treated as a hardened production OS.