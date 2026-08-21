InventoryConfig = {
  --- Number of slots in a character inventory.
  ---
  --- Changing this on a live server never destroys anything: items sitting
  --- beyond the new limit stay in database and reappear if the value goes
  --- back up. They are simply not reachable in the meantime.
  ---
  --- Default: 40
  slots = 40,

  --- Maximum weight a character can carry, in grams.
  ---
  --- Every weight in this resource is expressed in grams — the interface
  --- turns them into a readable unit on its own.
  ---
  --- Default: 35000 (35 kg)
  maxWeight = 35000,

  --- How far a character reaches to see and pick up ground items, in metres.
  ---
  --- The check runs on the server against the real ped position, so a
  --- client asking for a distant drop is refused.
  ---
  --- Default: 2.5
  groundDistance = 2.5,

  --- How far a character reaches to hand an item to somebody else, in metres.
  ---
  --- Default: 3.0
  giveDistance = 3.0,

  --- How close a character stands to open a stash, in metres.
  ---
  --- Used by every stash that did not name its own distance. The check runs
  --- on the server against the real ped position, and it runs again while the
  --- stash is open: walking away closes it.
  ---
  --- Only stashes that declared coords are concerned. One opened by a script
  --- rather than by walking up to it has nowhere to be near.
  ---
  --- Default: 2.0
  stashDistance = 2.0,

  --- How long a temporary stash lives before it is removed, in milliseconds.
  ---
  --- A temporary stash and everything left in it disappear together. Set it
  --- to 0 to let one live until the resource restarts.
  ---
  --- Default: 1800000 (30 minutes)
  temporaryStashLifetime = 1800000,

  --- How long a dropped stack stays on the ground before it disappears, in
  --- milliseconds. Set it to 0 to keep drops forever.
  ---
  --- Expired drops are removed from database, not just hidden.
  ---
  --- Default: 900000 (15 minutes)
  dropLifetime = 900000,

  --- How often expired drops are swept, in milliseconds.
  ---
  --- Ignored when dropLifetime is 0.
  ---
  --- Default: 60000 (1 minute)
  dropSweepInterval = 60000,

  --- Minimum delay between two actions coming from the same player, in
  --- milliseconds.
  ---
  --- This is a spam guard, not a gameplay cooldown: it only rejects bursts
  --- a human hand cannot produce.
  ---
  --- Default: 50
  actionCooldown = 50,

  --- How perishable items spoil.
  ---
  --- An item declares a decay *speed* between 1 and 10 rather than a
  --- duration, and the reference below says what one speed point is worth.
  --- Raising or lowering this single number retunes every perishable item at
  --- once, which is the point: a server owner tunes the economy here, not by
  --- editing ten item definitions.
  ---
  --- An instance stays good for `reference / speed` milliseconds. With the
  --- default reference, speed 1 lasts twelve hours and speed 10 lasts a
  --- little over one hour.
  decay = {
    --- Lifetime of a decay speed of 1, in milliseconds.
    ---
    --- Default: 43200000 (12 hours)
    reference = 43200000,

    --- Below this share of remaining freshness, the interface marks the
    --- instance as going off.
    ---
    --- Default: 0.25
    warnBelow = 0.25,
  },

  --- How loading a weapon feels.
  ---
  --- How many rounds a magazine holds is never a setting: the game ships that
  --- number for every weapon it has and it is asked, not copied. What is a
  --- setting is whether loading takes time on this server.
  reload = {
    --- Whether loading occupies the character for a moment.
    ---
    --- Off, the magazine fills the instant it is asked for, the way the game
    --- does it on its own. On, a progress bar runs for the duration below and
    --- the character cannot fire until it ends.
    ---
    --- Default: true
    timed = true,

    --- How long loading takes, in milliseconds. Ignored when timed is off.
    ---
    --- Default: 2200
    duration = 2200,
  },

  --- Whether the game's own weapon wheel is switched off.
  ---
  --- Weapons are items in this resource, so what a character holds is decided
  --- by the inventory. Leaving the wheel on would give a player a second way
  --- to arm themselves that the server knows nothing about.
  ---
  --- Turn it off only if another resource already blocks the wheel; two
  --- resources fighting over the same controls is worse than either alone.
  ---
  --- Default: true
  disableWeaponWheel = true,

  --- Key that opens the inventory.
  ---
  --- Uses the FiveM control name — see the RegisterKeyMapping documentation
  --- for the full list.
  ---
  --- Default: 'i'
  openKey = 'i',

  --- Key that opens the stash a character is standing next to.
  ---
  --- Only ever does anything while a stash declaring coords is within reach,
  --- and a prompt says so before the key means anything. A server using a
  --- target resource instead can point it at the OpenStash export and ignore
  --- this entirely.
  ---
  --- Default: 'e'
  stashKey = 'e',

  --- Whether the world is blurred while the inventory is open.
  ---
  --- Uses the game's own screen effect, not a CSS filter: no cost on the
  --- interface, and it looks native.
  ---
  --- Default: true
  blurWorld = true,
}
