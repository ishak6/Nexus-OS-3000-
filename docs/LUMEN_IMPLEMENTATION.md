# LUMEN implementation status

## Native Qt/QML application prototype

LUMEN is a Qt 6 / Qt Quick application under `lumen/`. It provides a responsive navigation frame, theme toggle, and explicit placeholder states for system features that are not integrated.

## Nexus Pulse integration

The application now starts a local `PulseMonitor` adapter. It launches the read-only Python sampler and consumes newline-delimited JSON from procfs. The Overview cards display CPU utilization, used memory percentage and combined network RX/TX throughput. The adapter rejects payloads that do not declare `read_only: true`.

The sampler is installed at `/usr/lib/nexus/pulse/telemetry.py`; development builds also resolve the repository-local script. No telemetry is sent over the network, and the collector does not invoke shell commands or change system state. The network figure is a one-second RX+TX byte delta, displayed as KiB/s.

## Build locally

On Debian/Ubuntu with Qt 6 development packages, CMake, Ninja and Python 3 installed:

```sh
cmake -S lumen -B build/lumen -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/lumen
./build/lumen/nexus-lumen
```

The CI quality workflow compiles the app and starts it with Qt's offscreen platform plugin as a smoke test. Pulse's Python unit tests cover procfs parsing and interval deltas. These checks do not prove GPU acceleration, real display compatibility, accessibility, or VM boot integration.

## Integration gates

1. Build and launch the prototype in CI.
2. Package the app, Pulse sampler, desktop launcher and XFCE-scoped XDG autostart entry into the Debian live ISO; keep XFCE as the active fallback.
3. Verify the LUMEN window and read-only Pulse telemetry in the booted live ISO under XFCE. The VM smoke test requires a visible LUMEN text marker as well as the XFCE panel.
4. Test keyboard navigation, scaling, reduced motion, and memory use in a VM.
5. Expand real system telemetry and permission-status adapters.
6. Only after stability and recovery tests, create a selectable LUMEN login session. Do not remove XFCE as the fallback until that session is verified.

## Current limitations

LUMEN remains an application prototype, not a complete desktop shell or window manager. It does not yet replace XFCE, manage windows, control system services, or enforce security policies. The Pulse adapter is read-only telemetry and is not a privileged system-control interface.

## Ownership and upstream components

Nexus owns the LUMEN UI, application logic, integration code, policy and product behavior. It will still rely on maintained upstream foundations such as the Linux kernel, Qt, Wayland, system libraries, and hardware drivers. Reusing these audited components is safer and more maintainable than reimplementing an operating-system kernel or graphics stack. Third-party licenses must be preserved.
