# LUMEN implementation status

## First native prototype

The first LUMEN source prototype is a Qt 6 / Qt Quick application under `lumen/`. It provides a responsive navigation frame, theme toggle, and explicit placeholder states for telemetry that is not yet connected. It is an application prototype, not yet a desktop shell or window manager.

## Build locally

On Debian/Ubuntu with Qt 6 development packages, CMake, and Ninja installed:

```sh
cmake -S lumen -B build/lumen -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/lumen
./build/lumen/nexus-lumen
```

The CI quality workflow builds the prototype and starts it with Qt's offscreen platform plugin as a smoke test. A successful smoke test proves that the app can initialize in CI; it does not prove GPU acceleration, real display compatibility, accessibility, or VM boot integration.

## Integration gates

1. Build and launch the prototype in CI.
2. Run it in the Debian live ISO under the current XFCE session.
3. Test keyboard navigation, scaling, reduced motion, and memory use in a VM.
4. Implement real system telemetry and permission-status adapters.
5. Only after stability and recovery tests, create a selectable LUMEN login session. Do not remove XFCE as the fallback until that session is verified.

## Ownership and upstream components

Nexus owns the LUMEN UI, application logic, integration code, policy and product behavior. It will still rely on maintained upstream foundations such as the Linux kernel, Qt, Wayland, system libraries, and hardware drivers. Reusing these audited components is safer and more maintainable than reimplementing an operating-system kernel or graphics stack. Third-party licenses must be preserved.
