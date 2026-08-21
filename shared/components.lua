--- Weapon component definitions.
---
--- The third of the three files that feed the catalogue, beside items.lua and
--- weapons.lua. A component is an item of `type = 'component'` while it sits
--- in a bag; once fitted it stops being an item and becomes part of the weapon
--- it is bolted to, recorded in that instance's metadata.
---
--- Like items.lua, nothing is implicit. Every entry states its own weight, its
--- own artwork and its own booleans, so reading one entry answers every
--- question about that part without looking anywhere else.
---
--- Each entry declares the game components it stands for — usually several,
--- because the same part exists once per weapon family. A suppressor is
--- `COMPONENT_AT_PI_SUPP` on one pistol and `COMPONENT_CERAMICPISTOL_SUPP` on
--- another, but a player just owns "a suppressor".
---
--- Compatibility is deliberately not listed here. The client asks the game
--- whether the weapon in front of it accepts any of the variants, and the
--- first one it takes is the one fitted.
---
--- Required on every component
---   name         string, the business name of the part
---   label        string, the human name
---   type         string, 'component'
---   weight       number, grams for one part, zero or more
---   image        string, file name inside web/src/assets/images/items
---   stackable    boolean, whether two may ever share a slot
---   unique       boolean, whether every instance is tracked on its own
---   usable       boolean, whether the use action is offered
---   closeOnUse   boolean, whether the interface closes once a use is accepted
---   description  string, one or two sentences
---   slot         string, the attachment slot it occupies
---   variants     table, the game component names it may resolve to
---
--- The attachment point is called `slot`. It used to be called `type`, which
--- left this file saying `type` for the attachment point while its three
--- siblings said `type` for the family of the item — one name for two things,
--- one file apart. Here `type` now means what it means everywhere else.
---
--- Variant names are plain strings rather than backtick hashes: this file is
--- read by tooling and tests outside the game, and the client hashes them
--- itself.
Components = {
  at_flashlight = {
    name = 'at_flashlight',
    label = 'Tactical Flashlight',
    type = 'component',

    weight = 120,
    image = 'at_flashlight.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lampe montée sur rail. Elle éclaire la cible et signale le tireur.',

    slot = 'flashlight',
    variants = {
      'COMPONENT_AT_AR_FLSH',
      'COMPONENT_AT_AR_FLSH_REH',
      'COMPONENT_AT_PI_FLSH',
      'COMPONENT_AT_PI_FLSH_02',
      'COMPONENT_AT_PI_FLSH_03',
    },
  },

  at_suppressor_light = {
    name = 'at_suppressor_light',
    label = 'Suppressor',
    type = 'component',

    weight = 280,
    image = 'at_suppressor.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un silencieux de pistolet. Il étouffe la détonation sans la faire disparaître.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_PI_SUPP',
      'COMPONENT_AT_PI_SUPP_02',
      'COMPONENT_CERAMICPISTOL_SUPP',
      'COMPONENT_PISTOLXM3_SUPP',
    },
  },

  at_suppressor_heavy = {
    name = 'at_suppressor_heavy',
    label = 'Tactical Suppressor',
    type = 'component',

    weight = 280,
    image = 'at_suppressor.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un silencieux de fusil, long et brûlant après quelques rafales.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_AR_SUPP',
      'COMPONENT_AT_AR_SUPP_02',
      'COMPONENT_AT_SR_SUPP',
      'COMPONENT_AT_SR_SUPP_03',
    },
  },

  at_grip = {
    name = 'at_grip',
    label = 'Grip',
    type = 'component',

    weight = 280,
    image = 'at_grip.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une poignée avant. Elle tient la rafale plus bas.',

    slot = 'grip',
    variants = {
      'COMPONENT_AT_AR_AFGRIP',
      'COMPONENT_AT_AR_AFGRIP_02',
    },
  },

  at_barrel = {
    name = 'at_barrel',
    label = 'Heavy Barrel',
    type = 'component',

    weight = 280,
    image = 'at_barrel.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un canon lourd. Plus de précision, plus de poids à porter.',

    slot = 'barrel',
    variants = {
      'COMPONENT_AT_AR_BARREL_02',
      'COMPONENT_AT_BP_BARREL_02',
      'COMPONENT_AT_CR_BARREL_02',
      'COMPONENT_AT_MG_BARREL_02',
      'COMPONENT_AT_MRFL_BARREL_02',
      'COMPONENT_AT_SB_BARREL_02',
      'COMPONENT_AT_SC_BARREL_02',
      'COMPONENT_AT_SR_BARREL_02',
    },
  },

  at_clip_extended_pistol = {
    name = 'at_clip_extended_pistol',
    label = 'Extended Pistol Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_extended.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de pistolet rallongé. Il dépasse de la crosse.',

    slot = 'magazine',
    variants = {
      'COMPONENT_APPISTOL_CLIP_02',
      'COMPONENT_CERAMICPISTOL_CLIP_02',
      'COMPONENT_COMBATPISTOL_CLIP_02',
      'COMPONENT_HEAVYPISTOL_CLIP_02',
      'COMPONENT_PISTOL_CLIP_02',
      'COMPONENT_PISTOL_MK2_CLIP_02',
      'COMPONENT_PISTOL50_CLIP_02',
      'COMPONENT_SNSPISTOL_CLIP_02',
      'COMPONENT_SNSPISTOL_MK2_CLIP_02',
      'COMPONENT_VINTAGEPISTOL_CLIP_02',
      'COMPONENT_TECPISTOL_CLIP_02',
    },
  },

  at_clip_extended_smg = {
    name = 'at_clip_extended_smg',
    label = 'Extended SMG Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_extended.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de pistolet-mitrailleur rallongé, droit et fin.',

    slot = 'magazine',
    variants = {
      'COMPONENT_ASSAULTSMG_CLIP_02',
      'COMPONENT_COMBATPDW_CLIP_02',
      'COMPONENT_MACHINEPISTOL_CLIP_02',
      'COMPONENT_MICROSMG_CLIP_02',
      'COMPONENT_MINISMG_CLIP_02',
      'COMPONENT_SMG_CLIP_02',
      'COMPONENT_SMG_MK2_CLIP_02',
    },
  },

  at_clip_extended_shotgun = {
    name = 'at_clip_extended_shotgun',
    label = 'Extended Shotgun Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_extended2.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de fusil rallongé, pour ne pas recharger au mauvais moment.',

    slot = 'magazine',
    variants = {
      'COMPONENT_ASSAULTSHOTGUN_CLIP_02',
      'COMPONENT_HEAVYSHOTGUN_CLIP_02',
    },
  },

  at_clip_extended_rifle = {
    name = 'at_clip_extended_rifle',
    label = 'Extended Rifle Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_extended2.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de fusil d\'assaut rallongé, incurvé.',

    slot = 'magazine',
    variants = {
      'COMPONENT_ADVANCEDRIFLE_CLIP_02',
      'COMPONENT_ASSAULTRIFLE_CLIP_02',
      'COMPONENT_ASSAULTRIFLE_MK2_CLIP_02',
      'COMPONENT_BULLPUPRIFLE_CLIP_02',
      'COMPONENT_BULLPUPRIFLE_MK2_CLIP_02',
      'COMPONENT_CARBINERIFLE_CLIP_02',
      'COMPONENT_CARBINERIFLE_MK2_CLIP_02',
      'COMPONENT_COMPACTRIFLE_CLIP_02',
      'COMPONENT_HEAVYRIFLE_CLIP_02',
      'COMPONENT_MILITARYRIFLE_CLIP_02',
      'COMPONENT_SPECIALCARBINE_CLIP_02',
      'COMPONENT_SPECIALCARBINE_MK2_CLIP_02',
      'COMPONENT_TACTICALRIFLE_CLIP_02',
      'COMPONENT_BATTLERIFLE_CLIP_02',
    },
  },

  at_clip_extended_mg = {
    name = 'at_clip_extended_mg',
    label = 'Extended MG Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_drum.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de mitrailleuse rallongé. Lourd une fois plein.',

    slot = 'magazine',
    variants = {
      'COMPONENT_GUSENBERG_CLIP_02',
      'COMPONENT_MG_CLIP_02',
      'COMPONENT_COMBATMG_CLIP_02',
      'COMPONENT_COMBATMG_MK2_CLIP_02',
    },
  },

  at_clip_extended_sniper = {
    name = 'at_clip_extended_sniper',
    label = 'Extended Sniper Clip',
    type = 'component',

    weight = 280,
    image = 'at_clip_extended2.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un chargeur de fusil de précision rallongé.',

    slot = 'magazine',
    variants = {
      'COMPONENT_HEAVYSNIPER_MK2_CLIP_02',
      'COMPONENT_MARKSMANRIFLE_CLIP_02',
      'COMPONENT_MARKSMANRIFLE_MK2_CLIP_02',
    },
  },

  at_clip_drum_smg = {
    name = 'at_clip_drum_smg',
    label = 'SMG Drum',
    type = 'component',

    weight = 280,
    image = 'at_clip_drum.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un tambour de pistolet-mitrailleur. Encombrant, mais on tire longtemps.',

    slot = 'magazine',
    variants = {
      'COMPONENT_COMBATPDW_CLIP_03',
      'COMPONENT_MACHINEPISTOL_CLIP_03',
      'COMPONENT_SMG_CLIP_03',
    },
  },

  at_clip_drum_shotgun = {
    name = 'at_clip_drum_shotgun',
    label = 'Shotgun Drum',
    type = 'component',

    weight = 280,
    image = 'at_clip_drum.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un tambour de fusil à pompe. Il déséquilibre l\'arme vers l\'avant.',

    slot = 'magazine',
    variants = {
      'COMPONENT_HEAVYSHOTGUN_CLIP_03',
    },
  },

  at_clip_drum_rifle = {
    name = 'at_clip_drum_rifle',
    label = 'Rifle Drum',
    type = 'component',

    weight = 280,
    image = 'at_clip_drum.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un tambour de fusil d\'assaut. Il ne rentre dans aucune poche.',

    slot = 'magazine',
    variants = {
      'COMPONENT_ASSAULTRIFLE_CLIP_03',
      'COMPONENT_COMPACTRIFLE_CLIP_03',
      'COMPONENT_CARBINERIFLE_CLIP_03',
      'COMPONENT_SPECIALCARBINE_CLIP_03',
    },
  },

  at_compensator = {
    name = 'at_compensator',
    label = 'Compensator',
    type = 'component',

    weight = 280,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un compensateur de bouche. Il renvoie les gaz vers le haut.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_PI_COMP',
      'COMPONENT_AT_PI_COMP_02',
      'COMPONENT_AT_PI_COMP_03',
    },
  },

  at_scope_macro = {
    name = 'at_scope_macro',
    label = 'Macro Scope',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lunette à faible grossissement, pour le tir rapproché.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_MACRO',
      'COMPONENT_AT_SCOPE_MACRO_02',
      'COMPONENT_AT_SCOPE_MACRO_MK2',
      'COMPONENT_AT_SCOPE_MACRO_02_MK2',
      'COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2',
    },
  },

  at_scope_small = {
    name = 'at_scope_small',
    label = 'Small Scope',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une petite lunette. Un compromis entre viser et voir.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_SMALL',
      'COMPONENT_AT_SCOPE_SMALL_02',
      'COMPONENT_AT_SCOPE_SMALL_MK2',
      'COMPONENT_AT_SCOPE_SMALL_SMG_MK2',
    },
  },

  at_scope_medium = {
    name = 'at_scope_medium',
    label = 'Medium Scope',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lunette moyenne. Elle couvre la plupart des distances utiles.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_MEDIUM',
      'COMPONENT_AT_SCOPE_MEDIUM_MK2',
    },
  },

  at_scope_large = {
    name = 'at_scope_large',
    label = 'Large Scope',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une grande lunette. Au-delà de cent mètres, elle change tout.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_LARGE_MK2',
    },
  },

  at_scope_advanced = {
    name = 'at_scope_advanced',
    label = 'Advanced Scope',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lunette de précision à réticule gravé et tourelles réglables.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_MAX',
    },
  },

  at_scope_nv = {
    name = 'at_scope_nv',
    label = 'NV Scope',
    type = 'component',

    weight = 420,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lunette à intensification de lumière. Inutilisable en plein jour.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_NV',
    },
  },

  at_scope_thermal = {
    name = 'at_scope_thermal',
    label = 'Thermal Scope',
    type = 'component',

    weight = 420,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une lunette thermique. Elle voit la chaleur, pas les formes.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_SCOPE_THERMAL',
    },
  },

  at_scope_holo = {
    name = 'at_scope_holo',
    label = 'Holographic Sight',
    type = 'component',

    weight = 280,
    image = 'at_scope.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un viseur holographique. Point rouge, les deux yeux ouverts.',

    slot = 'sight',
    variants = {
      'COMPONENT_AT_PI_RAIL',
      'COMPONENT_AT_PI_RAIL_02',
      'COMPONENT_AT_SIGHTS',
      'COMPONENT_AT_SIGHTS_SMG',
    },
  },

  at_muzzle_flat = {
    name = 'at_muzzle_flat',
    label = 'Flat Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche plat. Discret et sans prétention.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_01',
    },
  },

  at_muzzle_tactical = {
    name = 'at_muzzle_tactical',
    label = 'Tactical Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche tactique, à fentes latérales.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_02',
    },
  },

  at_muzzle_fat = {
    name = 'at_muzzle_fat',
    label = 'Fat Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche épais. Il élargit la silhouette du canon.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_03',
    },
  },

  at_muzzle_precision = {
    name = 'at_muzzle_precision',
    label = 'Precision Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche allongé, usiné pour le tir posé.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_04',
    },
  },

  at_muzzle_heavy = {
    name = 'at_muzzle_heavy',
    label = 'Heavy Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche massif. Il encaisse les gros calibres.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_05',
    },
  },

  at_muzzle_slanted = {
    name = 'at_muzzle_slanted',
    label = 'Slanted Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche biseauté. Il pousse le canon vers le bas.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_06',
    },
  },

  at_muzzle_split = {
    name = 'at_muzzle_split',
    label = 'Split Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche fendu en deux. Une signature visuelle avant tout.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_07',
    },
  },

  at_muzzle_squared = {
    name = 'at_muzzle_squared',
    label = 'Squared Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche à section carrée, anguleux.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_08',
    },
  },

  at_muzzle_bell = {
    name = 'at_muzzle_bell',
    label = 'Bell Muzzle',
    type = 'component',

    weight = 80,
    image = 'at_muzzle.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un frein de bouche évasé en pavillon. Le son porte différemment.',

    slot = 'muzzle',
    variants = {
      'COMPONENT_AT_MUZZLE_09',
    },
  },

  at_skin_luxe = {
    name = 'at_skin_luxe',
    label = 'Luxury Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une finition dorée gravée à la main. Elle ne rend pas l\'arme meilleure, seulement plus chère.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_VARMOD_LUXE',
      'COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER',
      'COMPONENT_CARBINERIFLE_VARMOD_LUXE',
      'COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER',
      'COMPONENT_MARKSMANRIFLE_VARMOD_LUXE',
      'COMPONENT_MG_VARMOD_LOWRIDER',
      'COMPONENT_MICROSMG_VARMOD_LUXE',
      'COMPONENT_PISTOL_VARMOD_LUXE',
      'COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER',
      'COMPONENT_SMG_VARMOD_LUXE',
    },
  },

  at_skin_wood = {
    name = 'at_skin_wood',
    label = 'Wood Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des plaquettes en bois verni. Un goût d\'ancien sur une arme moderne.',

    slot = 'skin',
    variants = {
      'COMPONENT_HEAVYPISTOL_VARMOD_LUXE',
      'COMPONENT_SNIPERRIFLE_VARMOD_LUXE',
      'COMPONENT_SNSPISTOL_VARMOD_LOWRIDER',
    },
  },

  at_skin_metal = {
    name = 'at_skin_metal',
    label = 'Metal Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un habillage métal brossé, sans reflet.',

    slot = 'skin',
    variants = {
      'COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE',
      'COMPONENT_APPISTOL_VARMOD_LUXE',
      'COMPONENT_BULLPUPRIFLE_VARMOD_LOW',
      'COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE',
      'COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER',
    },
  },

  at_skin_pearl = {
    name = 'at_skin_pearl',
    label = 'Pearl Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des plaquettes en nacre. Elles jaunissent avec les années.',

    slot = 'skin',
    variants = {
      'COMPONENT_PISTOL50_VARMOD_LUXE',
    },
  },

  at_skin_ballas = {
    name = 'at_skin_ballas',
    label = 'Ballas Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Aux couleurs des Ballas. On ne la sort pas dans n\'importe quel quartier.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_BALLAS',
    },
  },

  at_skin_diamond = {
    name = 'at_skin_diamond',
    label = 'Diamond Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Sertie de pierres qui n\'en sont probablement pas.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_DIAMOND',
    },
  },

  at_skin_dollar = {
    name = 'at_skin_dollar',
    label = 'Dollar Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Couverte de billets gravés. Le message n\'a rien de subtil.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_DOLLAR',
    },
  },

  at_skin_hate = {
    name = 'at_skin_hate',
    label = 'Hate Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un mot de quatre lettres, une lettre par phalange.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_HATE',
    },
  },

  at_skin_king = {
    name = 'at_skin_king',
    label = 'King Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une couronne gravée. Autoproclamée, évidemment.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_KING',
    },
  },

  at_skin_love = {
    name = 'at_skin_love',
    label = 'Love Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Le pendant du kit Hate. La même main, l\'autre poing.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_LOVE',
    },
  },

  at_skin_pimp = {
    name = 'at_skin_pimp',
    label = 'Pimp Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Dorure criarde et velours. Aucune retenue.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_PIMP',
    },
  },

  at_skin_player = {
    name = 'at_skin_player',
    label = 'Player Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une finition qui parle plus fort que celui qui la porte.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_PLAYER',
    },
  },

  at_skin_vagos = {
    name = 'at_skin_vagos',
    label = 'Vagos Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Aux couleurs des Vagos, jaune franc.',

    slot = 'skin',
    variants = {
      'COMPONENT_KNUCKLE_VARMOD_VAGOS',
    },
  },

  at_skin_blagueurs = {
    name = 'at_skin_blagueurs',
    label = 'Blagueurs Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une batte peinte à la main. L\'humour n\'est pas le même des deux côtés.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3',
    },
  },

  at_skin_splatter = {
    name = 'at_skin_splatter',
    label = 'Splatter Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des éclaboussures peintes. Du moins on l\'espère.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_01',
    },
  },

  at_skin_bulletholes = {
    name = 'at_skin_bulletholes',
    label = 'Bullet Holes Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des impacts en trompe-l\'œil. Aucun n\'est réel.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_02',
    },
  },

  at_skin_burgershot = {
    name = 'at_skin_burgershot',
    label = 'Burger Shot Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Aux couleurs de l\'enseigne. Une opération marketing qui a mal vieilli.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_03',
    },
  },

  at_skin_cluckinbell = {
    name = 'at_skin_cluckinbell',
    label = 'Cluckin Bell Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Le poulet de l\'enseigne, imprimé grandeur nature.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_04',
    },
  },

  at_skin_fatalincursion = {
    name = 'at_skin_fatalincursion',
    label = 'Fatal Incursion Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Aux couleurs du jeu vidéo. Une licence sous licence.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_05',
    },
  },

  at_skin_luchalibre = {
    name = 'at_skin_luchalibre',
    label = 'Lucha Libre Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Masques et couleurs de catch mexicain.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_06',
    },
  },

  at_skin_trippy = {
    name = 'at_skin_trippy',
    label = 'Trippy Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des motifs qui donnent mal au crâne à jeun.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_07',
    },
  },

  at_skin_tiedye = {
    name = 'at_skin_tiedye',
    label = 'Tie-Dye Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Teinture nouée, couleurs délavées. Un contresens assumé.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_08',
    },
  },

  at_skin_wall = {
    name = 'at_skin_wall',
    label = 'Wall Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un habillage façon mur taggué, béton compris.',

    slot = 'skin',
    variants = {
      'COMPONENT_BAT_VARMOD_XM3_09',
    },
  },

  at_skin_vip = {
    name = 'at_skin_vip',
    label = 'VIP Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une finition réservée à ceux qui paient l\'entrée.',

    slot = 'skin',
    variants = {
      'COMPONENT_REVOLVER_VARMOD_BOSS',
      'COMPONENT_SWITCHBLADE_VARMOD_VAR1',
    },
  },

  at_skin_bodyguard = {
    name = 'at_skin_bodyguard',
    label = 'Bodyguard Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'La finition sobre de ceux qui accompagnent les précédents.',

    slot = 'skin',
    variants = {
      'COMPONENT_REVOLVER_VARMOD_GOON',
      'COMPONENT_SWITCHBLADE_VARMOD_VAR2',
    },
  },

  at_skin_festive = {
    name = 'at_skin_festive',
    label = 'Festive Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Rouge, blanc, et un grelot quelque part. Strictement saisonnier.',

    slot = 'skin',
    variants = {
      'COMPONENT_RAYPISTOL_VARMOD_XMAS18',
    },
  },

  at_skin_security = {
    name = 'at_skin_security',
    label = 'Security Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un habillage de société de sécurité, matricule compris.',

    slot = 'skin',
    variants = {
      'COMPONENT_APPISTOL_VARMOD_SECURITY',
      'COMPONENT_MICROSMG_VARMOD_SECURITY',
    },
  },

  at_skin_camo = {
    name = 'at_skin_camo',
    label = 'Camo Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un camouflage numérique standard, gris et vert.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO',
      'COMPONENT_CARBINERIFLE_MK2_CAMO',
      'COMPONENT_COMBATMG_MK2_CAMO',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO',
      'COMPONENT_PISTOL_MK2_CAMO',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO',
      'COMPONENT_REVOLVER_MK2_CAMO',
      'COMPONENT_SMG_MK2_CAMO',
      'COMPONENT_SNSPISTOL_MK2_CAMO',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO',
    },
  },

  at_skin_brushstroke = {
    name = 'at_skin_brushstroke',
    label = 'Brushstroke Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un camouflage peint au pinceau, comme au siècle dernier.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_02',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_02',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_02',
      'COMPONENT_COMBATMG_MK2_CAMO_02',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_02',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_02',
      'COMPONENT_PISTOL_MK2_CAMO_02',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_02',
      'COMPONENT_REVOLVER_MK2_CAMO_02',
      'COMPONENT_SMG_MK2_CAMO_02',
      'COMPONENT_SNSPISTOL_MK2_CAMO_02',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_02',
    },
  },

  at_skin_woodland = {
    name = 'at_skin_woodland',
    label = 'Woodland Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un camouflage forestier. Efficace là où il y a des arbres.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_03',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_03',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_03',
      'COMPONENT_COMBATMG_MK2_CAMO_03',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_03',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_03',
      'COMPONENT_PISTOL_MK2_CAMO_03',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_03',
      'COMPONENT_REVOLVER_MK2_CAMO_03',
      'COMPONENT_SMG_MK2_CAMO_03',
      'COMPONENT_SNSPISTOL_MK2_CAMO_03',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_03',
    },
  },

  at_skin_skull = {
    name = 'at_skin_skull',
    label = 'Skull Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des crânes répétés sur toute la longueur. Sans subtilité.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_04',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_04',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_04',
      'COMPONENT_COMBATMG_MK2_CAMO_04',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_04',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_04',
      'COMPONENT_PISTOL_MK2_CAMO_04',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_04',
      'COMPONENT_REVOLVER_MK2_CAMO_04',
      'COMPONENT_SMG_MK2_CAMO_04',
      'COMPONENT_SNSPISTOL_MK2_CAMO_04',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_04',
    },
  },

  at_skin_sessanta = {
    name = 'at_skin_sessanta',
    label = 'Sessanta Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une livrée de course, numéro peint sur le côté.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_05',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_05',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_05',
      'COMPONENT_COMBATMG_MK2_CAMO_05',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_05',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_05',
      'COMPONENT_PISTOL_MK2_CAMO_05',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_05',
      'COMPONENT_REVOLVER_MK2_CAMO_05',
      'COMPONENT_SMG_MK2_CAMO_05',
      'COMPONENT_SNSPISTOL_MK2_CAMO_05',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_05',
    },
  },

  at_skin_perseus = {
    name = 'at_skin_perseus',
    label = 'Perseus Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un motif de constellation sur fond sombre.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_06',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_06',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_06',
      'COMPONENT_COMBATMG_MK2_CAMO_06',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_06',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_06',
      'COMPONENT_PISTOL_MK2_CAMO_06',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_06',
      'COMPONENT_REVOLVER_MK2_CAMO_06',
      'COMPONENT_SMG_MK2_CAMO_06',
      'COMPONENT_SNSPISTOL_MK2_CAMO_06',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_06',
    },
  },

  at_skin_leopard = {
    name = 'at_skin_leopard',
    label = 'Leopard Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une fourrure imprimée. Personne n\'est dupe.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_07',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_07',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_07',
      'COMPONENT_COMBATMG_MK2_CAMO_07',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_07',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_07',
      'COMPONENT_PISTOL_MK2_CAMO_07',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_07',
      'COMPONENT_REVOLVER_MK2_CAMO_07',
      'COMPONENT_SMG_MK2_CAMO_07',
      'COMPONENT_SNSPISTOL_MK2_CAMO_07',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_07',
    },
  },

  at_skin_zebra = {
    name = 'at_skin_zebra',
    label = 'Zebra Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des rayures noires et blanches. Voyant, et c\'est le but.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_08',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_08',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_08',
      'COMPONENT_COMBATMG_MK2_CAMO_08',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_08',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_08',
      'COMPONENT_PISTOL_MK2_CAMO_08',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_08',
      'COMPONENT_REVOLVER_MK2_CAMO_08',
      'COMPONENT_SMG_MK2_CAMO_08',
      'COMPONENT_SNSPISTOL_MK2_CAMO_08',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_08',
    },
  },

  at_skin_geometric = {
    name = 'at_skin_geometric',
    label = 'Geometric Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des facettes anguleuses qui cassent la silhouette.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_09',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_09',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_09',
      'COMPONENT_COMBATMG_MK2_CAMO_09',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_09',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_09',
      'COMPONENT_PISTOL_MK2_CAMO_09',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_09',
      'COMPONENT_REVOLVER_MK2_CAMO_09',
      'COMPONENT_SMG_MK2_CAMO_09',
      'COMPONENT_SNSPISTOL_MK2_CAMO_09',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_09',
    },
  },

  at_skin_boom = {
    name = 'at_skin_boom',
    label = 'Boom Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Des onomatopées de bande dessinée. Le contraste est volontaire.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_10',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_10',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_10',
      'COMPONENT_COMBATMG_MK2_CAMO_10',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_10',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_10',
      'COMPONENT_PISTOL_MK2_CAMO_10',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_10',
      'COMPONENT_REVOLVER_MK2_CAMO_10',
      'COMPONENT_SMG_MK2_CAMO_10',
      'COMPONENT_SNSPISTOL_MK2_CAMO_10',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_10',
    },
  },

  at_skin_patriotic = {
    name = 'at_skin_patriotic',
    label = 'Patriotic Weapon Kit',
    type = 'component',

    weight = 50,
    image = 'at_skin.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Bannière étoilée sur toute la carcasse. Sortie pour le 4 juillet.',

    slot = 'skin',
    variants = {
      'COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01',
      'COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01',
      'COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01',
      'COMPONENT_COMBATMG_MK2_CAMO_IND_01',
      'COMPONENT_HEAVYSNIPER_MK2_CAMO_IND_01',
      'COMPONENT_MARKSMANRIFLE_MK2_CAMO_IND_01',
      'COMPONENT_PISTOL_MK2_CAMO_IND_01',
      'COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01',
      'COMPONENT_REVOLVER_MK2_CAMO_IND_01',
      'COMPONENT_SMG_MK2_CAMO_IND_01',
      'COMPONENT_SNSPISTOL_MK2_CAMO_IND_01',
      'COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01',
    },
  },
}
