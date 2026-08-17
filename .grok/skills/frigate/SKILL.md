---
name: frigate
description: >
  Operate Leonid Dubinsky's Frigate NVR from Grok Build as a config engineer.
  Use when the user mentions Frigate, NVR, doorbell camera, go2rtc, RTSP,
  recordings, or detect/record streams. Also when they run /frigate.
metadata:
  short-description: "Edit Frigate YAML on the PVE share and reload Docker"
---

# Frigate (this house)

Grok Build is a **config engineer**, not the Frigate UI. Edit YAML on the host share. Do not open camera streams or change detect/record unless the user asked.

There is no Frigate MCP.

## Connect

**Edit files on the Proxmox host** (same tree the container sees via NFS):

```bash
ssh -o BatchMode=yes pve '…'   # /mnt/data/apps/frigate
```

**Reload / logs** on the Docker VM:

```bash
ssh -o BatchMode=yes docker '…'
```

| | |
|---|---|
| SSH aliases | `pve` → `192.168.1.40`; `docker` → `192.168.1.187` (`docker.lan.podval.org`) |
| Guest | PVE VM **101**, hostname `docker`, Debian 13 |
| Auth | Same YubiKey (`~/.ssh/id_ed25519_sk.pub`) |
| Host tree | `/mnt/data/apps/frigate` |
| Guest mount | `192.168.1.40:/mnt/data/apps/frigate` → `/frigate` (NFS4, `_netdev,nofail`) |
| UI | http://192.168.1.187:8971 (not port 5000) |
| UniFi | Reservation is on **docker** at `.187`. Do not recreate a client named `frigate`. |

The YubiKey cannot be touched from Grok. If `BatchMode` fails, tell the user to run `ssh pve` or `ssh docker` once in a normal terminal, tap, then retry. `ControlPersist` is 5m (`Host *`).

Do not print `.env`, `config/.jwt_secret`, RTSP passwords, or `FRIGATE_*` values (`set -x` will leak them).

## Safety

- **Never** attach virtiofs to VM 101 — it hangs UEFI boot. NFS only.
- **Never** write `config/frigate.db*` or `.jwt_secret`.
- Before YAML edits: `cp -a config.yaml config.yaml.bak.$(date +%Y%m%d%H%M%S)` (same for `compose.yml`).
- After `config.yaml` change: `ssh docker 'docker restart frigate'` (or `docker compose -f /frigate/compose.yml up -d` if compose/binds changed). Check `docker logs frigate --tail 50` and that the container is healthy.
- Do not `docker compose down` unless the user asked (drops the NVR).
- MQTT is **disabled** in config. Do not enable it unless asked (HA has its own Reolink path).

## Layout (re-check on disk)

```
/mnt/data/apps/frigate/
  compose.yml          # restart: unless-stopped; binds /frigate/config and /frigate/storage
  .env                 # FRIGATE_DOORBELL_PASSWORD, FRIGATE_RTSP_PASSWORD
  config/config.yaml   # cameras + go2rtc
  storage/             # recordings
```

NFS export (PVE `/etc/exports`): `/mnt/data/apps/frigate` → `192.168.1.187` only.

Container: `ghcr.io/blakeblackshear/frigate:stable`, no Coral/GPU devices. Ports `8971`, `8554` (go2rtc RTSP), `8555` WebRTC.

## Cameras (last inventoried)

One camera: **doorbell** (Reolink hostname `Front`, MAC `c4:8b:66:0e:97:21`, UniFi reservation `192.168.1.110`). go2rtc pulls `Preview_01_main` / `Preview_01_sub` with `{FRIGATE_DOORBELL_PASSWORD}`; Frigate consumes `rtsp://127.0.0.1:8554/doorbell_*` (`preset-rtsp-restream`). Detect 480×640 on the sub stream; record+audio on main. `.203` is stale.

## First move in a new session

1. `ssh -o BatchMode=yes docker 'hostname; docker ps --filter name=frigate; findmnt /frigate'`
2. Inventory only the YAML you will touch; do not dump `.env`.
3. Edit, restart, confirm healthy.
