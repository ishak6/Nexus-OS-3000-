# Nexus Harness — Capability Manifest v1

## Purpose and status

This milestone adds a strict capability manifest, a deny-by-default policy document, a metadata-only validator, and unit tests.

It does not execute applications or enforce OS sandboxing. A valid manifest is not permission to run an application.

## Security invariants

1. Imported archives and scripts are data and are never auto-executed.
2. A manifest describes requested capabilities; it does not grant them.
3. Unknown fields and capabilities are rejected.
4. Privileged execution is denied by this manifest version.
5. Any future runtime must require OS-enforced sandboxing.
6. Future permission prompts must show each capability and require explicit approval.
7. Validation must never interpret or execute application entrypoints.

## Allowed capability requests

| Capability | Meaning | Default |
|---|---|---|
| filesystem.read | Read approved files | Deny |
| filesystem.write | Write within approved app data | Deny |
| network.client | Outbound network access | Deny |
| device.camera | Camera access | Deny |
| device.microphone | Microphone access | Deny |
| device.location | Location access | Deny |

No raw shell, arbitrary host paths, kernel access, credential access, persistence, or privileged capability exists in v1.

## Validate

Run from the repository root:

    python3 harness/policy/validate_manifest.py harness/examples/hello-app.manifest.json
    python3 -m unittest discover -s harness/tests -v

The validator only parses JSON and checks metadata.

## Runtime integration gates

Before application execution can be considered implemented:
- Resolve requested capabilities through a visible approval flow.
- Use an unprivileged account and maintained sandbox mechanism.
- Restrict filesystem visibility to app data and user-selected paths.
- Deny network/device access unless separately granted.
- Apply resource limits and process lifecycle controls.
- Record grants, denials and revocations locally.
- Test isolation boundaries, revocation, reboot and recovery.
- Complete independent security review.

Manifest validation is not sandbox enforcement or proof of runtime security.
