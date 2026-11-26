## Monitoring follow-up — 2026-11-26

- Current `main` HEAD before this documentation update: `d38b3326c6c367bc42474368f79648da09e84f00`. The code/workflow fix candidate is `d861ecbc7b87c25641c458e7e418dd402219fc32`; subsequent `d38b332` is documentation-only.
- [Quality Checks #138](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45842142207) passed on `d861ecb`; [Quality #139](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45842205068) passed on `d38b332`. Both include the new marker-checker test and the Qt/QML LUMEN build/offscreen startup.
- [Build Nexus OS ISO #50](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45842142177) is still running on `d861ecb`. VM preflight, the new OCR marker regression tests, Debian Trixie dependency installation, live configuration, LUMEN staging, and live-config package verification passed. The `Build ISO` step was in progress at the last check; no #50 ISO artifact or VM result is yet verified.
- The #47 ISO and VM artifacts remain available. Raw ISO SHA-256: `6a568973d061b1ead2236797d3b23b0db68a67d41a52cd483e18bf4dd4ca2701`; raw size 1,172,379,268 bytes. #47's visible LUMEN UI screenshot is valid evidence, although the old detector failed because foreground LUMEN obscured desktop icons.
- The new marker checker and five regression tests passed locally (5/5), and the checker passed against the actual Build #47 `desktop.txt`, `desktop-top-panel.txt`, and `lumen-window.txt` extracted from artifact `15036468992`.
- Intermediate Quality #132–#135 and ISO #49 failures occurred during the multi-commit rollout: the VM script switched to the new marker helper before the static VM test was updated, so the old test still required Home/File System OCR strings. The static test was updated in `d6d476d`; helper tests were then added to both Quality and ISO preflight. Quality #136–#139 passed, and ISO #50's preflight passed. These are resolved rollout failures, not current code failures.
- Latest main still requires independent verification of LUMEN session integration, UEFI QEMU boot, installer, runtime Harness sandbox, Security/Privacy enforcement, networking runtime, recovery, signed updates and release provenance/SBOM. Keep XFCE fallback.

## Current evidence update — 2026-11-26

- Current main after the detector correction and CI wiring: `d861ecbc7b87c25641c458e7e418dd402219fc32`; the correction was made across commits `c0f8ae7`, `8c86ed6`, `7a3edaa`, `de14bce`, `d6d476d`, `fa09fb1`, and `d861ecb`.
- [Quality Checks #131](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45643806771) passed on the previous `aa09ec17` documentation HEAD. The new detector/test/workflow changes are now committed and have triggered fresh Quality and ISO workflows; their results are pending at this update.
- [Build #47](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45642268194) built and uploaded its ISO successfully, but its QEMU job failed the old desktop marker predicate. The ISO build, kernel/initrd checks, GRUB/boot-entry validation and artifact uploads all passed.
- **Confirmed #47 false-negative cause:** the actual 1280x800 VM screenshot shows the XFCE top panel with Applications and Debian Live user, plus a foreground Nexus LUMEN window displaying Overview, the workspace card, CPU LOAD, MEMORY and NETWORK cards. Because the foreground LUMEN window covers the desktop, OCR cannot see Home/File System icons. The old detector incorrectly required those occluded icons. This is a VM test predicate failure; the screenshot proves the ISO booted and LUMEN launched visibly.
- Build #47 raw ISO SHA-256 from the build log: `6a568973d061b1ead2236797d3b23b0db68a67d41a52cd483e18bf4dd4ca2701`; raw ISO size 1,172,379,268 bytes. ISO artifact [ID 15037355749](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45642268194/artifacts/15037355749), Actions ZIP digest `sha256:5c7b323e7aa694cf879ddc7bb3f9df0117bb1047b90897571b94e6235eecb1a0` (ZIP digest is not the raw ISO digest).
- Build #47 VM evidence [artifact ID 15036468992](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45642268194/artifacts/15036468992), 121,508 bytes, ZIP digest `sha256:1af42df0dd19f5d5d816720d0565a51d764291edfb0a828809ee43a84d9acc36`. It includes desktop and top-panel screenshots/OCR, LUMEN sparse OCR, QEMU log and result. The final OCR confirms the visible LUMEN content markers even though Home/File System are absent.
- New fix: added `scripts/verify-vm-desktop-markers.py`. It requires the XFCE Applications/Whisker menu and Debian Live user panel markers, the Nexus LUMEN title, and at least two visible workspace/card text markers. It deliberately does not require desktop icons that the foreground app can occlude.
- Added five regression tests in `scripts/tests/test-verify-vm-desktop-markers.py`, including a Build #47-style OCR fixture that must pass without Home/File System and negative tests for missing panel, live-user, title, or content markers. Updated the VM smoke-test static checks, Quality workflow, and ISO workflow preflight/path filters to run the helper tests.
- Next verification: wait for the fresh CI and ISO run triggered by `d861ecb`; confirm the new OCR predicate passes against a fresh QEMU boot. Do not claim a new successful ISO/VM run until that run completes.
- Other release gates remain: LUMEN default-session integration, UEFI QEMU boot, installer, runtime Harness sandbox, Security/Privacy enforcement, networking runtime, recovery, signed updates and release SBOM/provenance. Keep XFCE fallback.

## Current evidence update — 2026-11-25

- Current `main` HEAD at this check: [`f3a09c9e8691a56a29027702cd3a50142d9138b4`](https://github.com/ishak6/Nexus-OS-3000-/commit/f3a09c9e8691a56a29027702cd3a50142d9138b4). Latest commit requires visible LUMEN workspace/card content in the XFCE VM integration test.
- [Quality Checks #130](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45642268205) passed on `f3a09c9`: commit whitespace, repository checks, Harness/Pulse tests, shell/regression tests, Qt 6/CMake LUMEN build, and the 8-second offscreen startup smoke test all passed.
- [Quality Checks #128](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45638892790) failed only at `Check commit whitespace` on `ff1d3cb`. The exact correction was removal of one trailing blank line from `scripts/tests/test-live-config-packages.sh` in [commit `88428a5`](https://github.com/ishak6/Nexus-OS-3000-/commit/88428a5d94f18cfb1b77ca734a81eb6d0ee18862); Quality #129 passed after that fix.
- [Build Nexus OS ISO #46](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45638892698) passed both jobs on code commit `ff1d3cb2197e169e294b1ced3f338668387498e5`: ISO build and isolated QEMU BIOS VM smoke test. The #46 VM test required the XFCE desktop plus the LUMEN window/title marker; it did not yet require the stricter visible workspace/card-content marker added in #130.
- Build #46 artifacts: ISO [artifact ID 15033638080](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45638892698/artifacts/15033638080), 1,172,260,300 bytes, Actions ZIP digest `sha256:d42d5d78de1ebdb6a8fda651926c5187b7cc3af58caa13bb66e09a796c2552d7`; GRUB evidence [15035172341](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45638892698/artifacts/15035172341), ZIP digest `sha256:28d617d0d97154ac1c400b5c8713c24f2787a61d4ce840650f5b806d89d21018`; VM evidence [15035288624](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45638892698/artifacts/15035288624), 125,890 bytes, ZIP digest `sha256:79c8e1f0591036432029c07a84adc82d9e0464578be473815aeeb0a20bc21c9c`. These are artifact ZIP digests, not a raw ISO SHA-256.
- The LUMEN autostart entry is XFCE-scoped and uses `/usr/bin/env QT_QUICK_BACKEND=software /usr/bin/nexus-lumen` for predictable Qt Quick rendering in QEMU TCG. This is a VM compatibility setting, not a performance claim.
- [Build Nexus OS ISO #47](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/45642268194) is **IN PROGRESS** on current commit `f3a09c9`. At the latest API check, dependency/configuration, LUMEN staging, and live-config package verification passed; ISO compilation was running. No #47 artifact or QEMU result was available yet.
- Current LUMEN gate: Build #46 provides evidence that the app/window autostarts in XFCE; #47 is the first run requiring visible workspace/card text such as `A calmer space`, `CPU LOAD`, or `NEXUS OS 3000`. Until #47's QEMU job passes, visible LUMEN UI content remains **PENDING**. XFCE remains the fallback.

# Release Gates and Verification Matrix

A release claim requires repeatable evidence. A green workflow alone does not certify a secure or production-ready OS.

| Gate | Required evidence | Current state |
|---|---|---|
| Repository quality | CI checks and unit tests pass on the exact candidate commit | **PASS** for the ISO code candidate `c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8` via [Quality Checks #121](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576664664). Documentation-only follow-ups also passed: [#123](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576986347), [#124](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44783857554), [#125](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784033491), and [#126](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784221202). |
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

- Build #45's ISO code candidate is [`c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8`](https://github.com/ishak6/Nexus-OS-3000-/commit/c8cf2ba620fd20b29ce8b5f84d8c968e2dc5f1d8). The five later commits through `6b51b92571c41e848741f73993dbf4e0413a385a` changed only `docs/RELEASE_GATES.md`; they do not change the source used to build ISO #45.
- [Quality Checks #123](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44576986347), [#124](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44783857554), [#125](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784033491), and [#126](https://github.com/ishak6/Nexus-OS-3000-/actions/runs/44784221202) all passed on their respective documentation-only commits. These changes do not modify the ISO code candidate.
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
