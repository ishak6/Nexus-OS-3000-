# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | Workflow defines repository, Python, Harness, Pulse, shell and Qt checks. The latest previously inspected HEAD had an empty combined-status response; current CI result is **unconfirmed** until a run/check result is retrieved. |
| ISO build | Non-empty ISO, SHA-256, BIOS/UEFI entries and retained artifact | Historical record: Build #32 produced a 1,013,689,194-byte ISO and its BIOS/UEFI El Torito checks and checksum passed. This is historical evidence only; it does not prove the current HEAD builds. |
| VM boot | Boot log and screenshot showing the live desktop, with no host disk or network | Historical Build #32 did not reach the desktop and remained at the GRUB menu. A GRUB timeout correction and regression checks were added afterwards. The current HEAD's VM result is **unconfirmed**; do not infer success from the workflow definition. |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false`. |
| Hardware basics | Display, keyboard, storage, network, audio and shutdown/reboot | Not tested on a declared hardware/VM matrix. |
| Security baseline | Runtime sysctl values and service status | Configuration is staged; runtime state is not verified. |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics. |
| AppArmor | Enabled mode and loaded profile evidence | Not verified. Package installation is not proof of active enforcement. |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package is staged; live VM and physical network behavior are not verified. |
| Harness policy | Manifest validator and archive inspection tests | Metadata/static inspection and policy foundations exist; runtime sandbox enforcement is not implemented. |
| Sandbox runtime | Boundary tests, resource limits, revocation and escape-resistance evidence | Not implemented/verified. |
| Privacy controls | Data-flow inventory, permission enforcement and opt-in/revocation tests | Specification exists; runtime permission enforcement is not implemented. |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt/QML application prototype and CI build/smoke-test definitions exist. It is not a complete shell or integrated desktop session; XFCE remains the fallback. Current commit-specific CI evidence is unconfirmed. |
| Recovery | Recovery environment, restore and rollback tests | Not implemented. |
| Updates | Signature verification, rollback and recovery tests | Not implemented. |
| Release integrity | SBOM, provenance, checksums, signed release and license inventory | ISO checksum workflow exists; complete SBOM, provenance and signed release evidence are not yet established. |

## Current evidence snapshot

- Repository: `ishak6/Nexus-OS-3000-`
- Last inspected commit before this register was added: `868ad52293c9ac6e9a5d09427270658b73dd2584`.
- The combined commit-status query for that SHA returned `statuses: []`. This means no commit status was available from that query; it is **not** a PASS.
- The quality workflow defines Python compile/tests, Harness/Pulse unit tests, shell syntax/regression tests, Qt/CMake compilation and an offscreen LUMEN startup smoke test.
- The ISO workflow defines Debian Trixie live-build, LUMEN staging, ISO boot-entry/checksum validation, artifact upload and a QEMU VM boot smoke test.
- Workflow definitions and configured test commands are not proof that a run executed or passed. Record exact run IDs, job results, logs and artifact references when available.
- Requirement-level progress is tracked in [REQUIREMENT_TRACEABILITY.md](REQUIREMENT_TRACEABILITY.md). That register is the authoritative checklist; this file is the release acceptance summary.

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
- `BLOCKED — APPROVAL REQUIRED`: a genuine constraint requires an explicit user-approved alternative.

No milestone is complete while any agreed requirement is pending, unverified, silently deferred or omitted without approval. An unavailable workflow-run API or empty status response must be reported as **UNCONFIRMED**, not PASS.
