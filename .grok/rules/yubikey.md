# Announce YubiKey taps before they happen

Leonid authenticates SSH and Git with a YubiKey FIDO2 key (`~/.ssh/id_ed25519_sk.pub`). Grok cannot touch it. **Before** any command that may need a tap, say so in the user-facing message — do not only mention it after `BatchMode` fails.

State all three:

1. That a YubiKey tap may be required
2. **Host** being contacted
3. **User** on that host

Do this for Git remotes (`git@…`, `yadm push`) and for house SSH (`ha`, `pve`, `unifi`, `docker`, anything else using that key). `Host *` in `~/.ssh/config` applies the same key everywhere.

| Alias / remote | User | Host |
|---|---|---|
| `github.com` (yadm / git) | `git` | `github.com` |
| `ha` | `root` | `homeassistant.lan.podval.org` (`192.168.1.209`) |
| `pve` | `root` | `192.168.1.40` (`proxmox.lan.podval.org`) |
| `unifi` | `root` | `192.168.1.184` (`unifi-os-server.lan.podval.org`) |
| `docker` | `root` | `192.168.1.187` (`docker.lan.podval.org`) |

Example: “Tap the YubiKey if prompted — SSH as `git@github.com`.”  
Or: “Tap the YubiKey if prompted — SSH as `root@192.168.1.40` (`pve`).”

`ControlPersist` is 5m and the agent may already hold an assertion, so a tap is not guaranteed (the last yadm push succeeded with none). Announce anyway. If nothing was requested, say that after the command.

If auth fails (`permission denied`, `agent refused operation`), tell him to plug the key in, run the same `ssh <alias>` (or `ssh git@github.com`) once in a normal terminal, tap there, then retry.
