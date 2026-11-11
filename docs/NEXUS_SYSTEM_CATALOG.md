# Nexus OS 3000 — Complete System Upgrade Catalog

**Status:** Master product/engineering scope. A listed item is a target until implementation and verification evidence are recorded. This document does not claim the full system already exists.

## Product goals

- A distinctive, native, privacy-first desktop OS for amd64 PCs and virtual machines.
- Own Nexus user experience, desktop shell, settings, security/privacy centers, Harness, policy model, and system integration.
- Transparent operation: no fake telemetry, fake antivirus alerts, hidden data collection, or claims of perfect privacy/security.
- Safe recovery and fallback at every major integration stage.

## 1. Boot, installer and platform foundation

- [ ] Debian 13 amd64 live image; stable package sources and pinned build dependencies.
- [ ] BIOS and UEFI boot verification; ISO checksum and build provenance.
- [ ] VM profiles for QEMU/KVM, VirtualBox and VMware; document unsupported configurations.
- [ ] Hardware inventory and compatibility report: CPU, RAM, storage, GPU, network, audio, input.
- [ ] Live session, persistent storage option, installer design, disk encryption and recovery media.
- [ ] Secure update design, signed metadata, rollback protection and recovery partition strategy.
- [ ] Reproducible build effort, SBOM, license inventory and release signing.

## 2. Nexus LUMEN desktop experience

- [ ] Native Qt 6/QML shell; Wayland-first with a supported fallback path.
- [ ] Living Space: task-focused workspaces, pinned apps, recent work and configurable panels.
- [ ] Orbit: workspace/window navigation and keyboard-first launcher.
- [ ] Nexus Core: local command palette; preview before privileged actions.
- [ ] Window management, virtual desktops, overview, task switcher and notifications.
- [ ] Dock, panel, app launcher, status area, quick settings and lock screen integration.
- [ ] First-party theme engine: dark/light/system, accent palette, density and motion controls.
- [ ] Design system: typography, spacing, icon family, motion tokens and reusable components.
- [ ] HiDPI/fractional scaling, multi-monitor, orientation, touch, keyboard and screen-reader support.
- [ ] Wallpaper, sound, cursor, fonts, icon theme and accessibility preferences.
- [ ] Session restore with user control; crash recovery and safe desktop fallback.

## 3. Core system settings

- [ ] Unified Settings app with search, categories and reset-to-default.
- [ ] Display, audio, keyboard, mouse/touchpad, Bluetooth, Wi-Fi and wired networking.
- [ ] Users, groups, login, lock screen, language, region, date/time and power.
- [ ] Storage, partitions, removable devices, printers and peripheral management.
- [ ] Notifications, startup applications, background services and default apps.
- [ ] Developer options, logs, diagnostics and exportable support bundle.

## 4. Nexus Pulse — system telemetry

- [ ] CPU, memory, disk, GPU (where supported), battery, temperature and network metrics.
- [ ] Process/service viewer and resource history.
- [ ] Clear data provenance, sampling interval and retention settings.
- [ ] Local-only by default; export is user initiated.
- [ ] Missing/unavailable metrics must show “unavailable”, never fabricated values.

## 5. Nexus Security Center

- [ ] Security posture dashboard based on verifiable system state.
- [ ] AppArmor status and profile manager; seccomp and namespace policy integration.
- [ ] nftables firewall with safe defaults, explainable rules and recovery path.
- [ ] Permission broker for camera, microphone, location, screen capture and removable media.
- [ ] Application provenance, package signature and update verification status.
- [ ] Quarantine/review/restore workflow for suspicious files; preserve evidence and avoid false certainty.
- [ ] Vulnerability and security update status from trusted package metadata.
- [ ] Read-only audit report, event history and emergency recovery guidance.
- [ ] No “100% secure” claim; disclose kernel, firmware, physical and supply-chain residual risks.

## 6. Nexus Privacy Center

- [ ] Per-application permissions and recent access history.
- [ ] Network connection overview and optional per-app network restrictions.
- [ ] Local data inventory, retention controls and clear/delete/export controls.
- [ ] Telemetry opt-in controls and explicit explanation of each data flow.
- [ ] DNS configuration, proxy and VPN integration through supported system interfaces.
- [ ] Tracker/ad blocking only through transparent, user-controlled DNS/network lists; no deceptive interception.
- [ ] Microphone/camera indicators and global privacy shortcuts.
- [ ] No covert monitoring, hidden recording, credential collection or anti-uninstall behavior.

## 7. Nexus Harness — application trust and execution

- [ ] Versioned application manifest and schema validation.
- [ ] Default-deny capabilities; user-visible permission request and revocation.
- [ ] Static archive inspection with path traversal, symlink, special-file and archive-bomb safeguards.
- [ ] Safe extraction into a disposable staging area only after validation.
- [ ] Runtime profiles using established OS controls: Bubblewrap/namespaces, seccomp, AppArmor and cgroups.
- [ ] Resource limits, filesystem allowlists, network policy and read-only mounts.
- [ ] Developer mode with explicit trust boundaries and auditable elevation.
- [ ] Native application integration without silently bypassing OS policy.
- [ ] Execution history, policy decision log, kill/revoke controls and recovery.
- [ ] Imported scripts never auto-run; show command and effects before user approval.

## 8. App and package ecosystem

- [ ] Curated package center using signed Debian repositories initially.
- [ ] App details: publisher/source, license, permissions, dependencies and update channel.
- [ ] Install/update/remove with transaction status and rollback where supported.
- [ ] Flatpak evaluation as an optional ecosystem, with permission review.
- [ ] Developer SDK, templates, packaging guide and test VM image.
- [ ] No unsupported compatibility claims; evaluate Windows app compatibility separately.

## 9. Network, connectivity and sharing

- [ ] NetworkManager integration and connection editor.
- [ ] Wi-Fi, Ethernet, Bluetooth, hotspot and VPN status.
- [ ] DNS-over-TLS/HTTPS options where supported by chosen resolver.
- [ ] Firewall status and per-network trust profiles.
- [ ] File sharing and remote access disabled by default; explicit consent and visible status.
- [ ] Network diagnostics with user-controlled export.

## 10. Files, backup and recovery

- [ ] File manager integration, mounts and removable media controls.
- [ ] Backup/restore UI with encryption and destination verification.
- [ ] Snapshot/rollback strategy selected after filesystem and installer evaluation.
- [ ] Recovery mode, safe graphics mode and known-good boot entry.
- [ ] Power-loss and interrupted-update recovery tests.

## 11. Audio, media and peripherals

- [ ] PipeWire audio routing and device selection.
- [ ] Camera/microphone permission indicators.
- [ ] Bluetooth audio, USB devices, printers and scanner support.
- [ ] Display/audio troubleshooting and hardware diagnostics.

## 12. Optional local intelligence

- [ ] Optional local assistant; disabled until user enables it.
- [ ] Local model discovery, resource budgets and model integrity checks.
- [ ] No automatic upload of files, prompts, telemetry or secrets.
- [ ] AI-generated commands are untrusted proposals; preview and confirmation before execution.
- [ ] Clear model/provider selection and local-data deletion controls.

## 13. Developer environment

- [ ] Terminal, editor integration, Git tools and build toolchains as optional packages.
- [ ] Project workspace and safe import workflow.
- [ ] Container/VM development profiles and resource controls.
- [ ] Logs, crash reports and diagnostic bundle with secret redaction.
- [ ] Build reproducibility and dependency/license reports.

## 14. Accessibility and internationalization

- [ ] Keyboard-only navigation and visible focus.
- [ ] Screen reader and accessible labels.
- [ ] High contrast, text scaling, reduced motion and color-independent status.
- [ ] Bengali and English localization baseline; locale-aware date, time and number formats.
- [ ] RTL readiness for future languages.

## 15. Quality, security and release engineering

- [ ] CI: lint, unit, integration, QML, package and ISO build checks.
- [ ] VM matrix: boot, display, input, network, audio, shutdown, upgrade and rollback.
- [ ] Performance budgets for idle RAM, startup, UI frame time and background CPU.
- [ ] Threat modeling, dependency provenance, license review and SBOM.
- [ ] Fuzzing and adversarial tests for parsers, manifests and archive inspection.
- [ ] Privacy/data-flow review and permission revocation tests.
- [ ] Accessibility and localization tests.
- [ ] Signed release artifacts, checksums, provenance, release notes and known-issues list.

## Delivery rule

The project can be developed in large coordinated batches, but integration gates remain mandatory. A component is not “done” until it has source code, automated checks, runtime evidence, documented limitations and a recovery path. The first milestone remains a bootable ISO and a LUMEN prototype running inside that ISO. Do not remove XFCE or another recovery desktop until LUMEN is proven in the target VM matrix.

## Current verified starting point (repository snapshot)

- Debian Trixie live-build workflow and XFCE baseline exist.
- Harness manifest validation and metadata-only archive inspection exist.
- Security and privacy documents exist; runtime enforcement is not fully verified.
- LUMEN has an initial Qt Quick prototype and a CI build/smoke-test workflow is being exercised.
- The initial ISO has not yet passed the full build-and-VM-boot release gates.
