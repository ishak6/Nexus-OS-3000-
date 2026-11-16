# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | **PASS** on evidence baseline `fccde56a10706d97b59cf5ca3f86bfb1e06fd9c3` via Quality Checks #106. |
| ISO build | Non-empty ISO, SHA-256, BIOS/UEFI entries and retained artifact | **PASS for Build #39's build job only**, on older commit `f9b8986612f68c0335563a42d9bf6576d4233800`. The ISO and checksum were uploaded. The evidence baseline has no ISO build yet. |
| VM boot | Boot log and screenshot showing the live desktop, with no host disk or network | **FAIL** in Build #39. QEMU remained at the GRUB menu; the XFCE desktop marker was not detected. |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false`. |
| Hardware basics | Display, keyboard, storage, network, audio and shutdown/reboot | Not tested on a declared hardware/VM matrix. |
| Security baseline | Runtime sysctl values and service status | Configuration is staged and static consistency tests pass; runtime state is not verified. |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics. |
| AppArmor | Enabled mode and loaded profile evidence | Not verified. Package installation is not proof of active enforcement. |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package is staged; live VM and physical network behavior are not verified. |
| Harness policy | Manifest validator and archive inspection tests | Static policy and archive-inspection tests pass. This is not runtime sandbox enforcement. |
| Sandbox runtime | Boundary tests, resource limits, revocation and escape-resistance evidence | Not implemented/verified. |
| Privacy controls | Data-flow inventory, permission enforcement and opt-in/revocation tests | Specification exists; runtime permission enforcement is not implemented. |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt/QML prototype build and offscreen startup pass in Quality #106. It is not a complete shell or integrated desktop session; XFCE remains the fallback. |
| Recovery | Recovery environment, restore and rollback tests | Not implemented. |
| Updates | Signature verification, rollback and recovery tests | Not implemented. |
| Release integrity | SBOM, provenance, checksums, signed release and license inventory | An ISO SHA-256 exists for Build #39; complete SBOM, provenance and signed release evidence are not established. |

## Current evidence snapshot — 2026-11-16

- Repository: `ishak6/Nexus-OS-3000-`
- At the time of this snapshot, `main` pointed to the evidence baseline [`fccde56a10706d97b59cf5ca3f86bfb1e06fd9c3`](https://github.com/ishak6/Nexus-OS-3000-/commit/fccde56a10706d97b59cf5ca3f86bfb1e06fd9c3). This commit includes the preceding security-audit consistency changes and this release-gate evidence refresh.
- The repository has one branch, no published GitHub releases, and branch protection is not enabled.
- Latest completed quality run for the evidence baseline: [Quality Checks #106](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/43920040920), on `fccde56a10706d97b59cf5ca3f86bfb1e06fd9c3`, completed successfully. The `repository-checks` job passed:
  - Harness unit tests: 11 passed.
  - Pulse unit tests: 5 passed.
  - Security-baseline consistency tests: 2 passed.
  - GRUB boot-config and VM smoke-test argument-validation scripts passed.
  - Qt 6/CMake LUMEN build passed.
  - The 8-second Qt offscreen startup smoke test passed.
- Latest ISO workflow: [Build Nexus OS ISO #39](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/43761385453), on commit [`f9b8986612f68c0335563a42d9bf6576d4233800`](https://github.com/ishak6/Nexus-OS-3000-/commit/f9b8986612f68c0335563a42d9bf6576d4233800), four commits behind the evidence baseline.
  - **Build Debian-based live ISO:** passed.
  - **Boot live ISO in isolated QEMU VM:** failed.
  - The build job's GRUB timeout check and BIOS/UEFI El Torito checks passed.
- Build #39 ISO artifact: [`nexus-os-3000-iso`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/43761385453/artifacts/14180587860), 1,041,391,873 bytes. The ISO file SHA-256 printed by the build job is `3947cf2b9a37d5a9063fc9a18dbc6a86e52e89745ee34bcd45bf48d0a7ac7e68`; the GitHub artifact ZIP digest is `217bb267008a48dcb4f72c39aab959a36b6e6ffc88abb2fc1c407b8b27ec9a57`.
- Build #39 VM evidence: [`nexus-os-vm-smoke-evidence`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/43761385453/artifacts/14180818140), 52,839 bytes, GitHub artifact ZIP digest `696e221cc732c0a625b3e2df589b0616b2e05b4e463e924a1502ea07b08c7586`.
- VM failure evidence: BIOS QEMU TCG, 3 GiB RAM, 2 vCPUs, no NIC and no host disk. The test waited up to 252 seconds for XFCE. The retained screenshot shows the Debian GRUB menu with the live and fail-safe entries still present; OCR did not detect an XFCE desktop marker.
- The build verified `set timeout_style=menu` and `set timeout=5` in `binary/boot/grub/config.cfg`, but the VM remained at the menu. **The observed failure is confirmed; why the effective BIOS boot path did not leave the menu is not yet established.** The guest kernel/desktop console was not captured, so do not infer a kernel panic or XFCE crash.
- The combined commit-status query for the evidence baseline returned an empty status list. Treat that result as **no combined status available**, not as a PASS; Quality Checks #106 is the direct quality evidence.
- Build #39's ISO artifact is historical evidence for its own commit only. It does not prove that the evidence baseline builds or boots.
- This evidence refresh changes documentation only. Its follow-up quality run is tracked in the Actions tab; it does not constitute a new ISO build.

## Next verification tasks

1. Diagnose the GRUB timeout discrepancy using the exact GRUB configuration consumed by the BIOS boot path; retain the generated config and guest boot evidence.
2. Trigger a fresh ISO build on the evidence baseline and require the QEMU smoke test to reach the XFCE desktop before treating the live image as boot-verified.
3. Verify the LUMEN launcher and Pulse adapter inside the booted XFCE live session. Keep XFCE as the fallback; do not make LUMEN the default session or remove XFCE until LUMEN boot, integration and recovery are independently verified.
4. Verify sysctl values and systemd-sysctl status in the live VM; then verify AppArmor mode/profiles and ordinary networking.
5. Continue implementation and acceptance work for the installer, enforced Harness sandbox, Security Center, Privacy Center, networking controls, recovery and signed updates. Do not mark package presence or UI placeholders as completed functionality.

## Minimum VM test plan

1. Create a disposable VM and attach the ISO as virtual optical media.
2. Boot without attaching a host writable disk.
3. Confirm live desktop, keyboard, display and network.
4. Run `scripts/security-audit.sh` and archive its output.
5. Verify sysctl values using `docs/SECURITY_BASELINE.md`.
6. Inspect AppArmor mode and loaded profiles; do not infer from package installation.
7. Test shutdown and reboot.
8. Record failures and hardware/VM configuration before changing defaults.
9. Verify LUMEN launcher behavior under the XFCE fallback; do not remove XFCE until a separate LUMEN session passes boot and recovery tests.
10. Preserve QEMU logs, screenshots, OCR output, test reports and artifact checksums.

Never test an early image against the user's only copy of important data.

## Evidence and status policy

- `NOT STARTED`: no implementation evidence.
- `IN PROGRESS`: active implementation; acceptance incomplete.
- `IMPLEMENTED / UNVERIFIED`: code/configuration exists, but the acceptance test has not passed with recorded evidence.
- `VERIFIED`: implementation and defined acceptance tests passed, with commit and evidence references.
- `BLOCKED — APPROVAL REQUIRED`: a genuine constraint requires an explicit user-approved alternative. This is not completion.

No milestone is complete while any agreed requirement is pending, unverified, silently deferred or omitted without approval. An unavailable workflow-run API or empty status response must be reported as **UNCONFIRMED**, not PASS.
