# PortalDesk Privacy Policy

**Effective date:** October 23, 2026

PortalDesk is a remote-desktop application (Windows, Android, iOS) that lets you connect to and control your own devices, or devices you have been explicitly given permission to access. This policy explains what data PortalDesk accesses, why, and what happens to it.

## What PortalDesk does

PortalDesk connects two devices directly (peer-to-peer) or through a relay server when a direct connection is not possible, so one device can view and/or control the other's screen. It does not operate a cloud account system: there is no PortalDesk "profile" tied to your name or email.

## Data PortalDesk accesses

| Data | Why | Where it goes |
|---|---|---|
| Device ID | Identifies your device so another device can connect to it | Generated locally; shared only with the relay server to route connection requests, and with whoever you give your ID to |
| Connection password | Authorizes who may connect to your device | Stored locally (hashed); sent encrypted during the connection handshake |
| Screen contents (via MediaProjection / screen capture) | Lets the connecting device see your screen during an active session | Streamed only to the device you are actively connected to, for the duration of that session; not stored by PortalDesk |
| Keyboard/mouse/touch input (via Accessibility Service) | Lets the connecting device control your device during an active session | Processed locally to simulate input; not stored |
| Files you choose to transfer | File-transfer feature, when you use it | Sent only to the connected device, only for files you explicitly select |
| Audio (if enabled) | Lets the connecting device hear your device's audio during a session | Streamed only during the active session; not stored |
| Telegram chat ID (identity verification) | A one-time check, during first setup, that a real person with Telegram access is using the app — an anti-fraud measure | Sent to Telegram's Bot API; stored locally on your device as a linked/not-linked flag. PortalDesk does not store your Telegram messages, contacts, or any other Telegram data |

## What PortalDesk does not do

- It does not collect analytics, advertising identifiers, or browsing history.
- It does not sell or share your data with third parties for marketing.
- It does not access your screen, input, files, or audio except during a session you or someone you authorized actively started.
- It does not read your Telegram messages beyond the single linking confirmation described above.

## Permissions explained (Android)

- **Accessibility Service**: used only to simulate remote keyboard/mouse/touch input when a session is active and you have granted Input Control permission. PortalDesk is a remote-support tool, not an assistive technology for users with disabilities, though the same system permission is used for both purposes.
- **Screen capture (MediaProjection)**: used only to stream your screen during an active, user-initiated remote session.
- **Storage/File access**: used only for the file-transfer feature, for files you explicitly select.

## Data retention

PortalDesk does not operate a server-side database of user accounts or session history in this app. Session data (screen, input, audio, files) is not stored once a session ends. The device ID and local settings are stored only on your own device.

## Changes to this policy

If this policy changes, the updated version will be published at this same URL with a new effective date.

## Contact

For questions about this policy, contact the developer through the app's GitHub repository: https://github.com/DENAYZE34/PortalDesk
