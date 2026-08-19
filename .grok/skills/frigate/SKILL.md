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
- MQTT is **enabled** to HA Mosquitto at `192.168.1.209:1883`, user `frigate`, password `FRIGATE_MQTT_PASSWORD` in `/frigate/.env` (also listed in `compose.yml` `environment`). Do not print it.

## Layout (re-check on disk)

```
/mnt/data/apps/frigate/          # PVE NFS; docker mounts this at /frigate
  compose.yml                    # restart: unless-stopped; binds config + storage
  .env                           # FRIGATE_DOORBELL_PASSWORD, FRIGATE_MQTT_PASSWORD (not yadm)
  config/config.yaml             # cameras + go2rtc (placeholders only)
  config/*.bak.*                 # timestamped local copies after edits
  storage/                       # recordings, clips, snapshots
```

NFS export (PVE `/etc/exports`): `/mnt/data/apps/frigate` → `192.168.1.187` only. This tree is **not** in yadm and **not** in HA Google Drive Backup. Safe to copy off-box: `compose.yml` and `config/config.yaml` (secrets are `{FRIGATE_*}` placeholders). Never copy `.env`, `config/.jwt_secret`, or `config/frigate.db*`. Today the only backups are those `.bak.*` files on the same share. Later (do not start unless asked): include this dataset in PVE/PBS, or rsync the two safe files somewhere tracked.

Container: `ghcr.io/blakeblackshear/frigate:stable`, no Coral/GPU. Ports `8971`, `8554` (go2rtc RTSP), `8555` WebRTC.

### iGPU / `/dev/dri` (not in use)

`/dev/dri/renderD128` is the render node ffmpeg uses for VAAPI/QSV. VM 101 only has QEMU stdvga (`1234:1111`) and `/dev/dri/card0` — that is **not** an iGPU. Using hwaccel means: confirm an Intel/AMD iGPU on the PVE host (`lspci`), pass it through to VM 101 (PCI or mediated), then uncomment `/dev/dri/renderD128` in `compose.yml` and set `ffmpeg.hwaccel_args` (e.g. `preset-vaapi`). Do not confuse this with virtiofs (forbidden on this VM). One 480×640 doorbell at 5 fps is fine on CPU (~10 ms inference); add the iGPU when there are more cameras. Do not start unless asked.

## Cameras (last inventoried)

One camera: **doorbell** (Reolink hostname `Front`, MAC `c4:8b:66:0e:97:21`, UniFi reservation `192.168.1.110`). HTTP is enabled on the camera. go2rtc video is HTTP-FLV (`channel0_main.bcs` / `channel0_ext.bcs`). Two-way talk is **only** on `doorbell_sub` (`rtsp://…/Preview_01_sub`, no `ffmpeg:` prefix) — that is the stream the HA card uses. Do not put talk on `doorbell_main` (one backchannel). Frigate consumes `rtsp://127.0.0.1:8554/doorbell_*`. Detect **on**, 480×640 on the sub stream; record+audio on main. Review **alerts = person only**, and **`review.alerts.required_zones: [stoop]`**. Zone `stoop` is the brick landing + lower stairs + **grass left of the walkway** (not the street). Frigate 0.17 does **not** accept `objects.filters.person.required_zones` (safe-mode). Sidewalk people can still be detections / `doorbell_person_occupancy`; they are not Review **alerts**. For HA phone notify to match, trigger on the stoop occupancy entity (not generic person occupancy). Recording: motion 7 days, alerts/detections 14 days. Snapshots 14 days. Button press is Reolink; HA `frigate.create_event` (`visitor`, 30s) plus notify image `/api/frigate/notifications/<event_id>/snapshot.jpg`. Person notify uses `/api/frigate/doorbell/person/snapshot.jpg`. `.203` is stale. Do not URL-encode the doorbell password in the FLV query string.

To tweak the polygon: Frigate UI → doorbell → Masks / Zones, or edit `coordinates` (relative 0–1). Restart Frigate after YAML changes.

## First move in a new session

1. `ssh -o BatchMode=yes docker 'hostname; docker ps --filter name=frigate; findmnt /frigate'`
2. Inventory only the YAML you will touch; do not dump `.env`.
3. Edit, restart, confirm healthy.
