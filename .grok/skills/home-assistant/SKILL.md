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

House facts (runtime, add-ons, automations, entities, later work): `~/Podval/dub.podval.org/notes/SystemAdministration/Home Assistant.md`. Read it before changing YAML. Fridge Wi‑Fi move: UniFi note. **Do not start** later/TODO items unless the user asks. **Do not bump ratgdo firmware** unless something is actually broken (see the ratgdo section of the note).

## Connect

```bash
ssh -o BatchMode=yes ha '…'
```

Jail is the official **Terminal & SSH** add-on (`core_ssh`), not the Proxmox host. `/config` is a symlink to `/homeassistant`. YubiKey: `yk-tap` for `ha` (user rule).

No `python3` / `rg` in the add-on. Pull files here and parse locally:

```bash
mkdir -p /tmp/ha-inv
scp -o BatchMode=yes ha:/config/automations.yaml /tmp/ha-inv/
scp -o BatchMode=yes ha:/homeassistant/.storage/core.entity_registry /tmp/ha-inv/
```

Do not copy or print `secrets.yaml` values or Supervisor tokens (`set -x` will leak `SUPERVISOR_TOKEN`).

### Core API is not reachable from this SSH jail (not a transient 401)

`core_ssh` has `hassio_api: true` / `hassio_role: manager` and **`homeassistant_api: false`**. That is the official add-on manifest (not a user option). `SUPERVISOR_TOKEN` works for **Supervisor** (`ha core info`, `ha core check`, `http://supervisor/info` → 200). The same bearer against **Core** (`http://supervisor/core/api/…`) is **401**. Protection mode is on; there is no Docker socket, so we cannot exec into the Core container either.

There is **no browser tool** in Grok Build for clicking the HA UI. Reload and live Core calls use a **long-lived access token**:

| | |
|---|---|
| URL | `~/.grok/skills/home-assistant/api.env` (`HA_URL=http://192.168.1.209:8123`) |
| Secret | `~/.grok/skills/home-assistant/api.token` (mode 600, gitignored, yadm encrypt) |
| Helper | `~/.grok/scripts/ha-api` (not on PATH). Default: `POST /api/services/automation/reload` |

Create the token in the UI (shown once): **http://192.168.1.209:8123/profile/security** → **Long-lived access tokens** → Create → name `grok`. Put only the token in `api.token`. Then `yadm encrypt`. Do not paste the token into chat. `set -x` will leak it.

```bash
set +x
~/.grok/scripts/ha-api                  # reload automations
~/.grok/scripts/ha-api script.reload
~/.grok/scripts/ha-api GET /api/config
```

If `api.token` is missing, after YAML edits: `ha core check`, then tell the user to **Developer tools → YAML → Automations → Reload**. Need last_triggered without Core API: `scp` `/config/home-assistant_v2.db` and query it locally.

Do **not** retry Supervisor-token curl-to-Core (still 401). Do not switch to Advanced SSH unless asked.

## Safety

- **Never** write `.storage/`, `secrets.yaml`, `*.db*`, or Z-Wave/Zigbee keys.
- Before editing YAML: `cp -a /config/automations.yaml /config/automations.yaml.bak.$(date +%Y%m%d%H%M%S)`
- After edit: `ha core check`. Do not restart Core unless the user agrees.
- Do not invent `entity_id`s. Resolve them from `core.entity_registry` (`disabled_by` is null ⇒ enabled).
- Prefer the entity the UI/voice uses (`fan.*` over the underlying `switch.*`).
- Match `automations.yaml` style: list of maps, `id`, `alias`, modern `triggers:` / `actions:`, `mode:`. `mode: restart` is per-automation — do not combine the bathroom-fan automations.
- Do not clobber existing YAML automations (list in the note).
- `rtl_433/next.conf.template`: do not put broker credentials in the template (`mqtt:want` supplies them). Auto Discovery stays **stopped** unless a keeper F007TH gets a new ID.

## First move in a new session

1. `ssh -o BatchMode=yes ha 'hostname; ha core info'` — confirm the tunnel.
2. Inventory the files you will touch; don't dump the whole registry into chat.
3. Edit, `ha core check`, then `~/.grok/scripts/ha-api` (automation reload) if `api.token` exists. Otherwise ask the user to reload automations.
