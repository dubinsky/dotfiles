---
name: house-notes
description: >
  Keep Leonid's published notes as the source of truth for house facts, and keep
  Grok skills as agent playbooks that point at those notes. Use when editing
  house skills (frigate, home-assistant, proxmox, unifi, omarchy), when a durable
  inventory/topology/why fact changed, when moving skill content into notes, or
  when the user runs /house-notes.
metadata:
  short-description: "Notes own facts; skills own agent procedure"
---

# House notes vs Grok skills

Notes: `~/Podval/dub.podval.org/notes/` (Obsidian source, published to dub.podval.org).
Sysadmin: `notes/SystemAdministration/`. Grok does **not** auto-load notes; a skill
must `read_file` the matching note when it needs a fact.

One home per fact. If the note already has it, the skill keeps a pointer, not a copy.

## What lives where

| Home | Owns |
|------|------|
| Note | Inventory, topology, why, history, planned work, human how-to. Wiki links `[[Frigate]]`. Match the note's existing voice. |
| Skill `SKILL.md` | When to fire, SSH/API connect, YubiKey tap, safety never-do, session first move, "don't print secrets", path to the note. |
| `~/.grok/rules/` | Always-on traps for every session (yadm, yk-tap). Durable how-to that landed in a rule belongs in the matching note (`dotfiles.md` for yadm). Do not copy the trap list into the note. |
| Skill sidecar (`api.key`, `api.token`, `.env`) | Secrets. yadm encrypt. Never notes, never chat, never `set -x`. |

Notes in that tree **are published**. Do not put tokens, PSKs, MQTT passwords, or `.env` values there. Unpublished material stays out of the site repo.

## Skill → note

| Skill | Note |
|-------|------|
| `frigate` | `~/Podval/dub.podval.org/notes/SystemAdministration/Frigate.md` |
| `home-assistant` | `~/Podval/dub.podval.org/notes/SystemAdministration/Home Assistant.md` |
| `proxmox` | `~/Podval/dub.podval.org/notes/SystemAdministration/ProxMox.md` |
| `unifi` | `~/Podval/dub.podval.org/notes/SystemAdministration/UniFi.md` |
| `omarchy` | `~/Podval/dub.podval.org/notes/SystemAdministration/Omarchy.md` and `dotfiles.md` |

Precedent: Frigate iGPU passthrough already lives in the note; `frigate` and `proxmox` skills point at that section.

## When a house fact changes

1. Write or update it in the matching note (create the note only if the table has no row and the user wants one).
2. In the skill: keep agent-only bits; replace duplicated tables/narrative with a one-line pointer plus the constraint the agent needs this session (`Do not start unless asked`).
3. Delete the copy. Do not leave the same IP list, guest table, or plan in both files.

## When editing a skill

Before adding a durable fact (IP, guest ID, SSID, entity, hardware, "later" plan), check the note. If it belongs there, put it there and point. Leave in the skill only what the agent must not rediscover while the note is unread (safety never-do, connect, first move).

Do not:

- Point `[skills].paths` at the notes tree (those files are not `SKILL.md`).
- Symlink notes into skill directories.
- Copy session playbooks ("first move", `BatchMode`, `yk-tap`) into published notes.
- Dump agent YAML voice into a narrative note.

## After house work

If the session learned a durable fact, update the note in the same turn. Leave the site-publisher repo alone unless the user asked to publish.
