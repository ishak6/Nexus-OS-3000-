# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | **PASS** on `e30f95e69f66093488311a3e3eff4ec3e8650398` via Quality Checks #109. |
| ISO build | Non-empty ISO, SHA-256, BIOS/UEFI entries and retained artifact | **PASS for Build #40's build job only** on `e30f95e69f66093488311a3e3eff4ec3e8650398`; ISO and extracted GRUB evidence artifacts were uploaded. |
| VM boot | Boot log and screenshot showing the live desktop, with no host disk or network | **FAIL** in Build #40. GRUB reports `/live/vmlinuz-6.12.117+deb13-amd64` missing and cannot load the kernel. The build used `--linux-packages none`, which disables live-build's kernel staging step; fix and rebuild required. |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false`. |
| Hardware basics | Display, keyboard, storage, network, audio and shutdown/reboot | Not tested on a declared hardware/VM matrix. |
| Security baseline | Runtime sysctl values and service status | Configuration is staged and static consistency tests pass; runtime state is not verified. |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics. |
| AppArmor | Enabled mode and loaded profile evidence | Not verified. Package installation is not proof of active enforcement. |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package is staged; live VM and physical network behavior are not verified. |
| Harness policy | Manifest validator and archive inspection tests | Static policy and archive-inspection tests pass. This is not runtime sandbox enforcement. |
| Sandbox runtime | Boundary tests, resource limits, revocation and escape-resistance evidence | Not implemented/verified. |
| Privacy controls | Data-flow inventory, permission enforcement and opt-in/revocation tests | Specification exists; runtime permission enforcement is not implemented. |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt 6/CMake prototype build and 8-second offscreen startup pass in Quality #109. It is not a complete shell or integrated desktop session; XFCE remains the fallback. |
| Recovery | Recovery environment, restore and rollback tests | Not implemented. |
| Updates | Signature verification, rollback and recovery tests | Not implemented. |
| Release integrity | SBOM, provenance, checksums, signed release and license inventory | An ISO SHA-256 exists for Build #39; complete SBOM, provenance and signed release evidence are not established. |

## Current evidence snapshot — 2026-11-17

- Repository: `ishak6/Nexus-OS-3000-`
- Main head at the start of this diagnostic/fix pass: [`e30f95e69f66093488311a3e3eff4ec3e8650398`](https://github.com/ishak6/Nexus-OS-3000-/commit/e30f95e69f66093488311a3e3eff4ec3e8650398).
- [Quality Checks #109](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994530) passed on that exact commit. The job passed repository/policy checks, Python syntax, 11 Harness tests, 5 Pulse tests, 2 security-baseline tests, GRUB and VM-input regression tests, Qt 6/CMake LUMEN build, and the 8-second offscreen startup smoke test.
- [Build Nexus OS ISO #40](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489) ran on the same commit:
  - **Build Debian-based live ISO:** passed; BIOS and UEFI El Torito entries were detected.
  - **Extract effective GRUB configuration:** passed; the artifact retained the exact `/boot/grub/config.cfg` and `/boot/grub/grub.cfg` files.
  - **Boot live ISO in isolated QEMU VM:** failed.
- **Confirmed boot blocker:** the extracted GRUB menu references `/live/vmlinuz-6.12.117+deb13-amd64` and its matching initrd. VM OCR reports `error: file ... not found` followed by `you need to load the kernel first`. The build workflow passed `--linux-packages none` to live-build. Debian's live-build documentation states that this disables the kernel installation step; the separate `binary_linux-image` stage copies the kernel into the live image. The chroot package list installing `linux-image-amd64` does not override the disabled live-build kernel stage. This explains the missing `/live` kernel path; the evidence does not indicate an XFCE crash.
- This fix removes the disabling option and adds a pre-artifact validator that checks every active GRUB kernel/initrd reference against the actual `binary/live` files. Regression tests cover valid staging, missing kernel, missing initrd, and mismatched kernel/initrd pairs. These checks are pending the next Actions run.
- Build #40 ISO artifact: [`nexus-os-3000-iso`](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44110994489/artifacts/14340767883), 1,041,390,567 bytes; GitHub artifact ZIP digest `dab1234c7ea9aefc51f7c990fd2bd19448f86592adb1cda78e3f1cc704032a70`.
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
