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
| Jail | Official **Terminal & SSH** add-on (`core_ssh` 10.3.0). Not the Proxmox host. |
| Config root | `/config` is a symlink to `/homeassistant` |

The YubiKey cannot be touched from Grok. If `BatchMode` fails with permission denied, tell the user to plug in the key, run `ssh ha` once in a normal terminal, tap, then retry. `ControlPersist` is 5m (`Host *`).

No `python3` / `rg` in the add-on. Pull files here and parse locally:

```bash
mkdir -p /tmp/ha-inv
scp -o BatchMode=yes ha:/config/automations.yaml /tmp/ha-inv/
scp -o BatchMode=yes ha:/homeassistant/.storage/core.entity_registry /tmp/ha-inv/
```

Do not copy or print `secrets.yaml` values or Supervisor tokens (`set -x` will leak `SUPERVISOR_TOKEN`).

### Core API is not reachable from this SSH jail (not a transient 401)

`core_ssh` has `hassio_api: true` / `hassio_role: manager` and **`homeassistant_api: false`**. That is the official add-on manifest (not a user option). `SUPERVISOR_TOKEN` is present and works for **Supervisor** (`ha core info`, `ha core check`, `http://supervisor/info` → 200). The same bearer against **Core** (`http://supervisor/core/api/…`) is **401**. Protection mode is on; there is no Docker socket, so we cannot exec into the Core container either.

Do **not** retry curl-to-Core, mint a long-lived token, or switch to Advanced SSH unless the user asks. After YAML edits: `ha core check`, then tell the user to **Developer tools → YAML → Automations → Reload** (or toggle the automation). Need live state / last_triggered / notify: `scp` `/config/home-assistant_v2.db` and query it locally.

## Safety

- **Never** write `.storage/`, `secrets.yaml`, `*.db*`, or Z-Wave/Zigbee keys.
- Before editing YAML: `cp -a /config/automations.yaml /config/automations.yaml.bak.$(date +%Y%m%d%H%M%S)`
- After edit: `ha core check`. Do not restart Core unless the user agrees.
- Do not invent `entity_id`s. Resolve them from `core.entity_registry` (`disabled_by` is null ⇒ enabled).
- Prefer the entity the UI/voice uses. Example: `fan.master_bathroom_fan` is `switch_as_x` over `switch.master_bathroom_fan` — automate the **fan**.

## Config shape (2026-08)

`configuration.yaml` is stock: `default_config` plus includes for automations/scripts/scenes, plus a YAML **notify action group** `notify.phones` (Pixel 10 / Pixel 8 / Pixel 8 Remote). **No `packages/`**, **no `/config/esphome/`**. Scripts file is empty. Logic is YAML automations. **Node-RED is installed but stopped** (`boot: manual`, empty flow). Check it is still empty before adding YAML that might duplicate a future flow.

Add-ons **started**: Z-Wave JS, Terminal & SSH 10.3.0, Mosquitto, Google Drive Backup, rtl_433 (next). **Stopped, boot manual** (start from the UI if you need them): File editor, MQTT Explorer, Node-RED, rtl_433 MQTT Auto Discovery. Custom: HACS + Frigate integration 5.15.4. Advanced Camera Card is files under `/config/www/advanced-camera-card/` (not HACS).

Core **2026.8.2** on qemux86-64 (HAOS 18.2 VM 100). Hostnames: `homeassistant.local`, `homeassistant.lan.podval.org`. **Not** 192.168.1.245 (that's the UniFi switch). Core HTTP is `:8123` with `ssl: false`. Doorbell talk/mic needs a secure context; today that means Nabu Casa.

`rtl_433/next.conf.template`: protocol 20 only (Ambient Weather F007TH), `verbose 4`. MQTT host/user/pass come from the add-on's `mqtt:want` service (`${host}` `${username}` `${password}` `${retain}`) — do not put broker credentials in the template. Auto Discovery is **stopped**; the three named sensors already exist (boiler `2-234`, garage `1-55`, deck `3-219`). Start Auto Discovery only if a real sensor gets a new ID (battery change), then stop it again so neighbor F007THs are not re-created.

## Later (do not start unless asked)

- **Local HTTPS** so Talk works on the LAN without Nabu Casa.
- **Smoke / CO + garden leak notify** — sensors exist, no automation yet. Attic Zooz ZEN55: `binary_sensor.attic_fire_sensor_smoke_detected`, `binary_sensor.attic_fire_sensor_carbon_monoxide_detected`. Garden SONOFF SWV: `binary_sensor.sonoff_swv_water_leak`. Send `notify.phones` (`ttl: 0`, `priority: high`), distinct titles. Do not page on `binary_sensor.attic_fire_sensor_idle`.
- **Advanced Camera Card via HACS** so it gets updates. Today it is unpacked under `/config/www/advanced-camera-card/` (v7.27.4). `lovelace_resources` is what actually loads it; `frontend.extra_module_url` in `configuration.yaml` is leftover and can go once HACS owns the resource.
- **Official Z-Wave JS → Z-Wave JS UI** if you want a network graph, heal, and per-node debug. Current official add-on is fine for the Zooz/T6 set. Follow HA's switch doc (do not run both add-ons). https://www.home-assistant.io/integrations/zwave_js/#how-do-i-switch-between-the-official-z-wave-js-add-on-and-the-z-wave-js-ui-add-on
- **Watchman + battery status** — [Watchman](https://github.com/dummylabs/thewatchman) for a weekly unavailable-entity report. Separate low-battery notify to `notify.phones` for the real cells: eight SNZB-02D `sensor.sonoff_snzb_02d_battery*`, garden `sensor.sonoff_swv_battery`, T6 `sensor.t6_pro_z_wave_programmable_thermostat_battery_level` / `binary_sensor.t6_pro_z_wave_programmable_thermostat_low_battery_level`, F007TH keepers only (`sensor.ambientweather_234_battery`, `sensor.ambientweather_f007th_1_55_battery`, `sensor.ambientweather_f007th_3_219_battery`). Skip phone battery entities.
- **Floor plan** dashboard. Draw in Sweet Home 3D / RoomSketcher / FreeCAD; integrate with ha-floorplan / floorplan_3d / home-assistant-floor-plan (links in the human note). Not required for current automations.

## Automations style

Match `automations.yaml`: list of maps, `id`, `alias`, modern `triggers:` / `actions:` keys, `mode:`. For timers that should reset when the device is turned on again, use `mode: restart`.

Existing YAML automations (do not clobber):

- Tag Shabbos Lights → `scene.master_bedroom_shabbos_scene`
- Refrigerator Shabbos Mode Toggle — tag `96c806d9-d374-4af9-9675-36defd91f1f2` (`tag.refrigerator_shabbos_mode`) → `switch.toggle` on `switch.refrigerator_sabbath_mode`
- Doorbell Notification → Reolink `binary_sensor.front_door_visitor` (button) or Frigate `binary_sensor.doorbell_person_occupancy` → **`notify.phones`** (Pixel 10 + Pixel 8 + Pixel 8 Remote). On **button**, `frigate.create_event` (`visitor`, 30s) and the notify image is `/api/frigate/notifications/<event_id>/snapshot.jpg`. Person image is `/api/frigate/doorbell/person/snapshot.jpg`. **Talk** opens `/lovelace-doorbell/talk`. HA must be **https** (Nabu Casa) for the browser mic. Keep Reolink for the chime; disable Reolink camera entities. `notify.phones` is a YAML **action** group (not a UI notify-entity helper) so Android extras still pass through.
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
- Phones: `device_tracker.pixel_10`, `notify.phones` (group). Singles: `notify.mobile_app_pixel_10` / `notify.pixel_10` (and Pixel 8 / Pixel 8 Remote). `person.mqtt` is leftover from Mosquitto onboarding — delete in **Settings → People** (this jail cannot write `.storage/person`). After that, the HA login user `mqtt` can go too; rtl_433 no longer uses it.

~700 enabled entities, ~2600 registered. Many lights still have generic ids (`light.dimmer`, `light.light`). Use the registry `original_name` / `name` to disambiguate.

## First move in a new session

1. `ssh -o BatchMode=yes ha 'hostname; ha core info'` — confirm the tunnel.
2. Inventory the files you will touch; don't dump the whole registry into chat.
3. Edit, check, then ask the user to reload automations.
