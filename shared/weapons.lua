--- Weapon definitions.
---
--- The second of the three files that feed the catalogue, beside items.lua and
--- components.lua. A weapon is an item of `type = 'weapon'` like any other —
--- nothing about the model changes here. They live in a file of their own
--- because there are a hundred of them.
---
--- Like items.lua, nothing is implicit. Every entry states its own weight, its
--- own artwork and its own booleans, so reading one entry answers every
--- question about that weapon without looking anywhere else.
---
--- Categories
---   A weapon belongs to a family, and the family is only a name: what the
---   interface calls the weapon when it describes it. It decides nothing. Two
---   weapons of the same family may weigh differently and feed on different
---   rounds, and each says so for itself.
---
--- Required on every weapon
---   name         string, the name the game knows it by
---   label        string, the human name
---   type         string, 'weapon'
---   weight       number, grams for one weapon, zero or more
---   image        string, file name inside web/src/assets/images/items
---   stackable    boolean, whether two may ever share a slot
---   unique       boolean, whether every instance is tracked on its own
---   usable       boolean, whether the use action is offered
---   closeOnUse   boolean, whether the interface closes once a use is accepted
---   description  string, one or two sentences
---   category     string, one of the families below
---   ammoType     string naming an entry of ammo.lua, or false when the weapon
---                fires nothing: a blade, a thrown charge, a gadget, or an
---                energy weapon carrying its own supply
---
--- What is deliberately not written here
---   How many rounds a weapon holds. The game knows the size of every
---   magazine it ships, and asking it beats keeping a hundred numbers in step
---   with it by hand — the same reason component compatibility is not listed
---   either. One round is one item of the declared ammoType, and the client
---   reads the capacity off the engine when it loads.
---
---   The serial number and the round count carried by an instance are also
---   absent: they are the same two properties for every weapon and follow
---   from `ammoType`, so they are attached on expansion rather than repeated
---   a hundred times.
WeaponCategories = {
  melee = { label = 'weapon.category.melee' },
  pistol = { label = 'weapon.category.pistol' },
  smg = { label = 'weapon.category.smg' },
  shotgun = { label = 'weapon.category.shotgun' },
  rifle = { label = 'weapon.category.rifle' },
  sniper = { label = 'weapon.category.sniper' },
  machinegun = { label = 'weapon.category.machinegun' },
  heavy = { label = 'weapon.category.heavy' },
  throwable = { label = 'weapon.category.throwable' },
  other = { label = 'weapon.category.other' },
}

Weapons = {
  --- Melee
  nightstick = {
    name = 'WEAPON_NIGHTSTICK',
    label = 'Nightstick',
    type = 'weapon',

    weight = 900,
    image = 'weapon_nightstick.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une matraque de service en polycarbonate. Elle ne coupe pas, elle brise.',

    category = 'melee',
    ammoType = false,
  },

  bat = {
    name = 'WEAPON_BAT',
    label = 'Baseball Bat',
    type = 'weapon',

    weight = 1000,
    image = 'weapon_bat.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une batte en aluminium. Personne ne la sort pour jouer.',

    category = 'melee',
    ammoType = false,
  },

  knife = {
    name = 'WEAPON_KNIFE',
    label = 'Knife',
    type = 'weapon',

    weight = 250,
    image = 'weapon_knife.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une lame courte à manche caoutchouté. Discrète, et sans bruit.',

    category = 'melee',
    ammoType = false,
  },

  golfclub = {
    name = 'WEAPON_GOLFCLUB',
    label = 'Golf Club',
    type = 'weapon',

    weight = 1200,
    image = 'weapon_golfclub.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fer de golf qui n\'a jamais vu un parcours.',

    category = 'melee',
    ammoType = false,
  },

  hammer = {
    name = 'WEAPON_HAMMER',
    label = 'Hammer',
    type = 'weapon',

    weight = 800,
    image = 'weapon_hammer.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un marteau de charpentier. L\'outil le plus honnête du lot.',

    category = 'melee',
    ammoType = false,
  },

  crowbar = {
    name = 'WEAPON_CROWBAR',
    label = 'Crowbar',
    type = 'weapon',

    weight = 1400,
    image = 'weapon_crowbar.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pied-de-biche. Il ouvre des portes, et le reste aussi.',

    category = 'melee',
    ammoType = false,
  },

  bottle = {
    name = 'WEAPON_BOTTLE',
    label = 'Broken Bottle',
    type = 'weapon',

    weight = 300,
    image = 'weapon_bottle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un tesson tenu par le goulot. L\'arme des fins de soirée.',

    category = 'melee',
    ammoType = false,
  },

  dagger = {
    name = 'WEAPON_DAGGER',
    label = 'Antique Cavalry Dagger',
    type = 'weapon',

    weight = 400,
    image = 'weapon_dagger.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une dague de cavalerie à lame gravée. Une pièce de collection, toujours affûtée.',

    category = 'melee',
    ammoType = false,
  },

  hatchet = {
    name = 'WEAPON_HATCHET',
    label = 'Hatchet',
    type = 'weapon',

    weight = 900,
    image = 'weapon_hatchet.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une hachette de bûcheron, le fil ébréché.',

    category = 'melee',
    ammoType = false,
  },

  machete = {
    name = 'WEAPON_MACHETE',
    label = 'Machete',
    type = 'weapon',

    weight = 700,
    image = 'weapon_machete.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une lame large et souple, tachée de sève.',

    category = 'melee',
    ammoType = false,
  },

  switchblade = {
    name = 'WEAPON_SWITCHBLADE',
    label = 'Switchblade',
    type = 'weapon',

    weight = 200,
    image = 'weapon_switchblade.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un couteau à cran d\'arrêt. Il tient dans une poche revolver.',

    category = 'melee',
    ammoType = false,
  },

  poolcue = {
    name = 'WEAPON_POOLCUE',
    label = 'Pool Cue',
    type = 'weapon',

    weight = 600,
    image = 'weapon_poolcue.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une queue de billard. Le petit bout casse en premier.',

    category = 'melee',
    ammoType = false,
  },

  battleaxe = {
    name = 'WEAPON_BATTLEAXE',
    label = 'Battle Axe',
    type = 'weapon',

    weight = 2600,
    image = 'weapon_battleaxe.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une hache de bataille, lourde et mal équilibrée.',

    category = 'melee',
    ammoType = false,
  },

  wrench = {
    name = 'WEAPON_WRENCH',
    label = 'Pipe Wrench',
    type = 'weapon',

    weight = 1600,
    image = 'weapon_wrench.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une clé à molette de plombier. Deux kilos de levier.',

    category = 'melee',
    ammoType = false,
  },

  stone_hatchet = {
    name = 'WEAPON_STONE_HATCHET',
    label = 'Stone Hatchet',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_stone_hatchet.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une hachette de pierre taillée. Plus vieille que la poudre.',

    category = 'melee',
    ammoType = false,
  },

  candycane = {
    name = 'WEAPON_CANDYCANE',
    label = 'Candy Cane',
    type = 'weapon',

    weight = 300,
    image = 'weapon_candycane.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une canne en sucre d\'orge, dure comme du verre.',

    category = 'melee',
    ammoType = false,
  },

  stunrod = {
    name = 'WEAPON_STUNROD',
    label = 'The Shocker',
    type = 'weapon',

    weight = 900,
    image = 'weapon_stunrod.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un bâton électrique. Une décharge suffit à mettre à genoux.',

    category = 'melee',
    ammoType = false,
  },

  knuckle = {
    name = 'WEAPON_KNUCKLE',
    label = 'Brass Knuckles',
    type = 'weapon',

    weight = 350,
    image = 'weapon_knuckle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un poing américain en laiton, gravé au nom de son propriétaire.',

    category = 'melee',
    ammoType = false,
  },

  --- Handguns
  pistol = {
    name = 'WEAPON_PISTOL',
    label = 'Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_pistol.webp',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Le pistolet de service standard. Fiable, sans surprise, partout.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  snspistol = {
    name = 'WEAPON_SNSPISTOL',
    label = 'SNS Pistol',
    type = 'weapon',

    weight = 700,
    image = 'weapon_snspistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet bon marché, fondu en série. Il s\'enraye une fois sur dix.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  gadgetpistol = {
    name = 'WEAPON_GADGETPISTOL',
    label = 'Perico Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_gadgetpistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet de luxe à finition dorée. Un objet de vitrine qui tire.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  flaregun = {
    name = 'WEAPON_FLAREGUN',
    label = 'Flare Gun',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_flaregun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet de détresse. Il signale plus qu\'il ne blesse.',

    category = 'pistol',
    ammoType = 'ammo-flare',
  },

  marksmanpistol = {
    name = 'WEAPON_MARKSMANPISTOL',
    label = 'Marksman Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_marksmanpistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet à un coup, canon long. Tout se joue au premier.',

    category = 'pistol',
    ammoType = 'ammo-50',
  },

  navyrevolver = {
    name = 'WEAPON_NAVYREVOLVER',
    label = 'Navy Revolver',
    type = 'weapon',

    weight = 1400,
    image = 'weapon_navyrevolver.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un revolver d\'ordonnance du siècle dernier, encore en état de marche.',

    category = 'pistol',
    ammoType = 'ammo-38',
  },

  doubleaction = {
    name = 'WEAPON_DOUBLEACTION',
    label = 'Double-Action Revolver',
    type = 'weapon',

    weight = 1300,
    image = 'weapon_doubleaction.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un revolver double action au barillet gravé.',

    category = 'pistol',
    ammoType = 'ammo-38',
  },

  raypistol = {
    name = 'WEAPON_RAYPISTOL',
    label = 'Up-n-Atomizer',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_raypistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une arme à énergie, sans chargeur ni douille. Elle avale des cellules.',

    category = 'pistol',
    ammoType = 'ammo-laser',
  },

  heavypistol = {
    name = 'WEAPON_HEAVYPISTOL',
    label = 'Heavy Pistol',
    type = 'weapon',

    weight = 1300,
    image = 'weapon_heavypistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet à carcasse acier. Le recul se sent dans l\'épaule.',

    category = 'pistol',
    ammoType = 'ammo-45',
  },

  snspistol_mk2 = {
    name = 'WEAPON_SNSPISTOL_MK2',
    label = 'SNS Pistol Mk II',
    type = 'weapon',

    weight = 750,
    image = 'weapon_snspistol_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'La version retravaillée du SNS. Toujours bon marché, un peu moins capricieuse.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  revolver = {
    name = 'WEAPON_REVOLVER',
    label = 'Heavy Revolver',
    type = 'weapon',

    weight = 1500,
    image = 'weapon_revolver.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un revolver massif. Un coup suffit, encore faut-il le placer.',

    category = 'pistol',
    ammoType = 'ammo-44',
  },

  vintagepistol = {
    name = 'WEAPON_VINTAGEPISTOL',
    label = 'Vintage Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_vintagepistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet d\'avant-guerre, crosse en nacre. Il se porte plus qu\'il ne se tire.',

    category = 'pistol',
    ammoType = 'ammo-45',
  },

  appistol = {
    name = 'WEAPON_APPISTOL',
    label = 'AP Pistol',
    type = 'weapon',

    weight = 1200,
    image = 'weapon_appistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet automatique. Il vide son chargeur avant qu\'on ait relâché la détente.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  revolver_mk2 = {
    name = 'WEAPON_REVOLVER_MK2',
    label = 'Heavy Revolver Mk II',
    type = 'weapon',

    weight = 1550,
    image = 'weapon_revolver_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un revolver lourd, canon renforcé et rail supérieur.',

    category = 'pistol',
    ammoType = 'ammo-44',
  },

  pistolxm3 = {
    name = 'WEAPON_PISTOLXM3',
    label = 'WM 29 Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_pistolxm3.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un revolver à carcasse massive, canon ventilé. Six coups, pas un de plus.',

    category = 'pistol',
    ammoType = 'ammo-44',
  },

  pistol50 = {
    name = 'WEAPON_PISTOL50',
    label = 'Pistol .50',
    type = 'weapon',

    weight = 1400,
    image = 'weapon_pistol50.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet de gros calibre. La détonation s\'entend d\'un pâté de maisons.',

    category = 'pistol',
    ammoType = 'ammo-50',
  },

  combatpistol = {
    name = 'WEAPON_COMBATPISTOL',
    label = 'Combat Pistol',
    type = 'weapon',

    weight = 1100,
    image = 'weapon_combatpistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet compact conçu pour être porté toute la journée.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  pistol_mk2 = {
    name = 'WEAPON_PISTOL_MK2',
    label = 'Pistol Mk II',
    type = 'weapon',

    weight = 1150,
    image = 'weapon_pistol_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Le pistolet standard remis au goût du jour, rails et crosse texturée.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  ceramicpistol = {
    name = 'WEAPON_CERAMICPISTOL',
    label = 'Ceramic Pistol',
    type = 'weapon',

    weight = 800,
    image = 'weapon_ceramicpistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet en céramique, presque invisible aux portiques.',

    category = 'pistol',
    ammoType = 'ammo-9',
  },

  stungun = {
    name = 'WEAPON_STUNGUN',
    label = 'Stun Gun',
    type = 'weapon',

    weight = 900,
    image = 'weapon_stungun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet à impulsion. Deux fils, une cartouche, et la cible tombe.',

    category = 'pistol',

    --- The one firearm here that loads nothing: it carries its own charge, so
    --- there is no round to declare and nothing to reload.
    ammoType = false,
  },

  --- Submachine guns
  smg_mk2 = {
    name = 'WEAPON_SMG_MK2',
    label = 'SMG Mk II',
    type = 'weapon',

    weight = 2600,
    image = 'weapon_smg_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet-mitrailleur modernisé, canon flottant et rails partout.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  smg = {
    name = 'WEAPON_SMG',
    label = 'SMG',
    type = 'weapon',

    weight = 2600,
    image = 'weapon_smg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet-mitrailleur compact. Il monte vite en cadence.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  machinepistol = {
    name = 'WEAPON_MACHINEPISTOL',
    label = 'Machine Pistol',
    type = 'weapon',

    weight = 1600,
    image = 'weapon_machinepistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet automatique à crosse repliable. Rien de précis.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  tecpistol = {
    name = 'WEAPON_TECPISTOL',
    label = 'Tactical SMG',
    type = 'weapon',

    weight = 1900,
    image = 'weapon_tecpistol.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet-mitrailleur tactique, court et maniable en voiture.',

    category = 'smg',
    ammoType = 'ammo-45',
  },

  assaultsmg = {
    name = 'WEAPON_ASSAULTSMG',
    label = 'Assault SMG',
    type = 'weapon',

    weight = 3000,
    image = 'weapon_assaultsmg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un pistolet-mitrailleur d\'assaut, lourd pour sa catégorie.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  combatpdw = {
    name = 'WEAPON_COMBATPDW',
    label = 'Combat PDW',
    type = 'weapon',

    weight = 2800,
    image = 'weapon_combatpdw.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une arme de défense rapprochée, chargeur long et crosse pliante.',

    category = 'smg',
    ammoType = 'ammo-rifle',
  },

  microsmg = {
    name = 'WEAPON_MICROSMG',
    label = 'Micro SMG',
    type = 'weapon',

    weight = 1800,
    image = 'weapon_microsmg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un micro pistolet-mitrailleur. Il tient sous une veste.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  minismg = {
    name = 'WEAPON_MINISMG',
    label = 'Mini SMG',
    type = 'weapon',

    weight = 1700,
    image = 'weapon_minismg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une arme minuscule à cadence absurde. Elle vide tout en trois secondes.',

    category = 'smg',
    ammoType = 'ammo-9',
  },

  --- Shotguns
  autoshotgun = {
    name = 'WEAPON_AUTOSHOTGUN',
    label = 'Sweeper Shotgun',
    type = 'weapon',

    weight = 3200,
    image = 'weapon_autoshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil à pompe automatique, chargeur tambour.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  assaultshotgun = {
    name = 'WEAPON_ASSAULTSHOTGUN',
    label = 'Assault Shotgun',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_assaultshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil de combat à chargeur amovible.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  combatshotgun = {
    name = 'WEAPON_COMBATSHOTGUN',
    label = 'Combat Shotgun',
    type = 'weapon',

    weight = 3200,
    image = 'weapon_combatshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil semi-automatique de police, canon court.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  heavyshotgun = {
    name = 'WEAPON_HEAVYSHOTGUN',
    label = 'Heavy Shotgun',
    type = 'weapon',

    weight = 3900,
    image = 'weapon_heavyshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil lourd. Le recul se paie à chaque coup.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  pumpshotgun_mk2 = {
    name = 'WEAPON_PUMPSHOTGUN_MK2',
    label = 'Pump Shotgun Mk II',
    type = 'weapon',

    weight = 3400,
    image = 'weapon_pumpshotgun_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil à pompe modernisé, crosse réglable et rail supérieur.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  sawnoffshotgun = {
    name = 'WEAPON_SAWNOFFSHOTGUN',
    label = 'Sawed-Off Shotgun',
    type = 'weapon',

    weight = 2400,
    image = 'weapon_sawnoffshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil scié aux deux bouts. Il ne vise rien au-delà de dix mètres.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  bullpupshotgun = {
    name = 'WEAPON_BULLPUPSHOTGUN',
    label = 'Bullpup Shotgun',
    type = 'weapon',

    weight = 3200,
    image = 'weapon_bullpupshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil bullpup. Le chargeur est derrière la détente.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  pumpshotgun = {
    name = 'WEAPON_PUMPSHOTGUN',
    label = 'Pump Shotgun',
    type = 'weapon',

    weight = 3200,
    image = 'weapon_pumpshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil à pompe classique. Le bruit du réarmement fait la moitié du travail.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  dbshotgun = {
    name = 'WEAPON_DBSHOTGUN',
    label = 'Double-Barrel Shotgun',
    type = 'weapon',

    weight = 3000,
    image = 'weapon_dbshotgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil juxtaposé à deux coups, crosse en bois.',

    category = 'shotgun',
    ammoType = 'ammo-shotgun',
  },

  --- Assault rifles
  advancedrifle = {
    name = 'WEAPON_ADVANCEDRIFLE',
    label = 'Advanced Rifle',
    type = 'weapon',

    weight = 3300,
    image = 'weapon_advancedrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une carabine compacte à poignée haute.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  bullpuprifle = {
    name = 'WEAPON_BULLPUPRIFLE',
    label = 'Bullpup Rifle',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_bullpuprifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil bullpup, ramassé et bien équilibré.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  compactrifle = {
    name = 'WEAPON_COMPACTRIFLE',
    label = 'Compact Rifle',
    type = 'weapon',

    weight = 2900,
    image = 'weapon_compactrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil d\'assaut raccourci, chargeur camembert.',

    category = 'rifle',
    ammoType = 'ammo-rifle2',
  },

  tacticalrifle = {
    name = 'WEAPON_TACTICALRIFLE',
    label = 'Service Carbine',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_tacticalrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une carabine de service, canon inox et garde-main ventilé.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  carbinerifle_mk2 = {
    name = 'WEAPON_CARBINERIFLE_MK2',
    label = 'Carbine Rifle Mk II',
    type = 'weapon',

    weight = 3700,
    image = 'weapon_carbinerifle_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'La carabine remise à niveau : garde-main long, crosse réglable.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  assaultrifle_mk2 = {
    name = 'WEAPON_ASSAULTRIFLE_MK2',
    label = 'Assault Rifle Mk II',
    type = 'weapon',

    weight = 3800,
    image = 'weapon_assaultrifle_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil d\'assaut modernisé, chargeur incurvé.',

    category = 'rifle',
    ammoType = 'ammo-rifle2',
  },

  assaultrifle = {
    name = 'WEAPON_ASSAULTRIFLE',
    label = 'Assault Rifle',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_assaultrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Le fusil d\'assaut le plus répandu. Il fonctionne sale.',

    category = 'rifle',
    ammoType = 'ammo-rifle2',
  },

  carbinerifle = {
    name = 'WEAPON_CARBINERIFLE',
    label = 'Carbine Rifle',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_carbinerifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une carabine d\'assaut polyvalente, à l\'aise partout.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  heavyrifle = {
    name = 'WEAPON_HEAVYRIFLE',
    label = 'Heavy Rifle',
    type = 'weapon',

    weight = 4100,
    image = 'weapon_heavyrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil lourd à canon épais. Il ne se porte pas discrètement.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  battlerifle = {
    name = 'WEAPON_BATTLERIFLE',
    label = 'Battle Rifle',
    type = 'weapon',

    weight = 4300,
    image = 'weapon_battlerifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil de combat à canon long, calibre plein.',

    category = 'rifle',
    ammoType = 'ammo-sniper',
  },

  militaryrifle = {
    name = 'WEAPON_MILITARYRIFLE',
    label = 'Military Rifle',
    type = 'weapon',

    weight = 3900,
    image = 'weapon_militaryrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil d\'ordonnance, poignée pistolet et rail continu.',

    category = 'rifle',
    ammoType = 'ammo-rifle2',
  },

  bullpuprifle_mk2 = {
    name = 'WEAPON_BULLPUPRIFLE_MK2',
    label = 'Bullpup Rifle Mk II',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_bullpuprifle_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Le bullpup révisé : détente reprise, garde-main allongé.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  specialcarbine_mk2 = {
    name = 'WEAPON_SPECIALCARBINE_MK2',
    label = 'Special Carbine Mk II',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_specialcarbine_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'La carabine spéciale revue, crosse pliante et rails.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  specialcarbine = {
    name = 'WEAPON_SPECIALCARBINE',
    label = 'Special Carbine',
    type = 'weapon',

    weight = 3600,
    image = 'weapon_specialcarbine.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une carabine sans défaut marquant. Elle fait tout correctement.',

    category = 'rifle',
    ammoType = 'ammo-rifle',
  },

  --- Sniper rifles
  marksmanrifle_mk2 = {
    name = 'WEAPON_MARKSMANRIFLE_MK2',
    label = 'Marksman Rifle Mk II',
    type = 'weapon',

    weight = 4800,
    image = 'weapon_marksmanrifle_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil de tireur d\'élite modernisé, bipied intégré.',

    category = 'sniper',
    ammoType = 'ammo-sniper',
  },

  heavysniper_mk2 = {
    name = 'WEAPON_HEAVYSNIPER_MK2',
    label = 'Heavy Sniper Mk II',
    type = 'weapon',

    weight = 6200,
    image = 'weapon_heavysniper_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil anti-matériel révisé. Il traverse ce qui se met devant.',

    category = 'sniper',
    ammoType = 'ammo-heavysniper',
  },

  sniperrifle = {
    name = 'WEAPON_SNIPERRIFLE',
    label = 'Sniper Rifle',
    type = 'weapon',

    weight = 5400,
    image = 'weapon_sniperrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil à verrou, lunette d\'origine. Un coup, une respiration.',

    category = 'sniper',
    ammoType = 'ammo-sniper',
  },

  precisionrifle = {
    name = 'WEAPON_PRECISIONRIFLE',
    label = 'Precision Rifle',
    type = 'weapon',

    weight = 5000,
    image = 'weapon_precisionrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil de précision à crosse châssis, réglable au millimètre.',

    category = 'sniper',
    ammoType = 'ammo-sniper',
  },

  musket = {
    name = 'WEAPON_MUSKET',
    label = 'Musket',
    type = 'weapon',

    weight = 4200,
    image = 'weapon_musket.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un mousquet à chargement par la bouche. Un coup, puis une longue minute.',

    category = 'sniper',
    ammoType = 'ammo-musket',
  },

  marksmanrifle = {
    name = 'WEAPON_MARKSMANRIFLE',
    label = 'Marksman Rifle',
    type = 'weapon',

    weight = 4700,
    image = 'weapon_marksmanrifle.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un semi-automatique de tireur désigné. Il comble le vide entre carabine et sniper.',

    category = 'sniper',
    ammoType = 'ammo-sniper',
  },

  heavysniper = {
    name = 'WEAPON_HEAVYSNIPER',
    label = 'Heavy Sniper',
    type = 'weapon',

    weight = 6000,
    image = 'weapon_heavysniper.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un fusil anti-matériel. Il n\'a pas été conçu pour des cibles humaines.',

    category = 'sniper',
    ammoType = 'ammo-heavysniper',
  },

  --- Machine guns
  raycarbine = {
    name = 'WEAPON_RAYCARBINE',
    label = 'Unholy Hellbringer',
    type = 'weapon',

    weight = 7800,
    image = 'weapon_raycarbine.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une arme à énergie à haute cadence. Elle chauffe et elle boit.',

    category = 'machinegun',
    ammoType = 'ammo-laser',
  },

  mg = {
    name = 'WEAPON_MG',
    label = 'MG',
    type = 'weapon',

    weight = 7800,
    image = 'weapon_mg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mitrailleuse à bande. Elle se tire debout, mal.',

    category = 'machinegun',
    ammoType = 'ammo-mg',
  },

  gusenberg = {
    name = 'WEAPON_GUSENBERG',
    label = 'Gusenberg Sweeper',
    type = 'weapon',

    weight = 4500,
    image = 'weapon_gusenberg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mitrailleuse d\'époque à chargeur tambour. Une pièce de musée bruyante.',

    category = 'machinegun',
    ammoType = 'ammo-45',
  },

  combatmg = {
    name = 'WEAPON_COMBATMG',
    label = 'Combat MG',
    type = 'weapon',

    weight = 8200,
    image = 'weapon_combatmg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mitrailleuse de combat, bipied replié sous le canon.',

    category = 'machinegun',
    ammoType = 'ammo-mg',
  },

  combatmg_mk2 = {
    name = 'WEAPON_COMBATMG_MK2',
    label = 'Combat MG Mk II',
    type = 'weapon',

    weight = 8400,
    image = 'weapon_combatmg_mk2.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'La mitrailleuse de combat revue : canon lourd, boîtier renforcé.',

    category = 'machinegun',
    ammoType = 'ammo-mg',
  },

  --- Heavy weapons
  minigun = {
    name = 'WEAPON_MINIGUN',
    label = 'Minigun',
    type = 'weapon',

    weight = 26000,
    image = 'weapon_minigun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un canon rotatif de vingt-six kilos. Il faut le porter avant de le tirer.',

    category = 'heavy',
    ammoType = 'ammo-mg',
  },

  rayminigun = {
    name = 'WEAPON_RAYMINIGUN',
    label = 'Widowmaker',
    type = 'weapon',

    weight = 24000,
    image = 'weapon_rayminigun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un canon rotatif à énergie. Aucune douille, et pas un gramme de moins.',

    category = 'heavy',
    ammoType = 'ammo-laser',
  },

  rpg = {
    name = 'WEAPON_RPG',
    label = 'RPG',
    type = 'weapon',

    weight = 9500,
    image = 'weapon_rpg.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lance-roquettes à tube unique. Il se recharge par l\'avant, lentement.',

    category = 'heavy',
    ammoType = 'ammo-rocket',
  },

  compactlauncher = {
    name = 'WEAPON_COMPACTLAUNCHER',
    label = 'Compact Grenade Launcher',
    type = 'weapon',

    weight = 5200,
    image = 'weapon_compactlauncher.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lance-grenades compact à barillet.',

    category = 'heavy',
    ammoType = 'ammo-grenade',
  },

  grenadelauncher_smoke = {
    name = 'WEAPON_GRENADELAUNCHER_SMOKE',
    label = 'Tear Gas Launcher',
    type = 'weapon',

    weight = 9500,
    image = 'weapon_grenadelauncher_smoke.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lance-grenades chargé en gaz lacrymogène.',

    category = 'heavy',
    ammoType = 'ammo-grenade',
  },

  grenadelauncher = {
    name = 'WEAPON_GRENADELAUNCHER',
    label = 'Grenade Launcher',
    type = 'weapon',

    weight = 9500,
    image = 'weapon_grenadelauncher.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lance-grenades à barillet six coups.',

    category = 'heavy',
    ammoType = 'ammo-grenade',
  },

  railgun = {
    name = 'WEAPON_RAILGUN',
    label = 'Railgun',
    type = 'weapon',

    weight = 11000,
    image = 'weapon_railgun.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un canon électromagnétique. Le projectile part plus vite que le bruit ne revient.',

    category = 'heavy',
    ammoType = 'ammo-railgun',
  },

  hominglauncher = {
    name = 'WEAPON_HOMINGLAUNCHER',
    label = 'Homing Launcher',
    type = 'weapon',

    weight = 9500,
    image = 'weapon_hominglauncher.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lance-missiles à autodirecteur. Il faut tenir le verrouillage.',

    category = 'heavy',
    ammoType = 'ammo-rocket',
  },

  emplauncher = {
    name = 'WEAPON_EMPLAUNCHER',
    label = 'Compact EMP Launcher',
    type = 'weapon',

    weight = 5400,
    image = 'weapon_emplauncher.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lanceur à impulsion électromagnétique. Il éteint les moteurs, pas les gens.',

    category = 'heavy',
    ammoType = 'ammo-emp',
  },

  firework = {
    name = 'WEAPON_FIREWORK',
    label = 'Firework Launcher',
    type = 'weapon',

    weight = 4800,
    image = 'weapon_firework.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un tube de lancement d\'artifice. Spectaculaire, imprécis, illégal.',

    category = 'heavy',
    ammoType = 'ammo-firework',
  },

  snowlauncher = {
    name = 'WEAPON_SNOWLAUNCHER',
    label = 'Snowball Launcher',
    type = 'weapon',

    weight = 4000,
    image = 'weapon_snowlauncher.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un lanceur à boules de neige. Personne ne sait qui l\'a fabriqué.',

    category = 'heavy',
    ammoType = 'ammo-snowball',
  },

  railgunxm = {
    name = 'WEAPON_RAILGUNXM',
    label = 'Railgun XM3',
    type = 'weapon',

    weight = 11500,
    image = 'weapon_railgunxm.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un canon électromagnétique de dernière génération, batterie dorsale.',

    category = 'heavy',
    ammoType = 'ammo-railgun',
  },

  --- Throwables
  flare = {
    name = 'WEAPON_FLARE',
    label = 'Flare',
    type = 'weapon',

    weight = 200,
    image = 'weapon_flare.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une fusée éclairante à main. Elle brûle rouge pendant une minute.',

    category = 'throwable',
    ammoType = false,
  },

  snowball = {
    name = 'WEAPON_SNOWBALL',
    label = 'Snowball',
    type = 'weapon',

    weight = 150,
    image = 'weapon_snowball.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une boule de neige tassée à la main.',

    category = 'throwable',
    ammoType = false,
  },

  bzgas = {
    name = 'WEAPON_BZGAS',
    label = 'BZ Gas',
    type = 'weapon',

    weight = 600,
    image = 'weapon_bzgas.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une grenade de gaz incapacitant. L\'effet dure plus longtemps que le nuage.',

    category = 'throwable',
    ammoType = false,
  },

  stickybomb = {
    name = 'WEAPON_STICKYBOMB',
    label = 'Sticky Bomb',
    type = 'weapon',

    weight = 900,
    image = 'weapon_stickybomb.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une charge adhésive à détonation commandée.',

    category = 'throwable',
    ammoType = false,
  },

  smokegrenade = {
    name = 'WEAPON_SMOKEGRENADE',
    label = 'Tear Gas',
    type = 'weapon',

    weight = 600,
    image = 'weapon_smokegrenade.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une grenade lacrymogène. Elle vide une pièce en quelques secondes.',

    category = 'throwable',
    ammoType = false,
  },

  acidpackage = {
    name = 'WEAPON_ACIDPACKAGE',
    label = 'Acid Package',
    type = 'weapon',

    weight = 700,
    image = 'weapon_acidpackage.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un sachet d\'acide instable. Il ne supporte pas les chocs.',

    category = 'throwable',
    ammoType = false,
  },

  pipebomb = {
    name = 'WEAPON_PIPEBOMB',
    label = 'Pipe Bomb',
    type = 'weapon',

    weight = 800,
    image = 'weapon_pipebomb.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un tube de métal bourré de clous. Fabrication maison.',

    category = 'throwable',
    ammoType = false,
  },

  grenade = {
    name = 'WEAPON_GRENADE',
    label = 'Grenade',
    type = 'weapon',

    weight = 700,
    image = 'weapon_grenade.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une grenade à fragmentation. Cinq secondes après la cuillère.',

    category = 'throwable',
    ammoType = false,
  },

  molotov = {
    name = 'WEAPON_MOLOTOV',
    label = 'Molotov Cocktail',
    type = 'weapon',

    weight = 800,
    image = 'weapon_molotov.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une bouteille d\'essence et un chiffon. Rien de plus.',

    category = 'throwable',
    ammoType = false,
  },

  ball = {
    name = 'WEAPON_BALL',
    label = 'Baseball',
    type = 'weapon',

    weight = 150,
    image = 'weapon_ball.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une balle de baseball. Elle sert surtout à faire diversion.',

    category = 'throwable',
    ammoType = false,
  },

  newspaper = {
    name = 'WEAPON_NEWSPAPER',
    label = 'Newspaper',
    type = 'weapon',

    weight = 200,
    image = 'weapon_newspaper.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un journal roulé serré. Il ne fait de mal qu\'aux illusions.',

    category = 'throwable',
    ammoType = false,
  },

  proxmine = {
    name = 'WEAPON_PROXMINE',
    label = 'Proximity Mine',
    type = 'weapon',

    weight = 1000,
    image = 'weapon_proxmine.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mine de proximité. Elle attend, et elle n\'oublie pas.',

    category = 'throwable',
    ammoType = false,
  },

  --- Equipment: the game hands these out as weapons, but they fire nothing
  hackingdevice = {
    name = 'WEAPON_HACKINGDEVICE',
    label = 'Hacking Device',
    type = 'weapon',

    weight = 1200,
    image = 'weapon_hackingdevice.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un boîtier d\'intrusion à écran monochrome.',

    category = 'other',
    ammoType = false,
  },

  briefcase = {
    name = 'WEAPON_BRIEFCASE',
    label = 'Briefcase',
    type = 'weapon',

    weight = 2000,
    image = 'weapon_briefcase.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mallette en cuir. Ce qu\'elle contient ne se demande pas.',

    category = 'other',
    ammoType = false,
  },

  briefcase_02 = {
    name = 'WEAPON_BRIEFCASE_02',
    label = 'Briefcase',
    type = 'weapon',

    weight = 2000,
    image = 'weapon_briefcase_02.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mallette en cuir souple, serrure à combinaison.',

    category = 'other',
    ammoType = false,
  },

  briefcase_03 = {
    name = 'WEAPON_BRIEFCASE_03',
    label = 'Metal Briefcase',
    type = 'weapon',

    weight = 3000,
    image = 'weapon_briefcase_03.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Une mallette métallique verrouillée. Lourde, même vide.',

    category = 'other',
    ammoType = false,
  },

  digiscanner = {
    name = 'WEAPON_DIGISCANNER',
    label = 'Digital Scanner',
    type = 'weapon',

    weight = 900,
    image = 'weapon_digiscanner.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un scanner de poche. Il détecte des signaux qu\'on préférerait ignorer.',

    category = 'other',
    ammoType = false,
  },

  metaldetector = {
    name = 'WEAPON_METALDETECTOR',
    label = 'Metal Detector',
    type = 'weapon',

    weight = 1800,
    image = 'weapon_metaldetector.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un détecteur de métaux à disque large. Il siffle pour un rien.',

    category = 'other',
    ammoType = false,
  },
}
