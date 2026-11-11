# Nexus OS 3000 Roadmap

This roadmap separates working software from concepts and future research.

## Phase 0 — Repository and build foundation
- [x] Define project principles and initial repository layout.
- [x] Add Debian Live Build package configuration.
- [x] Add GitHub Actions ISO and quality workflows.
- [ ] Run the first successful ISO build.
- [ ] Boot-test the ISO in a virtual machine and record results.

## Phase 1 — Minimal bootable system
- Confirm boot on supported amd64 virtual machines.
- Verify display, keyboard, storage, network and shutdown.
- Document hardware support and known limitations.
- Establish signed release artifacts and reproducible build metadata.

## Phase 2 — Nexus LUMEN desktop
- Define UX flows and accessibility requirements.
- Build the first native desktop shell.
- Implement Living Space, workspace switching and settings navigation.
- Keep all security-critical decisions outside the presentation layer.

## Phase 3 — Harness and application isolation
- Define a threat model and permission/capability schema.
- Integrate OS-enforced isolation and resource limits.
- Inspect imported projects before execution.
- Require explicit approval for network, device and privileged access.

## Phase 4 — Security and privacy
- Add package signature verification and update integrity checks.
- Add firewall and per-application network policy interfaces.
- Add permission history, quarantine workflow and recovery.
- Add privacy controls with clear local/network data-flow explanations.

## Phase 5 — System intelligence
- Add evidence-based telemetry.
- Add optional local AI with explicit resource and data controls.
- Require preview and approval for sensitive AI actions.

## Phase 6 — Installer and stable release
- Design installer, disk encryption and recovery flow.
- Test upgrades, rollback, accessibility and hardware compatibility.
- Publish security policy, release notes, checksums and SBOM.

## Release gates

A feature is not marked complete until it has implementation evidence, tests, documented limitations, and a security/privacy review. A successful CI build alone does not prove the OS is secure or production-ready.