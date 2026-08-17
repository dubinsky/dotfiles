---
name: unifi
description: >
  Operate Leonid Dubinsky's UniFi Network from Grok Build as a config engineer.
  Use when the user mentions UniFi, UDM, USG, access points, SSIDs, VLANs,
  switch ports, UniFi OS, uosserver, podval Wi‑Fi, or asks to change Wi‑Fi
  or LAN. Also when they run /unifi.
metadata:
  short-description: "SSH into UniFi OS and configure Network safely"
---

# UniFi (this house)

Grok Build is a **config engineer**, not the UniFi phone app. Prefer the **local Network API key**. Use SSH only for host/container health. Do not adopt, forget, or reboot hardware unless the user asked.

There is no UniFi MCP.

## Local API (preferred)

Non-secret URL: `~/.grok/unifi/api.env`. Secret (mode 600, never print, never `set -x`, never yadm): `~/.grok/unifi/api.key` (raw key, one line). `source` of `api.env` loads both. Grok-only — not under `~/.config/unifi`.

```
# api.env
UNIFI_URL=https://192.168.1.184:11443
UNIFI_API_KEY=$(<"${HOME}/.grok/unifi/api.key")
```

Create the key in the UI (shown once): **https://192.168.1.184:11443/network/default/integrations** → Create New API Key → name it `grok`. Or: Network → Settings → Control Plane → Integrations. Do not use a Site Manager / unifi.ui.com cloud key. Put only the secret in `api.key`.

```bash
set +x
source ~/.grok/unifi/api.env
curl -sk -o /tmp/unifi-api.out -w '%{http_code}\n' \
  -H "X-API-KEY: ${UNIFI_API_KEY}" -H 'Accept: application/json' \
  "${UNIFI_URL}/proxy/network/integration/v1/sites"
```

- Official Integration API: `${UNIFI_URL}/proxy/network/integration/v1/…`. Docs: https://developer.ui.com
- Older Network endpoints when v1 cannot do the job: `${UNIFI_URL}/proxy/network/api/s/default/…` with the same header.
- v1 site id: `88f7af54-98f8-306a-a1c7-c9349722b1f6` (name Default). Legacy site name: `default`.
- Key is present and was verified (GET `/sites` → 200). HTTP 401 → key revoked or file overwritten.

## Connect (SSH, host only)

```bash
ssh -o BatchMode=yes unifi '…'
```

Fallback: `ssh -o BatchMode=yes pve 'pct exec 105 -- …'`

| | |
|---|---|
| SSH alias | `unifi` → `root@192.168.1.184` |
| FQDN | `unifi-os-server.lan.podval.org` |
| Guest | PVE LXC **105** (`unifi-os-server`), Debian 13 |
| Auth | Same YubiKey FIDO2 (`~/.ssh/id_ed25519_sk.pub`) |
| UI | https://192.168.1.184:11443 (HTTP 200). **Not** :8443 |
| Switch | **192.168.1.245** is the USW-Pro-24-PoE, not the controller |

The YubiKey cannot be touched from Grok. If `BatchMode` fails, tell the user to run `ssh unifi` (or `ssh pve`) once in a normal terminal, tap, then retry.

Inside the UniFi OS **podman** container (Network app + mongo):

```bash
cd /tmp
sudo -u uosserver -H env XDG_RUNTIME_DIR=/run/user/1000 podman exec uosserver …
```

`uosserver shell` is interactive only — do not use it from Grok.

Do not print Wi‑Fi passphrases, mongo dumps of `x_passphrase`, UI cookies, or local API keys (`set -x` will leak them).

## Safety

- **Never** `uosserver-purge`, `uosserver stop`, factory-reset, forget-device, or force-provision the USG unless the user asked. Stopping the controller does not immediately drop Wi‑Fi, but it blocks changes and inform.
- **Never** write the ace mongo DB or `/usr/lib/unifi/data/system.properties` as a way to “edit config”.
- Do not dump `wlanconf` documents — they contain PSK material.
- **Write** via the local API (or UI). Mongo is read-only inventory when the API cannot answer. Never create keys by inserting into `ace.api_key`.
- Before host-level edits: `cp -a` the file to `/root/….bak.$(date +%Y%m%d%H%M%S)`.

## Runtime (re-check with `uosserver status`)

- Host units: `uosserver.service`, `uosserver-updater.service` (run as user `uosserver`).
- Container image `uosserver`, UniFi OS Server **5.1.21**, Network **10.5.67**, status READY.
- Container services: `unifi.service` (Java + mongod `:27117`), `unifi-core.service`, `ulp-go.service`.
- Data on the LXC: `/var/lib/uosserver/`. App data in the container: `/usr/lib/unifi/data/`.
- Inform/STUN etc. published via pasta: `8080`, `3478/udp`, `11443→443`, plus 8444/8880–8882/5671/6789/9543.

Read-only inventory (names/IPs only):

```bash
sudo -u uosserver -H env XDG_RUNTIME_DIR=/run/user/1000 \
  podman exec uosserver mongo --quiet --port 27117 --eval '
    db = db.getSiblingDB("ace");
    db.device.find({}, {name:1, ip:1, mac:1, model:1, type:1, _id:0}).forEach(printjson);
  '
```

## Site (last inventoried)

One useful site: `default` (“Default”). LAN `192.168.1.1/24`. Public WAN on the USG was `73.143.105.42` (same IP cloudflare-ddns tracks for `k39.podval.org`).

| Type | Model | Name | Address |
|---|---|---|---|
| ugw | UGW3 | USG 3P | WAN 73.143.105.42 |
| uap | U7PG2 | AC Pro | 192.168.1.72 |
| uap | U7NHD | Nano HD | 192.168.1.161 |
| usw | US8P60 | US 8 60W | 192.168.1.210 |
| usw | USPM24P | USW Pro Max 24 PoE | 192.168.1.245 |

WLANs (do not print keys): `podval-u` is **5 GHz only** (people); `podval-2g` is **2.4 GHz IoT**. One LAN, no extra VLANs. DHCP pool `192.168.1.100–199`.

## First move in a new session

1. Confirm `~/.grok/unifi/api.key` is non-empty, then `source ~/.grok/unifi/api.env`. GET `/proxy/network/integration/v1/sites` (do not print the key).
2. Inventory only the devices or WLANs you will touch.
3. Change via the API; say what needs a device provision. Use `ssh unifi` only for container/host issues.
