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
| Nexus LUMEN | Desktop visual language and shell |
| Living Space | Task-oriented workspaces |
| Nexus Orbit | Window and workspace navigation |
| Nexus Core | Local command and orchestration surface |
| Nexus Harness | Execution policy and runtime coordination |
| Security Center | Permissions, isolation, firewall, verification, recovery |
| Privacy Center | Data controls, network privacy, audit and export |
| Nexus Pulse | Evidence-based system telemetry |

## Repository layout

- `config/`: Debian Live Build package lists.
- `.github/workflows/`: CI, ISO build and quality checks.
- `docs/`: architecture, threat model and project decisions.
- `desktop/`, `harness/`, `security/`, `system/`, `apps/`, `ai/`: planned implementation areas.

## Build the first live ISO

The initial build targets **Debian 13 (trixie), amd64**.

1. Open the repository's **Actions** tab.
2. Select **Build Nexus OS ISO**.
3. Choose **Run workflow**.
4. Wait for the build to finish.
5. Download the `nexus-os-3000-iso` artifact and boot it in a virtual machine.

The first image is a development live environment, not a production release or a safe-to-install daily-driver OS.

## Security baseline

A conservative sysctl baseline is staged in the live image configuration. It is not yet runtime-verified; see [docs/SECURITY_BASELINE.md](docs/SECURITY_BASELINE.md) for scope and VM verification steps. Package presence alone is not proof that a security control is active.

## Development status

See [docs/ROADMAP.md](docs/ROADMAP.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and [docs/THREAT_MODEL.md](docs/THREAT_MODEL.md).

## License

No project-wide license has been selected yet. Third-party components retain their own licenses. Do not assume this repository grants permission to redistribute third-party code beyond those licenses.