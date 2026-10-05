# Grok Bot on system upgrade

Official Linux AppImage.
`omarchy update` and pacman do not upgrade it.

When Leonid asks to upgrade or update the system, do **not** reinstall from
Omarchy | AI | Install | Grok Bot (the repo package lags).
Do **not** run Omarchy | AI | Remove | Grok Bot (it deletes `~/.config/Grok Bot`).

The app checks for updates on its own.
In-app **Check for Updates** is under **Settings → Updates**.
**Restart to Update** applies a downloaded app update.

Skip extra AppImage work unless he asks to upgrade Grok Bot itself, or
`~/.local/share/grok-bot/appimage` is missing.

Inventory: `~/Podval/dub.podval.org/notes/SystemAdministration/Omarchy.md`
(Grok Bot).

This is not Grok Build (`grok`).
The desktop app command is `grok-bot`.
