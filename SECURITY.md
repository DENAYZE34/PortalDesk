# Security

## How to report a vulnerability

Please do not post vulnerabilities in public issues. Use GitHub's private
reporting: **Security tab → Report a vulnerability** in
https://github.com/DENAYZE34/PortalDesk. Include the version, platform, steps and
impact. We aim to answer within 7 days.

## Supported versions

Only the latest release of each platform receives fixes. Apps update from this
repository.

## How the project protects users

- Device-to-device traffic is end-to-end encrypted; the relay forwards ciphertext.
- Updates are downloaded only from this repository, verified against the SHA-256
  published with the release, and must be signed with the PortalDesk key
  (Android) or come from the PortalDesk installer (Windows).
- Remote control requires a password you set; optional pairing restricts access to
  devices you approved.
- A banner shows while someone is connected, and you can disconnect everyone.
- CI blocks a release that changes the app identity, the signing key or the server.
