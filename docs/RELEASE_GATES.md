# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | **PASS** on `899fd5234673bed42b515dbcad8858fa9973c796` via Quality Checks #119; current HEAD `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8` Quality Checks #121 is in progress. |
| ISO build | Non-empty ISO, SHA-256, BIOS/UEFI entries and retained artifact | **PASS** for Build #42 on `d650121e37926a65acf8968c079cbd81839615ff`; a new build on current HEAD is pending in Build #45. |
| VM boot | Boot log and screenshot showing the live desktop, with no host disk or network | **XFCE desktop visibly reached** in Build #42 evidence; the job failed because full-screen OCR missed the top-panel `Applications` label. A cropped-panel detector fix is committed; a new QEMU run is pending. |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false`. |
| Hardware basics | Display, keyboard, storage, network, audio and shutdown/reboot | Not tested on a declared hardware/VM matrix. |
| Security baseline | Runtime sysctl values and service status | Configuration is staged and static consistency tests pass; runtime state is not verified. |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics. |
| AppArmor | Enabled mode and loaded profile evidence | Not verified. Package installation is not proof of active enforcement. |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package is staged; live VM and physical network behavior are not verified. |
| Harness policy | Manifest validator and archive inspection tests | Static policy and archive-inspection tests pass. This is not runtime sandbox enforcement. |
| Sandbox runtime | Boundary tests, resource limits, revocation and escape-resistance evidence | Not implemented/verified. |
| Privacy controls | Data-flow inventory, permission enforcement and opt-in/revocation tests | Specification exists; runtime permission enforcement is not implemented. |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt 6/CMake prototype build and 8-second offscreen startup pass in Quality #111. It is not a complete shell or integrated desktop session; XFCE remains the fallback. |
| Recovery | Recovery environment, restore and rollback tests | Not implemented. |
| Updates | Signature verification, rollback and recovery tests | Not implemented. |
| Release integrity | SBOM, provenance, checksums, signed release and license inventory | An ISO SHA-256 exists for Build #39; complete SBOM, provenance and signed release evidence are not established. |

## Evidence update — 2026-11-19

- Current `main` head: [`c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`](https://github.com/ishak6/Nexus-OS-3000-/commit/c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8).
- [Build Nexus OS ISO #42](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44356766810) completed its ISO build, kernel/initrd checks, GRUB checks, BIOS/UEFI entry checks, and artifact uploads. The ISO artifact is 1,171,360,984 bytes; its Actions artifact ZIP digest is `a31629ad200298db499fe3c8fabf4f8e626cd4263045ca936fd02ac29b15babe`.
- Build #42's QEMU job returned failure because the smoke test searched for `Applications` in the full-screen Tesseract PSM 6 output. I downloaded and inspected the retained `desktop.ppm` (1280x800): it visibly shows the XFCE top panel, `Applications` menu, `Home` and `File System` desktop icons, and the bottom panel/dock. The captured full-screen OCR contained `Home` and `File System` but omitted the small top-panel text. This is a detector false negative, not evidence that the guest failed to reach XFCE.
- Reprocessing the exact Build #42 screenshot with a 45-pixel top-panel crop and Tesseract PSM 6 returned `Applications`; the combined desktop-icon and top-panel detection passed locally.
- Added `scripts/crop-ppm-top-panel.py`, five unit tests in `scripts/tests/test-crop-ppm-top-panel.py`, and updated the VM smoke test to preserve and OCR the top panel separately. The existing VM smoke-test regression test and Quality workflow now include these checks.
- [Quality Checks #119](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576469977) passed on `899fd5234673bed42b515dbcad8858fa9973c796`. [Quality Checks #121](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664664) is running on current HEAD `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`; repository, Python, Harness, Pulse, and VM tooling tests have passed, while Qt dependency installation is still in progress.
- [Build Nexus OS ISO #45](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664860) is queued on current HEAD. It now runs the VM smoke-test preflight before installing the ISO build toolchain. The corrected detector is not yet verified in a fresh QEMU run.
- XFCE remains the fallback. Build #42 proves XFCE live desktop startup only; it does not prove LUMEN session integration or a LUMEN desktop boot.
## Historical evidence snapshot — 2026-11-17

- Repository: `ishak6/Nexus-OS-3000-`
- Current main head at this snapshot: [`f8fd3970efcdcabbe35b7de65208977ae01b4883`](https://github.com/ishak6/Nexus-OS-3000-/commit/f8fd3970efcdcabbe35b7de65208977ae01b4883).
- [Quality Checks #111](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44116445716) passed on that exact main commit. Repository/policy checks, Python syntax, 11 Harness tests, 5 Pulse tests, 2 security-baseline tests, GRUB and VM-input regression tests, Qt 6/CMake LUMEN build, and the 8-second offscreen startup smoke test all passed.
- [Quality Checks #110](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44116314858) initially failed because its new guard also matched the explanatory comment containing `--linux-packages none`. The guard was narrowed to active option lines in commit `f8fd3970efcdcabbe35b7de65208977ae01b4883`; Quality #111 then passed.
- The boot fix is in [commit `f485fe75fc893aea51b041165061a2f1b144a098`](https://github.com/ishak6/Nexus-OS-3000-/commit/f485fe75fc893aea51b041165061a2f1b144a098), the parent of the current main commit. It removes the live-build option that disabled kernel staging and adds a validator for every active GRUB kernel/initrd reference. Regression tests cover valid staging, missing kernel, missing initrd, and mismatched kernel/initrd pairs.
- [Build Nexus OS ISO #41](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44116314704) is running on that parent commit. The LUMEN build/staging step passed; the `lb build` step is still running. The kernel/initrd staging validator, ISO checksums, artifact uploads and QEMU VM boot job are not yet complete. Do not claim this build or VM boot passed until the run reports completion.
- Previous [Build Nexus OS ISO #40](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489) completed the ISO build and extracted GRUB evidence, but its QEMU VM job failed. The extracted GRUB menu references `/live/vmlinuz-6.12.117+deb13-amd64`; the VM OCR reports that file is missing and then `you need to load the kernel first`. Build #40 passed `--linux-packages none` to live-build. Debian's live-build documentation says this disables the kernel installation step, while `binary_linux-image` is the stage that copies the kernel into the live image. The explicit chroot package list did not compensate for the disabled binary staging step. This is a kernel-staging/boot-media failure, not evidence of an XFCE crash.
- Build #40 ISO artifact: [`nexus-os-3000-iso`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489/artifacts/14340767883), 1,041,390,567 bytes; artifact ZIP digest `dab1234c7ea9aefc51f7c990fd2bd19448f86592adb1cda78e3f1cc704032a70`.
- Build #40 extracted GRUB evidence: [`nexus-os-grub-boot-evidence`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489/artifacts/14340598020), 1,085 bytes; artifact ZIP digest `1f2de5248233f91b1c4a59bd767ad0115d6811148e1413196dc56814474ffcc7`.
- Build #40 VM evidence: [`nexus-os-vm-smoke-evidence`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489/artifacts/14342156370), 82,582 bytes; artifact ZIP digest `ce11a88dc6a2f129e31285dce4d3ead465813ffe222572a88b9fca336a9ac3dc`.
- The repository has one branch (`main`), no published GitHub releases, and branch protection is not enabled. XFCE remains the fallback; LUMEN is still a prototype, not a verified desktop session.

## Next verification tasks

1. Run the ISO workflow with live-build kernel staging enabled; require the generated GRUB kernel/initrd path validator to pass before uploading the ISO.
2. Re-run the isolated BIOS QEMU boot and require the default GRUB entry to load the kernel and reach XFCE without manual key injection. If it fails, inspect the new guest-visible evidence before changing defaults.
3. Require the QEMU smoke test to reach the XFCE desktop. Then verify the LUMEN launcher and Pulse adapter inside that live session. Keep XFCE as fallback; do not make LUMEN the default or remove XFCE until LUMEN boot, integration and recovery are independently verified.
4. Verify sysctl values and systemd-sysctl status in the live VM; then verify AppArmor mode/profiles and ordinary networking.
5. Continue implementation and acceptance work for the installer, enforced Harness sandbox, Security Center, Privacy Center, networking controls, recovery and signed updates. Package presence or UI placeholders are not completion evidence.
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
