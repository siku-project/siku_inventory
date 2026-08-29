# siku_inventory

The official inventory system of the SIKU ecosystem — a modern, modular and high-performance resource for managing items, weight, hotbars, ground drops, metadata, unique item instances, and seamless player interactions.

![Version](https://img.shields.io/badge/version-0.5.0-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Vue](https://img.shields.io/badge/NUI-Vue%203-4785bd)

## Features

- **A real item model** — the definition describes what an item *is* (label, weight, stacking, uniqueness, usability); what a player carries is an instance with its own quantity, metadata, freshness and remaining uses. Unique instances get an identifier and a serial that follow them everywhere.
- **Weight and named slots** — grid slots plus a five-key hotbar (`H1`–`H5`); everything the server accepts is recomputed from slot names, never from what a client claims.
- **Containers as a framework** — stash, trunk, glovebox, bag-in-bag, inspect and staff views are all kinds of one registered container family, with per-kind resolvers, live revalidation of open views, and room for future kinds (a shop reserve, for instance).
- **Stashes** — declared in data or registered at runtime, personal or shared, with pluggable access rules (`SetStashAccess`), a group provider hook for a future job system, and disposable temporary stashes.
- **Ground drops** — dropped stacks merge with nearby piles, expire on a sweeper, and reach clients through per-session diffing: the ground is only pushed when it changed.
- **Weapons** — drawn from the hotbar only, with serials, magazine-accurate reloads, attachment customization, spent-ammo tracking and a guard against unauthorized weapons.
- **Perishables and uses** — freshness travels as a share left (never a timestamp), spoiled stacks are swept, and use-counted items count down instead of vanishing.
- **Give, inspect, confiscate** — proximity-checked giving with ground overflow, staff inspection gated by permission and rank, and a sealed `confiscated` holding that only the confiscation flow reads back.
- **Server authoritative** — client requests pass a per-family field whitelist, mutations run under ordered multi-inventory locks, actions carry cooldowns and sanitized inputs.
- **Efficient persistence** — inventories cached in memory, written in batches, autosaved every five minutes, flushed on stop; sessions are restored after a resource restart.
- **Dark premium NUI** — Vue 3 drag-and-drop interface on the SIKU dark art direction, with tooltips, context menus, split/give dialogs, weapon dialogs and a full offline mock for browser development.
- **i18n pipeline** — the server language is pushed to the NUI at runtime (`fr` / `en`).

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) | Yes (≥ 0.2.0) | Framework core: character cache, migrations, commands, permissions, timers. |
| [oxmysql](https://github.com/CommunityOx/oxmysql) | Yes | Database access. |

`siku_core` must be started **before** `siku_inventory`.

## Installation

### From a release (recommended)

Download the latest [release](https://github.com/siku-project/siku_inventory/releases) zip and extract it into your server resources folder. The zip ships with the NUI **already built** — no build step, ready to run.

### From source

```bash
git clone git@github.com:siku-project/siku_inventory.git
cd siku_inventory/web
bun install
bun run build
```

### server.cfg

```cfg
ensure oxmysql
ensure siku_core
ensure siku_inventory
```

## Configuration

All options live in `config/` and are documented inline.

| File | Options |
|---|---|
| `config/inventory.lua` | `slots`, `maxWeight`, `groundDistance`, `giveDistance`, `stashDistance`, `temporaryStashLifetime`, `dropLifetime`, `dropSweepInterval`, `actionCooldown`, `decay`, `reload`, `disableWeaponWheel`, `disableWeaponBash`, `openKey`, `stashKey`, `blurWorld`, `staffRole` |
| `config/migration.lua` | Schema declaration, applied through the core migration service |
| `config/translation.lua` | `language` (`fr` / `en`) |

### Keybinds

| Key | Action |
|---|---|
| `TAB` | Open / close the inventory |
| `1` – `5` | Use the hotbar slot |
| `R` | Reload the drawn weapon |
| `E` | Open the stash in reach |

All rebindable per player through the GTA keybind settings.

## Declaring content

The `shared/` data files are the source of truth, validated at startup — a missing structural property is reported by name, never guessed:

| File | Declares |
|---|---|
| `shared/items.lua` | Item kinds: identity, label, weight, stacking, uniqueness, usability, decay, uses. The file header documents every field. |
| `shared/weapons.lua`, `shared/ammo.lua`, `shared/components.lua` | Weapons, their ammunition and attachments. |
| `shared/stashes.lua` | Stashes declared with the resource: label, slots, weight, coords, access. |
| `shared/vehicles.lua` | Trunk and glovebox capacities per vehicle class. |

## API

### Reading and mutating (server)

| Export | Purpose |
|---|---|
| `GetInventory`, `GetItems`, `GetItem`, `GetSlot`, `GetItemSlots`, `GetItemCount`, `GetItemByUid` | Read an inventory, its stacks, one definition, one slot, or locate instances. |
| `AddItem`, `RemoveItem`, `ClearInventory`, `SetItemMetadata`, `SetMaxWeight`, `CanCarryItem` | Mutate content and capacity, always clamped and weight-checked. |
| `GetCurrentWeapon` | The weapon a session has drawn. |
| `DisplayMetadata`, `HideMetadata` | Choose which metadata keys the interface shows. |

### Item uses (server)

| Export | Purpose |
|---|---|
| `RegisterItemUse`, `UnregisterItemUse` | Attach behavior to a usable item — a function, or a table with `canUse` checked before any progress starts. |

```lua
exports.siku_inventory:RegisterItemUse('bandage', function(source, stack)
  -- validated server-side; consume, heal, notify…
  return true
end)
```

### Stashes and containers (server)

| Export | Purpose |
|---|---|
| `RegisterStash`, `UnregisterStash` | Declare a stash at runtime. |
| `CreateTemporaryStash`, `RemoveTemporaryStash` | Short-lived stashes that expire on their own. |
| `SetStashAccess` | Per-stash access rule; `SetGroupProvider` plugs a job/group system in wholesale. |
| `RegisterContainer`, `UnregisterContainer` | A new container kind, with its own resolve and validate. |
| `OpenContainer`, `CloseContainer` | Drive a container view from another resource. |
| `ConfiscateInventory`, `ReturnInventory` | Move a character's belongings to the sealed holding and back. |

### Client exports

`OpenInventory`, `CloseInventory`, `IsInventoryOpen`, `OpenContainer`, `UseSlot`, `UseItem`, `GiveItemToTarget`, `GetHotbarSlot`, `GetCurrentWeapon`, `GetInventory`, `GetItemSlots`, `GetItemCount`.

## Commands

Granted automatically to the configured `staffRole`:

| Command | Permission | Purpose |
|---|---|---|
| `/giveitem` | `inventory.staff.giveItem` | Hand an item to a player. |
| `/clearinv` | `inventory.staff.clearInventory` | Empty a player's inventory, rank-checked. |
| `/randomitems` | `inventory.staff.randomItems` | Fill an inventory with random stacks, for testing. |

## Database

Two tables, created through the core migration service: `inventories` (one row per container — character, stash, drop, trunk — keyed by owner type) and `inventory_items` (one row per stack, with metadata, freshness, uses and unique identifiers).

## Development

The NUI lives in `web/` (Vue 3, Pinia, Tailwind, Vite — built with [bun](https://bun.sh)).

```bash
cd web
bun install
bun dev          # browser playground against a full mock server
bun run build    # production build → web/dist
bun run check    # format + type-check + lint
```

In development the interface runs against `mock/server.ts`, a complete simulation sharing the real code path — drag, split, give, containers and weapons all work in the browser.

```
siku_inventory/
├── client/modules/    # UI, keybinds, NUI bridge, stash points, vehicles, weapons
├── server/modules/    # core, actions, containers, stashes, ground, weapons, persistence, api
├── shared/            # item, weapon, ammo, component, stash and vehicle data
├── config/            # behavior, schema, language
├── translations/      # fr / en
└── web/               # Vue 3 NUI
```

## Credits

Part of the [SIKU project](https://github.com/siku-project) — © Siku Studio.
