--- Ammunition definitions.
---
--- One entry per kind of round. The table key is what a weapon names in its
--- `ammoType`, so a weapon and its ammunition are tied together by that name
--- and nothing else has to be kept in step.
---
--- Rounds are ordinary items — nothing about ammunition needs a mechanism of
--- its own. A box of 9mm stacks, weighs, persists and merges exactly like a
--- stack of bandages, and says so in the same fields.
---
--- Weight is given for a single round, which is the whole point of weighing
--- them one at a time: two hundred rifle rounds cost eight hundred grams and
--- two rockets cost a kilo, and the difference is felt when carrying them.
---
--- Using a round is loading it. The action does not spend anything on its
--- own: it opens the choice of which carried weapon to fill, and the rounds
--- only leave the bag once one is picked. That is why every entry below is
--- usable and none of them closes the screen.
---
--- Required on every round
---   name         string, the business name of the round
---   label        string, the human name, usually its calibre
---   type         string, 'item'
---   weight       number, grams for one round, zero or more
---   image        string, file name inside web/src/assets/images/items
---   stackable    boolean, whether two may share a slot
---   unique       boolean, whether every instance is tracked on its own
---   usable       boolean, whether the use action is offered
---   closeOnUse   boolean, whether the interface closes once a use is accepted
---   description  string, one or two sentences
---
--- What is deliberately not written here
---   That an entry of this file is ammunition. Every round declared here is
---   one, and the mark that says so is attached on expansion rather than
---   repeated twenty-two times.
Ammo = {
  ['ammo-22'] = {
    name = 'ammo-22',
    label = '.22 Long Rifle',
    type = 'item',

    weight = 3,
    image = 'ammo-22.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une petite cartouche annulaire. Peu de bruit, peu de dégâts.',
  },

  ['ammo-38'] = {
    name = 'ammo-38',
    label = '.38 LC',
    type = 'item',

    weight = 15,
    image = 'ammo-38.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche d\'un autre âge, encore fabriquée pour les revolvers anciens.',
  },

  ['ammo-44'] = {
    name = 'ammo-44',
    label = '.44 Magnum',
    type = 'item',

    weight = 16,
    image = 'ammo-44.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche de revolver massive. Le recul se sent dans le poignet.',
  },

  ['ammo-45'] = {
    name = 'ammo-45',
    label = '.45 ACP',
    type = 'item',

    weight = 15,
    image = 'ammo-45.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche large et lente. Elle s\'arrête dans ce qu\'elle touche.',
  },

  ['ammo-50'] = {
    name = 'ammo-50',
    label = '.50 AE',
    type = 'item',

    weight = 45,
    image = 'ammo-50.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche de pistolet démesurée. Sept coups pèsent un chargeur entier de 9mm.',
  },

  ['ammo-9'] = {
    name = 'ammo-9',
    label = '9mm',
    type = 'item',

    weight = 7,
    image = 'ammo-9.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'La cartouche la plus répandue. On en trouve partout, à tous les prix.',
  },

  ['ammo-shotgun'] = {
    name = 'ammo-shotgun',
    label = '12 Gauge',
    type = 'item',

    weight = 38,
    image = 'ammo-shotgun.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche à chevrotine. Elle se recharge une par une.',
  },

  ['ammo-rifle'] = {
    name = 'ammo-rifle',
    label = '5.56x45',
    type = 'item',

    weight = 4,
    image = 'ammo-rifle.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche intermédiaire légère. On en porte trois cents sans y penser.',
  },

  ['ammo-rifle2'] = {
    name = 'ammo-rifle2',
    label = '7.62x39',
    type = 'item',

    weight = 8,
    image = 'ammo-rifle2.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche à âme d\'acier. Deux fois plus lourde que la 5.56, et ça se sent.',
  },

  ['ammo-sniper'] = {
    name = 'ammo-sniper',
    label = '7.62x51',
    type = 'item',

    weight = 9,
    image = 'ammo-sniper.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche de plein calibre, appairée pour le tir de précision.',
  },

  ['ammo-heavysniper'] = {
    name = 'ammo-heavysniper',
    label = '.50 BMG',
    type = 'item',

    weight = 51,
    image = 'ammo-heavysniper.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche anti-matériel. Dix coups pèsent un demi-kilo.',
  },

  ['ammo-musket'] = {
    name = 'ammo-musket',
    label = '.50 Ball',
    type = 'item',

    weight = 38,
    image = 'ammo-musket.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une balle ronde en plomb, à charger avec sa poudre.',
  },

  ['ammo-mg'] = {
    name = 'ammo-mg',
    label = '7.62x51 Link',
    type = 'item',

    weight = 10,
    image = 'ammo-mg.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Des cartouches maillées en bande. Elles ne se chargent pas autrement.',
  },

  ['ammo-flare'] = {
    name = 'ammo-flare',
    label = 'Flare round',
    type = 'item',

    weight = 38,
    image = 'ammo-flare.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche éclairante. Elle monte, elle brûle, elle retombe.',
  },

  ['ammo-grenade'] = {
    name = 'ammo-grenade',
    label = '40mm Explosive',
    type = 'item',

    weight = 400,
    image = 'ammo-grenade.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une grenade de 40mm à percussion. Elle s\'arme à quelques mètres du tube.',
  },

  ['ammo-rocket'] = {
    name = 'ammo-rocket',
    label = 'Rocket',
    type = 'item',

    weight = 500,
    image = 'ammo-rocket.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une roquette à charge creuse. Un demi-kilo par tir.',
  },

  ['ammo-railgun'] = {
    name = 'ammo-railgun',
    label = 'Railgun charge',
    type = 'item',

    weight = 150,
    image = 'ammo-railgun.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cellule de charge et son projectile de tungstène.',
  },

  ['ammo-emp'] = {
    name = 'ammo-emp',
    label = 'EMP round',
    type = 'item',

    weight = 400,
    image = 'ammo-emp.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une charge à impulsion. Elle ne laisse aucune trace, seulement du silence.',
  },

  ['ammo-firework'] = {
    name = 'ammo-firework',
    label = 'Firework',
    type = 'item',

    weight = 200,
    image = 'ammo-firework.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Un artifice calibré. L\'étiquette déconseille de le tirer à l\'horizontale.',
  },

  ['ammo-laser'] = {
    name = 'ammo-laser',
    label = 'Laser charge',
    type = 'item',

    weight = 1,
    image = 'ammo-laser.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cellule d\'énergie. Elle ne pèse presque rien et ne se recharge pas.',
  },

  ['ammo-stungun'] = {
    name = 'ammo-stungun',
    label = 'Taser cartridge',
    type = 'item',

    weight = 40,
    image = 'ammo-stungun.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une cartouche à deux fils, propulsés à l\'air comprimé. Un seul usage.',
  },

  ['ammo-snowball'] = {
    name = 'ammo-snowball',
    label = 'Snowball',
    type = 'item',

    weight = 150,
    image = 'ammo-snowball.png',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = false,

    description = 'Une boule de neige tassée, prête à être lancée.',
  },
}
