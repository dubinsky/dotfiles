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

House facts (layout, doorbell, backups, iGPU plan): `~/Podval/dub.podval.org/notes/SystemAdministration/Frigate.md`. Read it before changing config. **Do not start** the iGPU passthrough unless the user explicitly asks.

## Connect

Edit files on the Proxmox host (same tree the container sees via NFS):

```bash
ssh -o BatchMode=yes pve '…'   # /mnt/data/apps/frigate
```

Reload / logs on the Docker VM:

```bash
ssh -o BatchMode=yes docker '…'
```

YubiKey: `yk-tap` for `pve` / `docker` (user rule). Do not print `.env`, `config/.jwt_secret`, RTSP passwords, or `FRIGATE_*` values (`set -x` will leak them).

## Safety

- **Never** attach virtiofs to VM 101 — it hangs UEFI boot. NFS only.
- **Never** write `config/frigate.db*` or `.jwt_secret`.
- Before YAML edits: `cp -a config.yaml config.yaml.bak.$(date +%Y%m%d%H%M%S)` (same for `compose.yml`).
- After `config.yaml` change: `ssh docker 'docker restart frigate'` (or `docker compose -f /frigate/compose.yml up -d` if compose/binds changed). Check `docker logs frigate --tail 50` and that the container is healthy.
- Do not `docker compose down` unless the user asked (drops the NVR).
- MQTT password is `FRIGATE_MQTT_PASSWORD` in `/frigate/.env`. Do not print it.
- UniFi reservation is on **docker** at `.187`. Do not recreate a client named `frigate`.
- Two-way talk is only on `doorbell_sub`. Do not put talk on `doorbell_main`. Do not URL-encode the doorbell password in the FLV query string.

## First move in a new session

1. `ssh -o BatchMode=yes docker 'hostname; docker ps --filter name=frigate; findmnt /frigate'`
2. Inventory only the YAML you will touch; do not dump `.env`.
3. Edit, restart, confirm healthy.
