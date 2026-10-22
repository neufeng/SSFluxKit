# Android emulator capability (Cloud Agent run)

**Can we run the Android emulator in this environment?** **No.**

## Checks performed

| Check | Result |
| --- | --- |
| `/dev/kvm` | Present (`crw-rw---- root:103`) but **not readable/writable** by user `ubuntu`; no `kvm` group exists to join |
| `ANDROID_HOME` / `ANDROID_SDK_ROOT` | Unset; no SDK under `$HOME/Android/Sdk` |
| `emulator -list-avds` | **Command not found** (SDK/emulator not installed) |
| `flutter emulators` | `Unable to find any emulator sources` |
| `flutter doctor -v` | **Android toolchain ✗** — Unable to locate Android SDK |
| Repository `environment.json` `install` | Clones Flutter stable and runs `flutter precache --linux` only (no Android SDK / AVD setup) |

## Why Android was not attempted further

Hardware-accelerated emulation requires KVM access and a full Android SDK + system image + AVD. This VM has KVM device node without user access, and the project environment bootstrap does not install the Android SDK. Installing and running a software-only emulator would be slow and unreliable for an agent run; we did not produce fake “Android” screenshots.

## Fallback used for UI preview

- **Platform:** Flutter **Web** (Chrome), mobile viewport **412×915**
- **Build:** `melos bootstrap` → `cd apps/ss_fluxkit_demo && flutter build web`
- **Serve:** `python3 -m http.server 8765` in `build/web`
- **Screenshots:** labeled `web-fallback-*.png` in `docs/screenshots/` (non-Android)

## Linux desktop note

`flutter doctor` reports Linux desktop toolchain OK after installing `ninja-build`, `libgtk-3-dev`, etc., but **native Linux build failed** here due to Clang missing C++ standard headers when compiling GTK glue (`type_traits` not found). Web fallback succeeded.
