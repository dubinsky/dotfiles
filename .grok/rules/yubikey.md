# YubiKey taps: open a terminal, never say "if prompted"

Leonid authenticates SSH and Git with a YubiKey FIDO2 key (`~/.ssh/id_ed25519_sk.pub`). Grok cannot touch it. There is **no** on-screen prompt in this TUI when `BatchMode` SSH waits on the agent — so **never** write “tap if prompted.”

## Required procedure

Skip the helper only when `ssh -O check <alias>` already succeeds (mux live). After a reboot of the remote, delete the stale socket (`~/.ssh/control/ssh-…`) and run it again.

Before any command that talks to a YubiKey-gated host (mux not live):

1. State **user@host** (and the alias) in the user-facing message.
2. Confirm the FIDO identity is in the agent:

   ```bash
   ssh-add -L
   ```

   Need a line `sk-ssh-ed25519@openssh.com` matching `~/.ssh/id_ed25519_sk.pub`. `Host *` `IdentityFile` is that **public** key (resident; no private stub on disk). Empty agent ⇒ OpenSSH prints `Load key "…/id_ed25519_sk.pub": invalid format` and fails.

3. If the agent has no identities (or no `sk-ssh-ed25519` line): **do not** run `yk-tap` yet. Open a **visible** terminal so Leonid can enter the FIDO PIN:

   ```bash
   export DISPLAY="${DISPLAY:-:0}"
   export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
   export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
   export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-/run/user/1000/ssh-agent.socket}"
   xdg-terminal-exec bash -lc 'printf "\n  ENTER FIDO PIN, then TAP THE YUBIKEY\n  ssh-add -K\n\n"; ssh-add -K; echo; ssh-add -L; echo; read -r -p "Press Enter to close."'
   ```

   Do **not** run `ssh-add -K` in this TUI (no PIN field). Poll `ssh-add -L` until the key appears.

4. Then run `~/.grok/scripts/yk-tap <ha|pve|docker|unifi|git>`. That opens a **separate visible terminal** whose only job is “TAP THE YUBIKEY NOW” and establishing `ControlMaster`. The script is Grok-only and is not on PATH. It exits non-zero if the agent still has no `sk-ssh-ed25519` identity — load the key first (step 3), do not retry the tap window.
5. Wait for the ready file (`/tmp/yk-tap-<alias>.ready`, or the path you passed).
6. Then run the real `ssh` / `yadm push` so it reuses the mux.

Do this for Git remotes (`yadm push`, `git push`) and house SSH. `Host *` in `~/.ssh/config` uses the same key everywhere. `ControlPersist` on muxes opened by the helper is 15 minutes.

| Alias | User | Host |
|---|---|---|
| `git` | `git` | `github.com` |
| `ha` | `root` | `homeassistant.lan.podval.org` (`192.168.1.209`) |
| `pve` | `root` | `192.168.1.40` (`proxmox.lan.podval.org`) |
| `unifi` | `root` | `192.168.1.184` (`unifi-os-server.lan.podval.org`) |
| `docker` | `root` | `192.168.1.187` (`docker.lan.podval.org`) |

Example: “Opening a terminal — tap the YubiKey for `root@192.168.1.40` (`pve`).” If the agent is empty: “Opening a terminal — enter the FIDO PIN (`ssh-add -K`), then I will open the tap window.”

If `ssh-add -K` fails, ask him to plug the key in and enter the PIN in that window. If `yk-tap` fails after the key is loaded, ask him to tap in the tap window. Do not fall back to silent `BatchMode` loops.
