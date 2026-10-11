<p align="center">
  <img src="res/logo-header.svg" alt="PortalDesk"><br>
  <b>PortalDesk: your own remote desktop. Fast, private, no accounts.</b>
</p>

## What it is

PortalDesk lets you control your PC from your phone, and your phone from another
phone, over your own server. No ads, no timers, no account, no tracking.

| Platform | Download |
|---|---|
| Windows (installer) | [Releases](https://github.com/DENAYZE34/PortalDesk/releases/latest), file `PortalDesk-setup-*-x86_64.exe` |
| Android 64-bit / 32-bit | [`android-latest`](https://github.com/DENAYZE34/PortalDesk/releases/tag/android-latest) / [`android-armv7-latest`](https://github.com/DENAYZE34/PortalDesk/releases/tag/android-armv7-latest) |
| iOS | SideStore source: `https://github.com/DENAYZE34/PortalDesk/releases/download/ios-latest/apps.json` |

## Updates

Every release is built and published here, in this repository only. The apps
check this repository, verify the SHA-256 of the download and install over the
existing version. Your ID, password and settings are kept.

## Build

Flutter UI (`flutter/`) over a Rust core (`src/`, `libs/`). CI builds all
platforms: see `.github/workflows/portal-*.yml`. Release gate and test plan:

## Licence and credits

PortalDesk is free software under the **GNU Affero General Public Licence v3**
(see `LICENCE`). It is built on the open-source RustDesk codebase
(https://github.com/rustdesk/rustdesk, AGPL-3.0, © the RustDesk contributors),
which the licence requires us to acknowledge and to keep available. Our changes
(interface, updates, server, mobile features) are published here under the same
licence. See `NOTICE.md`.
