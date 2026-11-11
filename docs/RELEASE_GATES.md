# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a bootable or secure OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass | Implemented; CI evidence per commit |
| ISO build | Non-empty ISO and SHA-256 artifact | Pending |
| VM boot | Boot log and screenshot; no installer/destructive disk action | Not tested |
| Hardware basics | Display, keyboard, storage, network, audio | Not tested |
| Security baseline | Runtime sysctl values and service status | Staged; not verified |
| AppArmor | Enabled mode and loaded profile evidence | Not verified |
| Harness policy | Manifest validator and archive inspection tests | Metadata/static checks only |
| Sandbox runtime | Boundary tests, resource limits, revocation | Not implemented |
| Privacy controls | Data-flow inventory and opt-in tests | Specification only |
| LUMEN desktop | Native shell usability and accessibility tests | Specification only |
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
