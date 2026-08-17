# YubiKey taps: open a terminal, never say "if prompted"

Leonid authenticates SSH and Git with a YubiKey FIDO2 key (`~/.ssh/id_ed25519_sk.pub`). Grok cannot touch it. There is **no** on-screen prompt in this TUI when `BatchMode` SSH waits on the agent — so **never** write “tap if prompted.”

## Required procedure

Before any command that talks to a YubiKey-gated host:

1. State **user@host** (and the alias) in the user-facing message.
2. Run `~/.grok/scripts/yk-tap <ha|pve|docker|unifi|git>`. That opens a **separate visible terminal** whose only job is “TAP THE YUBIKEY NOW” and establishing `ControlMaster`. The script is Grok-only and is not on PATH.
3. Wait for the ready file (`/tmp/yk-tap-<alias>.ready`, or the path you passed).
4. Then run the real `ssh` / `yadm push` so it reuses the mux.

Skip the helper only when `ssh -O check <alias>` already succeeds (mux live). After a reboot of the remote, delete the stale socket (`~/.ssh/control/ssh-…`) and run it again.

Do this for Git remotes (`yadm push`, `git push`) and house SSH. `Host *` in `~/.ssh/config` uses the same key everywhere. `ControlPersist` on muxes opened by the helper is 15 minutes.

| Alias | User | Host |
|---|---|---|
| `git` | `git` | `github.com` |
| `ha` | `root` | `homeassistant.lan.podval.org` (`192.168.1.209`) |
| `pve` | `root` | `192.168.1.40` (`proxmox.lan.podval.org`) |
| `unifi` | `root` | `192.168.1.184` (`unifi-os-server.lan.podval.org`) |
| `docker` | `root` | `192.168.1.187` (`docker.lan.podval.org`) |

Example: “Opening a terminal — tap the YubiKey for `root@192.168.1.40` (`pve`).”

If the helper fails, ask him to plug the key in and tap in that window; do not fall back to silent `BatchMode` loops.
