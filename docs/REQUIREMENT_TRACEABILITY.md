# Nexus OS 3000 — Requirement Traceability Register

**Purpose:** Master checklist for zero-pending delivery. The detailed product scope remains in [NEXUS_SYSTEM_CATALOG.md](NEXUS_SYSTEM_CATALOG.md); this register assigns stable IDs and maps every catalog requirement to an implementation milestone and verification evidence.

**Status vocabulary**
- `NOT STARTED`: no implementation evidence.
- `IN PROGRESS`: implementation is underway; acceptance evidence is incomplete.
- `IMPLEMENTED / UNVERIFIED`: code or configuration exists, but the acceptance test has not passed with recorded evidence.
- `VERIFIED`: implementation and its defined acceptance checks have passed; evidence is linked.
- `BLOCKED — APPROVAL REQUIRED`: a real platform, access, safety or dependency constraint requires an explicit user-approved alternative. This is not completion.

No item may be silently removed, deferred or marked verified. Each status change must include a commit, test/evidence reference, and any residual limitation. This register is initialized conservatively: repository presence alone is not proof of runtime behavior.

## M0 — Foundation, architecture and delivery controls

- [ ] M0-001 Establish authoritative repository, branch, baseline commit and clean source inventory.
- [ ] M0-002 Maintain architecture, trust boundaries, dependency decisions and supported-platform policy.
- [ ] M0-003 Maintain this requirement register and map every requirement to implementation and acceptance tests.
- [ ] M0-004 Establish reproducible developer setup, pinned build dependencies and documented local commands.
- [ ] M0-005 CI quality gates: lint/static checks, unit tests, integration tests, QML checks, package checks and ISO build.
- [ ] M0-006 Preserve build logs, test reports, checksums, artifacts and release provenance.
- [ ] M0-007 Maintain license inventory, third-party notices and dependency provenance.
- [ ] M0-008 Define performance budgets and regression baselines.
- [ ] M0-009 Define secure defaults, rollback strategy, recovery gates and evidence retention.
- [ ] M0-010 Maintain known limitations and require approval for any scope substitution.

## M1 — Core operating system and boot foundation

- [ ] M1-001 Debian 13 Trixie amd64 base with stable, authenticated package sources.
- [ ] M1-002 Debian-supported Linux kernel, drivers, initramfs and systemd boot.
- [ ] M1-003 BIOS and UEFI bootloader configuration and boot verification.
- [ ] M1-004 User/group, login/session and least-privilege foundation.
- [ ] M1-005 Filesystem, storage and removable-device foundation.
- [ ] M1-006 Hardware inventory and compatibility reporting for CPU, RAM, storage, GPU, network, audio and input.
- [ ] M1-007 Live session and safe persistent-storage design.
- [ ] M1-008 Kernel/sysctl baseline with runtime verification; package presence alone is insufficient.
- [ ] M1-009 Offline-capable base operation and diagnostics.

## M2 — Native LUMEN desktop and system UX

- [ ] M2-001 Native Qt 6/QML desktop shell; Wayland-first with tested fallback.
- [ ] M2-002 Living Space: task-focused workspaces, pinned apps, recent work and configurable panels.
- [ ] M2-003 Orbit: workspace/window navigation and keyboard-first launcher.
- [ ] M2-004 Nexus Core local command palette; preview before privileged actions.
- [ ] M2-005 Window manager integration, virtual desktops, overview and task switcher.
- [ ] M2-006 Dock, panel, app launcher, status area, quick settings and lock screen.
- [ ] M2-007 Notifications, shortcuts, clipboard and session restore with crash-safe fallback.
- [ ] M2-008 Theme engine: dark/light/system, accent, density, motion, wallpaper, sounds, cursor, fonts and icons.
- [ ] M2-009 Unified Settings with search, categories and reset-to-default.
- [ ] M2-010 Display, audio, keyboard, mouse/touchpad, Bluetooth, Wi-Fi and wired-network settings.
- [ ] M2-011 Users, groups, login, lock screen, language, region, date/time and power settings.
- [ ] M2-012 Storage, partitions, removable devices, printers and peripheral management.
- [ ] M2-013 Notifications, startup apps, background services, default apps and developer options.
- [ ] M2-014 HiDPI/fractional scaling, multi-monitor, orientation, touch, keyboard and screen-reader support.
- [ ] M2-015 Keep XFCE/recovery desktop until LUMEN session boot, recovery and compatibility are verified.

## M3 — Live ISO and virtual-machine validation

- [ ] M3-001 Build Debian live ISO with documented and pinned inputs.
- [ ] M3-002 Verify BIOS and UEFI boot entries and boot menu behavior.
- [ ] M3-003 Verify live desktop startup, display, keyboard, shutdown and reboot in isolated QEMU.
- [ ] M3-004 Test supported VM profiles for QEMU/KVM, VirtualBox and VMware; document unsupported cases.
- [ ] M3-005 Generate SHA-256 checksums, build logs and artifact manifest.
- [ ] M3-006 Retain ISO, logs, screenshots and machine-readable test evidence.
- [ ] M3-007 Test live session, optional persistence and safe-boot/recovery paths.

## M4 — Native installer and first boot

- [ ] M4-001 Guided installer with safe disk selection and explicit destructive-action confirmation.
- [ ] M4-002 Partitioning and filesystem selection with validation.
- [ ] M4-003 Bootloader installation and post-install boot verification.
- [ ] M4-004 Full-disk encryption and key-handling design with recovery procedure.
- [ ] M4-005 First-boot wizard: user, locale, network and privacy choices.
- [ ] M4-006 Interrupted-install, power-loss and failed-boot recovery tests.
- [ ] M4-007 Installer must not be marked complete until install/upgrade/recovery are tested in disposable VMs.

## M5 — Nexus Harness and enforced app sandbox

- [ ] M5-001 Versioned application capability manifest and schema validation.
- [ ] M5-002 Default-deny capabilities with user-visible grant, denial and revocation.
- [ ] M5-003 Safe ZIP/TAR inspection: traversal, symlink, special-file and archive-bomb defenses.
- [ ] M5-004 Validated extraction only into disposable staging areas.
- [ ] M5-005 Runtime isolation using established OS controls: Bubblewrap/namespaces, seccomp, AppArmor and cgroups.
- [ ] M5-006 Filesystem allowlists, read-only mounts and network policy.
- [ ] M5-007 CPU, memory, process and I/O resource limits.
- [ ] M5-008 Developer mode with explicit trust boundaries and auditable elevation.
- [ ] M5-009 Execution history, policy decision log, kill/revoke controls and recovery.
- [ ] M5-010 Imported scripts never auto-run; show commands and effects before approval.
- [ ] M5-011 Authorized sandbox boundary and escape-resistance regression tests.

## M6 — Security Center

- [ ] M6-001 Verifiable security posture dashboard; no fabricated alerts or protection claims.
- [ ] M6-002 AppArmor enabled-mode and loaded-profile management/verification.
- [ ] M6-003 Seccomp, namespaces and capability integration.
- [ ] M6-004 nftables firewall with explainable rules, safe defaults and recovery path.
- [ ] M6-005 Application/package provenance and signature verification status.
- [ ] M6-006 Suspicious-file quarantine, review and restore while preserving evidence.
- [ ] M6-007 Trusted vulnerability/security-update status.
- [ ] M6-008 Read-only audit report, event history and emergency recovery guidance.
- [ ] M6-009 Security control tests and documented residual kernel, firmware, physical and supply-chain risks.

## M7 — Privacy Center

- [ ] M7-001 Per-application permission grants and recent access history.
- [ ] M7-002 Camera, microphone, location and screen-capture permission indicators and controls.
- [ ] M7-003 USB, removable media, filesystem and clipboard access controls.
- [ ] M7-004 Network-connection overview and optional per-app network restrictions.
- [ ] M7-005 Local data inventory, retention controls, delete and user-initiated export.
- [ ] M7-006 Telemetry opt-in controls with an explanation of every data flow.
- [ ] M7-007 DNS, proxy and VPN integration through supported system interfaces.
- [ ] M7-008 Transparent user-controlled DNS/network filtering lists where supported.
- [ ] M7-009 Global privacy shortcuts and permission revocation tests.
- [ ] M7-010 No covert monitoring, hidden recording, credential collection or anti-uninstall behavior.

## M8 — Network and connectivity

- [ ] M8-001 NetworkManager integration and connection editor.
- [ ] M8-002 Ethernet, Wi-Fi, Bluetooth and hotspot status/control.
- [ ] M8-003 IPv4/IPv6, DHCP, DNS and connection diagnostics.
- [ ] M8-004 VPN support through maintained interfaces, including WireGuard and OpenVPN where packages/hardware support it.
- [ ] M8-005 DNS-over-TLS/HTTPS options where supported by the selected resolver.
- [ ] M8-006 Proxy configuration and network trust profiles.
- [ ] M8-007 Firewall status and network monitoring.
- [ ] M8-008 File sharing/remote access disabled by default with explicit consent and visible active status.
- [ ] M8-009 Network tests in VM and supported physical hardware.

## M9 — Recovery, backup and maintenance

- [ ] M9-001 Recovery environment and known-good boot entry.
- [ ] M9-002 Encrypted backup/restore UI with destination verification.
- [ ] M9-003 Select snapshot/rollback technology after filesystem and installer evaluation.
- [ ] M9-004 Btrfs snapshots where selected and supported.
- [ ] M9-005 Rollback and repair workflows with integrity checks.
- [ ] M9-006 Power-loss and interrupted-update recovery tests.
- [ ] M9-007 Safe graphics mode and recovery desktop fallback.

## M10 — Updates, packages and software center

- [ ] M10-001 Curated package center using authenticated, signed Debian repositories initially.
- [ ] M10-002 Package details: publisher/source, license, permissions and dependencies.
- [ ] M10-003 Install/update/remove transaction status and rollback where supported.
- [ ] M10-004 Signed repository metadata, update integrity and rollback protection.
- [ ] M10-005 Update engine and stable/testing/development release channels.
- [ ] M10-006 Optional Flatpak evaluation with permission review.
- [ ] M10-007 Developer SDK, templates, packaging guide and test VM image.
- [ ] M10-008 No unsupported Windows-app compatibility claims.

## Cross-cutting product requirements

- [ ] X-001 Nexus Pulse: CPU, memory, disk, GPU (where supported), battery, temperature and network metrics.
- [ ] X-002 Process/service viewer and resource history.
- [ ] X-003 Telemetry provenance, sampling interval, retention settings and unavailable-state handling.
- [ ] X-004 Local-only telemetry by default; export is user initiated.
- [ ] X-005 PipeWire audio routing, Bluetooth audio, camera/microphone indicators and device selection.
- [ ] X-006 USB devices, printers, scanners and peripheral diagnostics.
- [ ] X-007 File manager, mounts and removable-media controls.
- [ ] X-008 Optional local assistant, disabled until enabled by user.
- [ ] X-009 Local model discovery, resource budgets, model integrity and local-data deletion controls.
- [ ] X-010 AI commands treated as untrusted proposals; preview and confirmation before execution.
- [ ] X-011 Optional developer terminal/editor/Git/build toolchains.
- [ ] X-012 Project workspace, safe import and container/VM development profiles.
- [ ] X-013 Logs, crash reports and support bundles with secret redaction.
- [ ] X-014 Accessibility: keyboard-only navigation, visible focus, screen reader, high contrast, text scaling and reduced motion.
- [ ] X-015 Bengali and English localization, locale-aware formatting and RTL readiness.
- [ ] X-016 Multi-user support and account/session separation.
- [ ] X-017 Parental controls with explicit policy and privacy boundaries.
- [ ] X-018 Diagnostics and offline operation.
- [ ] X-019 Settings import/export and reset.
- [ ] X-020 Global search, keyboard shortcuts, clipboard, notifications and accessibility integration.

## M11 — Integration, audit and release

- [ ] M11-001 Full end-to-end integration and regression suite across all milestones.
- [ ] M11-002 Threat-model review and authorized Red/Blue/Purple security assessment.
- [ ] M11-003 Parser/manifest/archive fuzzing and adversarial regression tests.
- [ ] M11-004 Privacy/data-flow review and permission-revocation tests.
- [ ] M11-005 Performance budgets: idle RAM, boot/startup, UI frame time and background CPU.
- [ ] M11-006 Hardware/VM compatibility matrix and known-issues report.
- [ ] M11-007 Accessibility and localization test evidence.
- [ ] M11-008 SBOM, dependency/license inventory and provenance.
- [ ] M11-009 Signed release artifacts, checksums, release notes and recovery instructions.
- [ ] M11-010 Final release gate: no unresolved requirement, no unapproved omission and no unverified completion claim.

## Evidence ledger

For each requirement, append: requirement ID, status, commit SHA, exact test command/workflow run, result, artifact/log reference, reviewer notes and residual limitations. A commit without a passing acceptance test is not verification. An empty or unavailable CI status is recorded as **UNCONFIRMED**, never PASS.

## Initial baseline note

This register is newly established from the repository's existing system catalog, roadmap, architecture, threat model and release gates. Existing source files and workflow definitions are not automatically counted as verified runtime behavior. The initial state of every unchecked item is **NOT VERIFIED** until evidence is collected.
