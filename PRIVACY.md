# PortalDesk: Privacy Statement

Effective 2026-10-11. This describes what PortalDesk does with data, as the
application actually works today.

## In one paragraph

PortalDesk has no accounts, no advertising and no analytics. We do not sell data
and we do not collect usage statistics. Your screen, keyboard and files travel
directly between your devices, encrypted; our server only helps them find each
other.

## What stays on your device

- Your device ID, password settings, paired devices and preferences.
- A local crash log (kept on the device; copied only when you tap "Скопировать
  журнал сбоев" and choose to send it).
- Recent connections and favourites.

## What our server sees

The PortalDesk rendezvous and relay server (operated by the PortalDesk project)
sees, to connect two devices: the two device IDs, the IP addresses involved, and
connection timing. When a direct connection is not possible, the relay forwards
the already encrypted stream; it cannot read your screen or input. Server logs
are used only to run and secure the service.

## Optional voice typing

If you switch on the microphone button, audio is sent over TLS to our token
proxy and from there to **Deepgram** (api.deepgram.com) to be turned into text,
which is typed on the remote device. Audio is not stored by PortalDesk. Deepgram
processes it under its own terms. If you never use voice typing, no audio is
captured or sent.

## Updates

To check for a new version the app contacts **GitHub** (github.com,
api.github.com) for the PortalDesk repository. GitHub sees the request's IP
address. Downloads are verified with a SHA-256 hash and the app signature.

## Permissions on Android

| Permission | Why |
|---|---|
| Accessibility ("Управление вводом") | lets another device you approved tap and type on this phone |
| Screen capture | shows this phone's screen to the device that connects |
| Display over other apps | shows hints and a cursor |
| Microphone | only for voice typing, only when you turn it on |
| Notifications / foreground service | tells you that the phone is open for control and keeps the link alive |
| Battery optimisation exemption | prevents Android from cutting the connection |
| Install packages | installs updates you approve |

You can revoke any of them in Android settings; the related feature then stops.

## Your control

You decide who can connect: a one-time or permanent password, optional pairing
that only allows devices you approved, and a visible banner while someone is
connected. Stopping the service or uninstalling the app ends all access.

## Children

PortalDesk is not directed at children under 16.

## Changes and contact

We update this statement in the repository
(https://github.com/DENAYZE34/PortalDesk) and note the change in the release
notes. Questions: open an issue in the repository.
