---
name: home-assistant
description: >
  Operate Leonid Dubinsky's Home Assistant from Grok Build as a config engineer
  over SSH. Use when the user mentions Home Assistant, HA, automations, entities,
  Z-Wave, Zigbee, ESPHome, ratgdo, garden valve, rtl_433, ViCare, Reolink, or
  asks to change lights, fans, covers, or notify. Also when they run /home-assistant.
metadata:
  short-description: "SSH into HA and edit YAML safely"
---

# Home Assistant (this house)

Grok Build is a **config engineer**, not Assist. Read and edit YAML over SSH. Do not flip live devices unless the user asked to test a change.

Official HA MCP (`/api/mcp`) is **not** wired yet. Do not assume entity control tools exist.

## Connect

```bash
ssh -o BatchMode=yes ha '…'
```

| | |
|---|---|
| SSH alias | `ha` → `root@homeassistant.lan.podval.org` (`192.168.1.209`) |
| Auth | YubiKey FIDO2 (`sk-ssh-ed25519`). Public key file: `~/.ssh/id_ed25519_sk.pub` |
| Config | `~/.ssh/config` `Host ha` uses `IdentitiesOnly` + that `.pub` + `IdentityAgent` |
| Jail | Official **Terminal & SSH** add-on (`core-ssh`). Not the Proxmox host. |
| Config root | `/config` is a symlink to `/homeassistant` |

The YubiKey cannot be touched from Grok. If `BatchMode` fails with permission denied, tell the user to plug in the key, run `ssh ha` once in a normal terminal, tap, then retry. `ControlPersist` is 5m (`Host *`).

No `python3` / `rg` in the add-on. Pull files here and parse locally:

```bash
mkdir -p /tmp/ha-inv
scp -o BatchMode=yes ha:/config/automations.yaml /tmp/ha-inv/
scp -o BatchMode=yes ha:/homeassistant/.storage/core.entity_registry /tmp/ha-inv/
```

Do not copy or print `secrets.yaml` values or Supervisor tokens (`set -x` will leak `SUPERVISOR_TOKEN`).

## Safety

- **Never** write `.storage/`, `secrets.yaml`, `*.db*`, or Z-Wave/Zigbee keys.
- Before editing YAML: `cp -a /config/automations.yaml /config/automations.yaml.bak.$(date +%Y%m%d%H%M%S)`
- After edit: `ha core check`. Do not restart Core unless the user agrees.
- **Cannot reload automations from SSH** (Supervisor token returns 401 on Core API). After a successful check, tell the user: **Developer tools → YAML → Automations → Reload**.
- Do not invent `entity_id`s. Resolve them from `core.entity_registry` (`disabled_by` is null ⇒ enabled).
- Prefer the entity the UI/voice uses. Example: `fan.master_bathroom_fan` is `switch_as_x` over `switch.master_bathroom_fan` — automate the **fan**.

## Config shape (2026-08)

`configuration.yaml` is stock: `default_config` plus includes for automations/scripts/scenes. **No `packages/`**, **no `/config/esphome/`**. Scripts file is empty. Logic is almost all UI-created YAML plus **Node-RED** (`/addon_configs/a0d7b954_nodered/flows.json`). Check Node-RED before duplicating a flow.

Add-ons (started when last inventoried): Z-Wave JS, Terminal & SSH 10.3.0, Mosquitto, File editor, MQTT Explorer, Google Drive Backup, Node-RED, rtl_433 (next), rtl_433 MQTT Auto Discovery. Custom component: HACS only.

Core was **2026.8.1** on qemux86-64 (HAOS VM). Hostnames: `homeassistant.local`, `homeassistant.lan.podval.org`. **Not** 192.168.1.245 (that's the UniFi switch).

`rtl_433/next.conf.template`: MQTT to `homeassistant:1883`, protocol 20 only (Ambient Weather F007TH).

## Automations style

Match `automations.yaml`: list of maps, `id`, `alias`, modern `triggers:` / `actions:` keys, `mode:`. For timers that should reset when the device is turned on again, use `mode: restart`.

Existing YAML automations (do not clobber):

- Tag Shabbos Lights → `scene.master_bedroom_shabbos_scene`
- Refrigerator Shabbos Mode Toggle (device action, not a clean entity_id)
- Doorbell Notification → Reolink `binary_sensor.front_door_visitor` (button) or Frigate `binary_sensor.doorbell_person_occupancy` → snapshot `camera.doorbell` → `notify.mobile_app_pixel_10`. Keep Reolink for the chime; disable Reolink camera entities.
- **Bathroom fan auto-off** (one automation per fan, `mode: restart`, 15 min) — do not combine into one automation; `mode: restart` is per-automation, not per entity:
  - `fan.master_bathroom_fan`
  - `fan.bathroom_fan` (UI name Bathroom Fan; helper over `switch.1st_floor_bathroom_fan`)
  - `fan.guest_bathroom_fan`
  - `fan.attic_bathroom_fan` (helper over `switch.attic_bathroom_fan_2`)
  - **Not** `light.attic_bathroom_fan_light` / `switch.attic_bathroom_fan` (that's the attic fan *light*)

Those fan devices also have disabled Z-Wave `number.*_auto_turn_off_timer` config params (0–65535). Prefer the YAML automations unless the user wants the on-device timer.

## Stable entities (re-check registry; these were enabled)

- Garage: `cover.ratgdov25i_0bd4e4_door`
- Garden: `valve.back_garden_water`, `switch.sonoff_swv`
- Climate: `climate.t6_pro_z_wave_programmable_thermostat`
- Boiler: `sensor.e3_vitodens_100_na_0521_*`
- Doorbell button/chime (Reolink): `binary_sensor.front_door_visitor`, `number.reolink_chime_*`. Video/person (Frigate): `camera.doorbell`, `binary_sensor.doorbell_person_occupancy`. Disable `camera.front_door_fluent`.
- Phones: `device_tracker.pixel_10`, `notify.mobile_app_pixel_10`

~700 enabled entities, ~2600 registered. Many lights still have generic ids (`light.dimmer`, `light.light`). Use the registry `original_name` / `name` to disambiguate.

## First move in a new session

1. `ssh -o BatchMode=yes ha 'hostname; ha core info'` — confirm the tunnel.
2. Inventory the files you will touch; don't dump the whole registry into chat.
3. Edit, check, then ask the user to reload automations.
