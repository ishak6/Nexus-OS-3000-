# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass | Implemented; CI evidence per commit |
| ISO build | Non-empty ISO and SHA-256 artifact | Build #32 produced a 1,013,689,194-byte ISO; BIOS/UEFI El Torito entries and SHA-256 verification passed and the artifact was uploaded. Build #33 includes the GRUB timeout correction and is in progress; its artifact is pending |
| Installer | Guided installation, safe disk selection and install verification | Not implemented; the live-build workflow sets `--debian-installer false` |
| VM boot | Boot log and screenshot; no installer/destructive disk action | QEMU BIOS test on Build #32 remained at the GRUB live menu for the full 252-second observation window. The screenshot and OCR show the GRUB menu, not an ISOLINUX screen. Root cause: the workflow customized only config/bootloaders/isolinux while lb config selects grub-pc and grub-efi. A GRUB config override now sets timeout_style=menu and timeout=5, with regression tests and a post-build check of binary/boot/grub/config.cfg; Build #33 is rebuilding with the GRUB timeout correction; automatic desktop boot remains unverified |
| Hardware basics | Display, keyboard, storage, network, audio | Not tested |
| Security baseline | Runtime sysctl values and service status | Staged; not verified |
| Security Center | Enforced controls, permission UI and firewall policy | No integrated Security Center; the current audit script is read-only diagnostics |
| AppArmor | Enabled mode and loaded profile evidence | Not verified |
| Networking | NetworkManager boot, DHCP/DNS, Wi-Fi and firewall tests | NetworkManager package staged; VM network not tested |
| Harness policy | Manifest validator and archive inspection tests | Metadata/static checks only |
| Sandbox runtime | Boundary tests, resource limits, revocation | Not implemented |
| Privacy controls | Data-flow inventory and opt-in tests | Specification only; runtime permission enforcement is not implemented |
| LUMEN desktop | Native shell build, startup, session integration and accessibility tests | Qt/QML prototype builds and passes the offscreen startup smoke test in CI; it is not integrated as the desktop session |
| Recovery | Recovery environment, restore and rollback tests | Not implemented |
| Updates | Signature verification, rollback and recovery tests | Not implemented |
| Release integrity | SBOM, provenance, checksums and signed release | Not implemented |

## Minimum VM test plan

1. Create a disposable VM and attach the ISO as virtual optical media.
2. Boot without attaching a host writable disk.
3. Confirm live desktop, keyboard, display and network.
4. Run scripts/security-audit.sh and archive its output.
5. Verify sysctl values using docs/SECURITY_BASELINE.md.
6. Inspect AppArmor mode and loaded profiles; do not infer from package installation.
7. Test shutdown and reboot.
8. Record failures and hardware/VM configuration before changing defaults.

Never test an early image against the user's only copy of important data.
