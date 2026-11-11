# Initial Threat Model

## Assets to protect

- User documents, credentials and encryption keys.
- Microphone, camera, location and other device access.
- Network identity and traffic metadata.
- OS integrity, boot chain and update trust.
- Application permissions and execution history.
- Imported project files and archive extraction boundaries.

## Threat actors and failure modes

- Malicious or compromised applications.
- Untrusted imported archives, scripts and build tools.
- Path traversal, symbolic-link and archive-bomb inputs.
- Malicious dependencies or compromised package sources.
- Network attackers and hostile local network peers.
- Accidental destructive actions by users or automation.
- Misconfiguration, privilege escalation bugs and supply-chain compromise.

## Security requirements

- Least privilege by default.
- Verify package and update authenticity.
- Isolate untrusted workloads with OS-enforced controls.
- Do not auto-run imported scripts.
- Inspect archive metadata before any future extraction; reject unsafe paths and special entries.
- Show permission grants and access history.
- Make sensitive automation previewable and require confirmation.
- Provide recovery paths and integrity checks.
- Minimize telemetry and make optional data flows explicit.

## Out of scope for the initial prototype

- Guaranteed malware detection or perfect anti-tracking.
- Protection against every kernel, firmware or physical attack.
- Secure boot enforcement across all hardware configurations.
- Production-grade multi-user isolation until independently tested.
- Treating static archive inspection as antivirus or proof of safety.

## Review checklist

- [ ] Identify trust boundaries and privileged services.
- [ ] Review dependency provenance and licenses.
- [ ] Test sandbox escape resistance within an authorized lab.
- [ ] Verify default-deny behavior for sensitive capabilities.
- [ ] Test update signature and rollback protections.
- [ ] Document residual risks and known limitations.

This document is an initial planning artifact, not a security certification.
