# Nexus OS 3000 Roadmap

This roadmap separates working software from concepts and future research.

## Phase 0 — Repository and build foundation
- [x] Define project principles and initial repository layout.
- [x] Add Debian Live Build package configuration.
- [x] Add GitHub Actions ISO and quality workflows.
- [x] Run the first successful ISO build (GitHub Actions Build Nexus OS ISO #24).
- [x] Add an isolated QEMU BIOS boot smoke-test job with screenshot/OCR evidence upload.
- [ ] Pass the QEMU VM desktop boot test and record the evidence.

## Phase 1 — Minimal bootable system
- Confirm boot on supported amd64 virtual machines.
- Verify display, keyboard, storage, network and shutdown.
- Document hardware support and known limitations.
- Establish signed release artifacts and reproducible build metadata.

## Phase 2 — Nexus LUMEN desktop
- [x] Specify desktop surfaces, interaction invariants and accessibility requirements.
- [ ] Build the first native desktop shell.
- [ ] Implement Living Space, workspace switching and settings navigation.
- [ ] Connect Pulse to real system telemetry.

## Phase 3 — Harness and application isolation
- [x] Define a versioned capability manifest and deny-by-default policy contract.
- [x] Add metadata-only manifest validation and CI unit tests.
- [x] Add static ZIP/TAR metadata inspection without extraction or execution.
- [ ] Integrate OS-enforced isolation and resource limits.
- [ ] Add explicit capability approval and revocation.
- [ ] Add auditable permission grants, denials and revocation.

## Phase 4 — Security and privacy
- [x] Document privacy defaults, data classes and honest limitations.
- [x] Add a read-only security posture diagnostic.
- [ ] Verify sysctl baseline in the live VM.
- [ ] Confirm AppArmor is enabled and profiles are loaded.
- [ ] Design a user-visible nftables policy with safe recovery.
- [ ] Add package signature verification and update integrity checks.
- [ ] Add permission history, quarantine workflow and recovery.

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
