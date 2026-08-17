---
name: proxmox
description: >
  Operate Leonid Dubinsky's Proxmox VE host from Grok Build over SSH.
  Use when the user mentions Proxmox, PVE, VMs, LXC, haos, the docker VM,
  Frigate, cloudflare-ddns, cloudflared, UniFi OS, virtiofs, /mnt/data,
  /mnt/store, or asks to start/stop guests or inspect host storage.
  Also when they run /proxmox.
metadata:
  short-description: "SSH into PVE and manage guests safely"
---

# Proxmox (this house)

Grok Build is a **config engineer on the hypervisor**, not a guest OS. Use `ssh pve` for VMs, LXC, storage, and USB passthrough. For Home Assistant YAML, use the `home-assistant` skill (`ssh ha`) — that is the HAOS guest, not this host.

Do not install Grok on the PVE host.

## Connect

```bash
ssh -o BatchMode=yes pve '…'
```

| | |
|---|---|
| SSH alias | `pve` → `root@192.168.1.40` |
| FQDN | `proxmox.lan.podval.org` |
| Auth | Same YubiKey FIDO2 as HA (`~/.ssh/id_ed25519_sk.pub`) |
| Config | `Host pve` uses `IdentitiesOnly` + that `.pub` + `IdentityAgent` |
| Node | Standalone (no cluster / no corosync). Name: `proxmox` |
| Version | PVE **9.2.4** (kernel 7.0.14-5-pve) when last inventoried |

The YubiKey cannot be touched from Grok. If `BatchMode` fails with permission denied or `agent refused operation`, tell the user to plug in the key, run `ssh pve` once in a normal terminal, tap, then retry. `ControlPersist` is 5m (`Host *`).

PVE has a full shell (`pvesh`, `qm`, `pct`, `pvesm`). Pull files here if you need to parse them.

Do not print cloudflared tunnel tokens, UniFi credentials, or Cloudflare API keys (`set -x` will leak them).

## Safety

- **Never** `qm destroy` / `pct destroy`, wipe disks (`wipefs`, `mkfs`, `sgdisk`), or assemble the old `md127` RAID unless the user asked.
- Do not stop **100 (haos)** or **101 (docker)** without an explicit ask. Both are `onboot: 1`.
- Before editing a guest config: `cp -a /etc/pve/qemu-server/NNN.conf /root/NNN.conf.bak.$(date +%Y%m%d%H%M%S)` (LXC: `/etc/pve/lxc/NNN.conf`).
- Do not run community-scripts installers unless the user asked.
- Do not move USB devices off VM 100 (HA radios live there).
- Prefer `pvesh` / `qm` / `pct` over hand-editing `/etc/pve` when a command exists.

## Guests (re-check with `qm list` / `pct list`)

| ID | Type | Name | LAN IPv4 | Role |
|---|---|---|---|---|
| 100 | VM | haos | 192.168.1.209 | Home Assistant OS. `ssh ha`. 4G RAM, 2 cores, 32G disk |
| 101 | VM | docker | 192.168.1.187 | Docker / DevPod / Frigate. `ssh docker`. 32G RAM, 16 cores, 100G disk |
| 103 | LXC | cloudflare-ddns | 192.168.1.235 | Dynamic DNS (`k39.podval.org`). 3G disk. Binary `/usr/local/bin/cloudflare-ddns` + `/etc/cloudflare-ddns.env` (mode 600). Do **not** restore `go run …@latest` — that filled the disk |
| 104 | LXC | cloudflared | 192.168.1.236 | Cloudflare Tunnel |
| 105 | LXC | unifi-os-server | 192.168.1.184 | UniFi OS (controller). **Not** the switch at 192.168.1.245 |

All guests: `onboot: 1`, `vmbr0`, community-script tags. LXC 103/104 unprivileged + nesting. No snapshots when last inventoried.

HAOS USB passthrough (do not steal):

- `0bda:2832` Realtek RTL2832U (rtl_433)
- `303a:831a` Nabu Casa ZBT-2 (Zigbee)
- `303a:4001` Nabu Casa ZWA-2 (Z-Wave)

Docker VM hostname `docker`. **Do not attach virtiofs** — it hangs UEFI boot (QEMU up, 0 disk reads, no guest agent). Frigate lives on the host at `/mnt/data/apps/frigate` (compose, config, storage). NFS-exported to `192.168.1.187` only (`/etc/exports`). Guest mounts that at `/frigate`. Container binds `/frigate/config` and `/frigate/storage`, `restart: unless-stopped`. Directory mapping `docker-shared` still exists but is unused.

## Storage and host

- Hardware: i9-12900K (24 threads), 64G RAM, boot NVMe `KINGSTON SKC3000D2048G`.
- Bridge: `vmbr0` on `enp3s0`, `192.168.1.40/24`, gw `192.168.1.1`.
- PVE storage: `local` (dir `/var/lib/vz`, ISO/backup) and `local-lvm` (thin pool `pve/data` on the NVMe).
- `/mnt/store` — 1T ext4 thin LV (`pve/store`). Media copy; **~85% full**.
- `/mnt/data` — Btrfs RAID1 label `Big Data` on `/dev/sdc`+`/dev/sdd` (2×4T WD Red). Intended photo/media store. Virtiofs source. **~22% used**.
- `sda`/`sdb` (2×2T WD) still have leftover `md127` labeled `/mnt/data` but it is **not mounted**. Do not assemble.
- `sde` (500G) looks like an old backup disk; not mounted.

## First move in a new session

1. `ssh -o BatchMode=yes pve 'hostname; pveversion; qm list; pct list'` — confirm the tunnel.
2. Inventory only the guests or storage you will touch.
3. Change, then tell the user what needs a reboot or a UI click (guest restart, etc.).
