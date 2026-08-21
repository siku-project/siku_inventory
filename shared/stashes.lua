--- Stash declarations.
---
--- A stash is a container that is not carried: a locker, a safe, a crate, a
--- shelf behind a counter. Every entry here exists from the moment the
--- resource starts and stays for as long as it runs. A script may declare
--- more at runtime through the `RegisterStash` export — the shape is the
--- same one described below.
---
--- What is written here is a *declaration*, never a content. The stash
--- inventory is created on first access and lives in database from then on,
--- so raising `slots` later gives more room to a stash people already use
--- rather than replacing it.
---
--- Required on every stash
---   name       string, the identifier. What the exports name and what the
---              database stores. It never changes once a stash has content.
---   label      string, the human name, shown at the top of the panel.
---   slots      number, how many slots it holds.
---   maxWeight  number, grams it holds in total.
---
--- Who it belongs to
---   `owner` answers one question: is there one stash, or one per person?
---
---   nil or false  one stash, shared by everybody who may open it. A town
---                 evidence locker, a shop reserve.
---   true          one stash per character. Everyone opening `policelocker`
---                 opens their own; a script may still ask for somebody
---                 else's by naming them.
---   string        one stash, bound to that identifier. Used when the owner
---                 is something other than a character — a gang, a business,
---                 a property.
---
---   This is not access control. Whether a character may open a stash at all
---   is answered by `groups`, by `coords` and by the openStash hook — never by
---   who it belongs to.
---
--- Optional
---   groups     table, the jobs allowed to open it, each mapped to the
---              minimum grade required: { police = 0, ambulance = 2 }. Absent
---              means anybody may open it.
---   coords     vector3 or a list of them. The stash can only be opened, and
---              stays open, while the character is standing near one of them.
---              Absent means it may be opened from anywhere, which is what a
---              stash opened by a script rather than by walking up to it
---              usually wants.
---   distance   number, how close is near enough, in metres. Defaults to
---              InventoryConfig.stashDistance.
---   instance   number, restricts the stash to one routing bucket. Two
---              instances of the same building then hold two different
---              stashes even though they share a name.
---   icon       string, the glyph shown in the panel header. Defaults to a
---              locker.
Stashes = {
  {
    name = 'policelocker',
    label = 'Casier personnel',

    slots = 70,
    maxWeight = 70000,

    owner = true,
    groups = { police = 0 },

    coords = vec3(452.3, -991.4, 30.7),
    icon = 'mdi-locker',
  },

  {
    name = 'policeevidence',
    label = 'Salle des scellés',

    slots = 100,
    maxWeight = 200000,

    groups = { police = 2 },

    coords = vec3(474.1, -1000.2, 30.68),
    icon = 'mdi-archive-outline',
  },

  {
    name = 'emslocker',
    label = 'Casier personnel',

    slots = 70,
    maxWeight = 70000,

    owner = true,
    groups = { ambulance = 0 },

    coords = vec3(301.3, -600.23, 43.28),
    icon = 'mdi-locker',
  },
}
