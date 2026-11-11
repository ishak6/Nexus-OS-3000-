# Nexus OS 3000

**Next-Generation Privacy-First Operating System**

Nexus OS 3000 is an experimental, Debian-based operating-system project focused on a distinctive workspace-first desktop, transparent security controls, reversible automation, and privacy by default.

> **Project status:** Early foundation. The current repository is not yet a complete operating system. The first milestone is a reproducible amd64 live ISO that can be tested in a virtual machine.

## Project principles

- Privacy by default; collect and transmit as little data as possible.
- Least privilege and explicit consent for sensitive operations.
- Untrusted projects and scripts are inspected before execution and run with isolation.
- Security controls must be enforced by the OS and kernel, not by UI promises.
- Changes made by automation should be previewable, auditable, and reversible where possible.
- No fake telemetry, fake malware detections, or claims of perfect protection.

## Planned components

| Component | Responsibility |
|---|---|
| Nexus LUMEN | Native desktop shell and accessibility |
| Living Space | Task-oriented workspaces |
| Nexus Orbit | Window and workspace navigation |
| Nexus Core | Local command and orchestration surface |
| Nexus Harness | Application capability policy and runtime coordination |
| Security Center | Permissions, isolation, firewall, verification, recovery |
| Privacy Center | Data controls, network privacy, audit and export |
| Nexus Pulse | Evidence-based system telemetry |

## Implemented repository foundations

- Debian Trixie amd64 live-build configuration and GitHub Actions workflows.
- Staged sysctl security baseline with documented VM verification.
- Harness v1 capability manifest, deny-by-default policy and metadata validator.
- Static ZIP/TAR inspection that never extracts or executes imported content.
- Read-only security posture diagnostic script.
- Automated policy and archive-inspection tests in CI.

These are foundations, not a complete OS security stack. Archive inspection is not antivirus or proof that a file is safe. The Harness does not yet launch applications or enforce kernel isolation.

## Documentation

- Architecture: docs/ARCHITECTURE.md
- Threat model: docs/THREAT_MODEL.md
- Security baseline: docs/SECURITY_BASELINE.md
- Harness policy: docs/HARNESS_POLICY.md
- LUMEN UX specification: docs/NEXUS_LUMEN_UX.md
- Privacy model: docs/PRIVACY_MODEL.md
- Release gates: docs/RELEASE_GATES.md
- Roadmap: docs/ROADMAP.md

## Build the first live ISO

The initial build targets **Debian 13 (trixie), amd64**.

1. Open the repository's Actions tab.
2. Select Build Nexus OS ISO.
3. Choose Run workflow.
4. Wait for the build to finish.
5. Download the nexus-os-3000-iso artifact and boot it in a disposable virtual machine.

The first image is a development live environment, not a production release or a safe-to-install daily-driver OS.

## Local checks

    python3 harness/policy/validate_manifest.py harness/examples/hello-app.manifest.json
    python3 -m unittest discover -s harness/tests -v
    bash -n scripts/security-audit.sh

The security audit script is read-only and reports observed state; it does not modify firewall, sysctl or service settings.

## Security baseline

A conservative sysctl baseline is staged in the live image configuration. It is not yet runtime-verified; see docs/SECURITY_BASELINE.md. Package presence alone is not proof that a security control is active.

## Release readiness

See docs/RELEASE_GATES.md. A green CI run does not prove ISO bootability, sandbox enforcement, privacy guarantees or production readiness.

## License

No project-wide license has been selected yet. Third-party components retain their own licenses. Do not assume this repository grants permission to redistribute third-party code beyond those licenses.
