# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a secure or production-ready OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | **PASS** for the ISO code candidate `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8` via [Quality Checks #121](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664664). Documentation-only evidence updates were checked by [#123](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576986347) and [#124](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44783857554); [#125](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784033491) tracks the next documentation-only update. |
| ISO build | Non-empty ISO, SHA-256, BIOS/UEFI entries and retained artifact | **PASS** for [Build #45](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860), built from code commit `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`; ISO SHA-256 is recorded below. |
| VM boot | Boot log and screenshot showing the live desktop, with no host disk or network | **PASS** for Build #45: isolated QEMU BIOS boot reached the XFCE desktop on attempt 15. UEFI boot has not been exercised in QEMU. |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false`. |
| Hardware basics | Display, keyboard, storage, network, audio and shutdown/reboot | Not tested on a declared hardware/VM matrix. |
| Security baseline | Runtime sysctl values and service status | Configuration is staged and static consistency tests pass; runtime state is not verified. |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics. |
| AppArmor | Enabled mode and loaded profile evidence | Not verified. Package installation is not proof of active enforcement. |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package is staged; live VM and physical network behavior are not verified. |
| Harness policy | Manifest validator and archive inspection tests | Static policy and archive-inspection tests pass. This is not runtime sandbox enforcement. |
| Sandbox runtime | Boundary tests, resource limits, revocation and escape-resistance evidence | Not implemented/verified. |
| Privacy controls | Data-flow inventory, permission enforcement and opt-in/revocation tests | Specification exists; runtime permission enforcement is not implemented. |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt 6/CMake prototype build and 8-second offscreen startup pass in Quality #123. LUMEN has not been launched/verified inside the live XFCE session and is not an integrated desktop shell; XFCE remains the fallback. |
| Recovery | Recovery environment, restore and rollback tests | Not implemented. |
| Updates | Signature verification, rollback and recovery tests | Not implemented. |
| Release integrity | SBOM, provenance, checksums, signed release and license inventory | Build #45 ISO SHA-256 and Actions artifact ZIP digests are recorded below. Complete SBOM, provenance, signed release and license inventory are not established. |

## Current evidence update — 2026-11-20

- Current `main` head at the time of this update: [`d2f2537cdd0f5ea16929f7c3eef3001f0f2b59a3`](https://github.com/ishak6/Nexus-OS-3000-/commit/d2f2537cdd0f5ea16929f7c3eef3001f0f2b59a3). This is a documentation snapshot commit; Build #45 tested the immediately preceding code commit `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`.
- [Quality Checks #123](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576986347) passed on documentation commit `d2f2537`; [Quality Checks #124](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44783857554) passed on documentation commit `1215ed8`. Both repository-checks jobs completed successfully. [Quality Checks #125](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784033491) is the validation run for the subsequent documentation snapshot commit `412573d`.
- [Build Nexus OS ISO #45](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860) completed successfully on code commit `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`. Both jobs passed: `Build Debian-based live ISO` and `Boot live ISO in isolated QEMU VM`.
- Build #45 passed VM tooling preflight, Debian Trixie live-build dependency installation, live configuration, LUMEN compile/staging, live-config package checks, ISO creation, GRUB kernel/initrd staging validation, GRUB timeout validation, BIOS/UEFI El Torito entry validation, checksum generation, GRUB configuration extraction, and artifact uploads.
- The raw ISO is `live-image-amd64.hybrid.iso`. Its SHA-256, recorded by the build log, is `94a1e9c7524dc2bee250fdd80dd594ce8bec6165512f641e4a12044e21786a38`. The ISO contains 577,409 2,048-byte sectors (1,182,533,632 bytes).
- ISO artifact: [`nexus-os-3000-iso`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860/artifacts/14557279742), artifact ID `14557279742`; Actions artifact ZIP size 1,171,308,864 bytes; ZIP digest `sha256:6c63fe5e3bb0e15c0df67351c357d80a2f6b672f67b3b6918bd4b2cc8da97059`. The ZIP digest is not the raw ISO SHA-256.
- GRUB evidence: [artifact ID `14558151735`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860/artifacts/14558151735); ZIP digest `sha256:7d1c9a7d985c4ae0f60cda51fb6c3bc9fc77c36f51ff66a255d3810fa7f525e8`.
- VM evidence: [artifact ID `14557134339`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860/artifacts/14557134339); ZIP digest `sha256:c1424e7de327dc9ef14a14ad51068521b7bfacc5d9362ae96d4203224e63c921`. The archive contains `desktop.ppm`, `desktop-top-panel.ppm`, `grub-after-timeout.ppm`, OCR outputs, `qemu.log`, and `result.txt`.
- The Build #45 VM result states: `PASS: QEMU BIOS boot reached the XFCE desktop.` It succeeded on attempt 15 in QEMU TCG with a read-only ISO, no host disk and no network. I downloaded and inspected the 1280x800 screenshot: the XFCE Applications panel, Home and File System desktop icons, and bottom panel/dock are visible. The cropped top-panel OCR contains `Applications`.
- Build #42's earlier VM job failure was an OCR false negative: the screenshot already showed XFCE, but full-screen OCR missed the small top-panel label. The 45-pixel top-panel crop and combined detection now pass in the fresh Build #45 VM run. This is not evidence of an XFCE boot failure.
- Quality #123 also passed the Qt 6/CMake LUMEN prototype build and 8-second offscreen startup smoke test. That test does not establish LUMEN startup in the live XFCE session, desktop integration, or a LUMEN session boot.
- The repository has one branch (`main`), no published GitHub releases, and branch protection is disabled. XFCE remains the fallback; do not remove it or make LUMEN the default until LUMEN launch, session integration and recovery are independently verified.

## Historical evidence snapshot — 2026-11-19

- [Quality Checks #119](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576469977) passed on `899fd5234673bed42b515dbcad8858fa9973c796`; [Quality Checks #121](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664664) passed on code commit `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`; [Quality Checks #122](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576859678) passed on `d6d131b43671b8b10c161565de9965b589bd7512`.
- Build #42's screenshot demonstrated that XFCE had started despite the initial full-screen OCR false negative. The detector correction added `scripts/crop-ppm-top-panel.py`, five regression tests in `scripts/tests/test-crop-ppm-top-panel.py`, and separate top-panel OCR in `scripts/vm-smoke-test.sh`.
- [Build #42](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44356766810) produced an ISO but its QEMU job failed only because the old detector missed the small top-panel label. Build #45 is the successful fresh boot verification for the corrected detector.

## Historical evidence snapshot — 2026-11-17

- The kernel staging fix is in [commit `f485fe75fc893aea51b041165061a2f1b144a098`](https://github.com/ishak6/Nexus-OS-3000-/commit/f485fe75fc893aea51b041165061a2f1b144a098). It removes the live-build option that disabled kernel staging and adds a validator for GRUB kernel/initrd references.
- Previous [Build #40](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489) failed because GRUB referenced `/live/vmlinuz-6.12.117+deb13-amd64`, which was absent. The build passed `--linux-packages none`, disabling the live-build kernel staging step. This was a kernel-staging/boot-media failure, not an XFCE crash.
- [Quality Checks #111](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44116445716) passed after narrowing a guard that had incorrectly matched an explanatory comment; the preceding [Quality #110](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44116314858) failed for that guard false positive.

## Next verification tasks

1. Launch `nexus-lumen` from the live XFCE session and capture process/window evidence; verify the Pulse adapter against real guest telemetry.
2. Verify sysctl values and systemd-sysctl status in the live VM; then verify AppArmor mode/profiles and ordinary networking.
3. Implement and test the guided installer, enforced Harness sandbox, Security Center, Privacy Center, recovery and signed updates. Package presence or UI placeholders are not completion evidence.
4. Add UEFI QEMU boot evidence and a declared hardware/VM compatibility matrix.
5. Establish SBOM, provenance, signed release and license inventory before release.

## Minimum VM test plan

1. Create a disposable VM and attach the ISO as virtual optical media.
2. Boot without attaching a host writable disk.
3. Confirm live desktop, keyboard and display; verify network separately because the current smoke test deliberately has no NIC.
4. Run `scripts/security-audit.sh` and archive its output.
5. Verify sysctl values using `docs/SECURITY_BASELINE.md`.
6. Inspect AppArmor mode and loaded profiles; do not infer from package installation.
7. Launch `nexus-lumen` in the live XFCE session and capture startup, window and telemetry evidence.
8. Test shutdown and reboot.
9. Keep XFCE as fallback until a separate LUMEN session passes boot, integration and recovery tests.
10. Preserve QEMU logs, screenshots, OCR output, test reports and artifact checksums.

Never test an early image against the user's only copy of important data.

## Evidence and status policy

- `NOT STARTED`: no implementation evidence.
- `IN PROGRESS`: active implementation; acceptance incomplete.
- `IMPLEMENTED / UNVERIFIED`: code/configuration exists, but the acceptance test has not passed with recorded evidence.
- `VERIFIED`: implementation and defined acceptance tests passed, with commit and evidence references.
- `BLOCKED — APPROVAL REQUIRED`: a genuine constraint requires an explicit user-approved alternative. This is not completion.

No milestone is complete while any agreed requirement is pending, unverified, silently deferred or omitted without approval. An unavailable workflow-run API or empty status response must be reported as **UNCONFIRMED**, not PASS.
