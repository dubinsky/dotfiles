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

House facts (guests, USB, storage, later work): `~/Podval/dub.podval.org/notes/SystemAdministration/ProxMox.md`. Read it before changing guests or storage. Frigate iGPU plan: `Frigate.md` § iGPU passthrough. **Do not start** later items (prune `/mnt/store`, vzdump, iGPU) unless the user asks.

## Connect

```bash
ssh -o BatchMode=yes pve '…'
```

YubiKey: `yk-tap` for `pve` (user rule). PVE has a full shell (`pvesh`, `qm`, `pct`, `pvesm`). Pull files here if you need to parse them.

Do not print cloudflared tunnel tokens, UniFi credentials, or Cloudflare API keys (`set -x` will leak them).

## Safety

- **Never** `qm destroy` / `pct destroy`, wipe disks (`wipefs`, `mkfs`, `sgdisk`), or assemble leftover RAID unless the user asked. `md127` is **stopped** and ignored in `mdadm.conf`. Do not start it.
- Do not stop **100 (haos)** or **101 (docker)** without an explicit ask. Both are `onboot: 1`.
- Before editing a guest config: `cp -a /etc/pve/qemu-server/NNN.conf /root/NNN.conf.bak.$(date +%Y%m%d%H%M%S)` (LXC: `/etc/pve/lxc/NNN.conf`).
- Do not run community-scripts installers unless the user asked.
- Do not move USB devices off VM 100 (HA radios live there).
- Prefer `pvesh` / `qm` / `pct` over hand-editing `/etc/pve` when a command exists.
- **Never** attach virtiofs to VM 101 — it hangs UEFI boot. Frigate stays on NFS.
- Do **not** restore `go run …@latest` on LXC 103 (`cloudflare-ddns`) — that filled the disk.
- Filling `/mnt/store` can make the thin pool read-only and stall guests.

## First move in a new session

1. `ssh -o BatchMode=yes pve 'hostname; pveversion; qm list; pct list'` — confirm the tunnel.
2. Inventory only the guests or storage you will touch.
3. Change, then tell the user what needs a reboot or a UI click (guest restart, etc.).
