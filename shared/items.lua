--- Item definitions.
---
--- This file is the source of truth for what an item *is*. Every entry
--- describes a kind; what a player carries is an instance of one of these,
--- with its own quantity, its own metadata and, when the kind asks for it,
--- its own freshness or remaining uses.
---
--- Nothing here is implicit. A structural property that is missing is a
--- configuration error, reported by name at startup rather than quietly
--- guessed: the day a boolean is forgotten, the resource says so instead of
--- deciding for you.
---
--- Identity
---   The table key is the internal identifier. It is what a stack stores,
---   what the database writes and what another resource passes to the
---   exports. It never changes once items exist in the world.
---
---   `name` is the business name of the object, which is not always the same
---   thing: a weapon is identified in game by `WEAPON_PISTOL` while the
---   inventory knows it as `pistol`.
---
--- Required on every item
---   name         string, the business name of the object
---   label        string, the human name, shown everywhere in the interface
---   type         string, 'item'
---   weight       number, grams for a single unit, zero or more
---   image        string, file name inside web/src/assets/images/items
---   stackable    boolean, whether two units may ever share a slot
---   unique       boolean, whether every instance is tracked on its own
---   usable       boolean, whether the use action is offered
---   closeOnUse   boolean, whether the interface closes once a use is accepted
---   description  string, one or two sentences
---
--- Stacking and identity are two different questions
---   `stackable` says whether two units may share a slot. `unique` says
---   whether an instance is an object of its own, with an identifier, a serial
---   number and a history that follow it everywhere.
---
---   Both may be false: a radio does not stack and is still just a radio. What
---   cannot happen is both being true — an object tracked on its own can never
---   share a slot with another — and that is refused at startup.
---
--- Optional
---   maxStack     number, cap on a single stack. Absent or false means the
---                only limits are weight and slots. Only meaningful when
---                stackable is true.
---   metadata     table, `display` lists the properties that may leave the
---                server, in the order they should be read. Anything not
---                listed here stays on the server whatever it holds.
---   decay        number 1..10 or false. How fast the item spoils, read
---                against InventoryConfig.decay. Low is slow, high is fast.
---   removeOnDecay boolean, required when decay is set: whether a spoiled
---                instance disappears or stays as unusable.
---   uses         number, how many times a fresh instance may be used before
---                it is spent. Not a quantity: one lockpick with three uses
---                left is a single item, not three lockpicks.
---   useTime      number, milliseconds the character spends using it. Absent
---                means instant. While it runs the screen is closed and a
---                progress bar shows; leaving it unfinished uses nothing. A
---                weapon never declares one — it is drawn, not used.
--- Weapons, ammunition and components
---   All three are items too, and all three end up in this table — but none
---   of them is written here. Weapons live in shared/weapons.lua, rounds in
---   shared/ammo.lua and attachments in shared/components.lua, and all three
---   are expanded into this table on load.
---
---   A weapon is written out in full over there, field for field, exactly as
---   an item is written here. Rounds and attachments keep a shorter shape of
---   their own.
Items = {
  water = {
    name = 'water',
    label = 'Bouteille d\'eau',
    type = 'item',

    weight = 10,
    image = 'water.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'De l\'eau plate, en bouteille de 50 cl.',

    decay = 1,
    removeOnDecay = false,

    useTime = 2000,
    status = { thirst = 25 },
    server = { export = 'siku_status.Consume' },
  },

  bread = {
    name = 'bread',
    label = 'Pain',
    type = 'item',

    weight = 150,
    image = 'bread.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Une baguette encore tiède.',

    decay = 6,
    removeOnDecay = true,

    useTime = 2500,
    status = { hunger = 15 },
    server = { export = 'siku_status.Consume' },
  },

  burger = {
    name = 'burger',
    label = 'Burger',
    type = 'item',

    weight = 220,
    image = 'burger.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Double steak, cheddar fondu, pain brioché.',

    decay = 6,
    removeOnDecay = true,

    useTime = 3000,
    status = { hunger = 35 },
    server = { export = 'siku_status.Consume' },
  },

  sandwich = {
    name = 'sandwich',
    label = 'Sandwich',
    type = 'item',

    weight = 180,
    image = 'sandwich.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Jambon, beurre, cornichons — un classique.',

    decay = 6,
    removeOnDecay = true,

    useTime = 2500,
    status = { hunger = 25 },
    server = { export = 'siku_status.Consume' },
  },

  chocolate = {
    name = 'chocolate',
    label = 'Barre chocolatée',
    type = 'item',

    weight = 80,
    image = 'chocolate.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Du sucre, du cacao, du réconfort.',

    useTime = 1500,
    status = { hunger = 10 },
    server = { export = 'siku_status.Consume' },
  },

  donut = {
    name = 'donut',
    label = 'Donut',
    type = 'item',

    weight = 90,
    image = 'donut.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Glaçage rose, saupoudré de vermicelles.',

    decay = 4,
    removeOnDecay = true,

    useTime = 2000,
    status = { hunger = 12 },
    server = { export = 'siku_status.Consume' },
  },

  taco = {
    name = 'taco',
    label = 'Taco',
    type = 'item',

    weight = 150,
    image = 'taco.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Bœuf épicé, salsa maison, tortilla croustillante.',

    decay = 6,
    removeOnDecay = true,

    useTime = 2500,
    status = { hunger = 22, thirst = -5 },
    server = { export = 'siku_status.Consume' },
  },

  hotdog = {
    name = 'hotdog',
    label = 'Hot-dog',
    type = 'item',

    weight = 160,
    image = 'hotdog.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Saucisse grillée, moutarde, oignons frits.',

    decay = 6,
    removeOnDecay = true,

    useTime = 2500,
    status = { hunger = 20 },
    server = { export = 'siku_status.Consume' },
  },

  apple = {
    name = 'apple',
    label = 'Pomme',
    type = 'item',

    weight = 120,
    image = 'apple.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Croquante, à peine acidulée.',

    decay = 3,
    removeOnDecay = true,

    useTime = 2000,
    status = { hunger = 12, thirst = 4 },
    server = { export = 'siku_status.Consume' },
  },

  croissant = {
    name = 'croissant',
    label = 'Croissant',
    type = 'item',

    weight = 70,
    image = 'croissant.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Pur beurre, encore feuilleté du matin.',

    decay = 5,
    removeOnDecay = true,

    useTime = 2000,
    status = { hunger = 14 },
    server = { export = 'siku_status.Consume' },
  },

  chips = {
    name = 'chips',
    label = 'Paquet de chips',
    type = 'item',

    weight = 120,
    image = 'chips.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Salées comme il faut — prévoir de quoi boire.',

    useTime = 2500,
    status = { hunger = 10, thirst = -8 },
    server = { export = 'siku_status.Consume' },
  },

  pizza_slice = {
    name = 'pizza_slice',
    label = 'Part de pizza',
    type = 'item',

    weight = 130,
    image = 'pizza_slice.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Une part encore chaude, fromage filant.',

    decay = 6,
    removeOnDecay = true,

    useTime = 2500,
    status = { hunger = 28 },
    server = { export = 'siku_status.Consume' },
  },

  cola = {
    name = 'cola',
    label = 'Canette de cola',
    type = 'item',

    weight = 330,
    image = 'cola.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Bien fraîche, bien sucrée.',

    useTime = 2000,
    status = { thirst = 20, hunger = 3 },
    server = { export = 'siku_status.Consume' },
  },

  orange_juice = {
    name = 'orange_juice',
    label = 'Jus d\'orange',
    type = 'item',

    weight = 330,
    image = 'orange_juice.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Pressé le matin même.',

    decay = 3,
    removeOnDecay = false,

    useTime = 2000,
    status = { thirst = 22, hunger = 4 },
    server = { export = 'siku_status.Consume' },
  },

  coffee = {
    name = 'coffee',
    label = 'Café',
    type = 'item',

    weight = 250,
    image = 'coffee.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Un gobelet brûlant, serré.',

    useTime = 2000,
    status = { thirst = 10 },
    server = { export = 'siku_status.Consume' },
  },

  milk = {
    name = 'milk',
    label = 'Brique de lait',
    type = 'item',

    weight = 500,
    image = 'milk.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Demi-écrémé, à garder au frais.',

    decay = 4,
    removeOnDecay = false,

    useTime = 2000,
    status = { thirst = 18, hunger = 6 },
    server = { export = 'siku_status.Consume' },
  },

  energy_drink = {
    name = 'energy_drink',
    label = 'Boisson énergisante',
    type = 'item',

    weight = 250,
    image = 'energy_drink.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Taurine, caféine et mauvaises idées.',

    useTime = 2000,
    status = { thirst = 15 },
    server = { export = 'siku_status.Consume' },
  },

  lemonade = {
    name = 'lemonade',
    label = 'Limonade',
    type = 'item',

    weight = 330,
    image = 'lemonade.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Citron pressé, eau pétillante, un peu de sucre.',

    useTime = 2000,
    status = { thirst = 20 },
    server = { export = 'siku_status.Consume' },
  },

  iced_tea = {
    name = 'iced_tea',
    label = 'Thé glacé',
    type = 'item',

    weight = 330,
    image = 'iced_tea.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Pêche, servi très frais.',

    useTime = 2000,
    status = { thirst = 20 },
    server = { export = 'siku_status.Consume' },
  },

  milkshake = {
    name = 'milkshake',
    label = 'Milkshake',
    type = 'item',

    weight = 400,
    image = 'milkshake.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Vanille onctueuse, chantilly en prime.',

    decay = 7,
    removeOnDecay = true,

    useTime = 2500,
    status = { thirst = 18, hunger = 14 },
    server = { export = 'siku_status.Consume' },
  },

  sparkling_water = {
    name = 'sparkling_water',
    label = 'Eau pétillante',
    type = 'item',

    weight = 500,
    image = 'sparkling_water.svg',

    stackable = true,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Fines bulles, sans sucre.',

    useTime = 2000,
    status = { thirst = 24 },
    server = { export = 'siku_status.Consume' },
  },

  bandage = {
    name = 'bandage',
    label = 'Bandage',
    type = 'item',

    weight = 50,
    image = 'bandage.svg',

    stackable = true,
    maxStack = 20,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'De quoi arrêter un saignement, pas de quoi soigner une balle.',

    useTime = 2500,
  },

  phone = {
    name = 'phone',
    label = 'Téléphone',
    type = 'item',

    weight = 200,
    image = 'phone.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un smartphone verrouillé par un code à quatre chiffres.',

    metadata = {
      display = {
        { key = 'number', label = 'item.meta.phoneNumber' },
      },
    },
  },

  bank_card = {
    name = 'bank_card',
    label = 'Carte bancaire',
    type = 'item',

    weight = 5,
    image = 'bank_card.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Une carte nominative. Elle appartient à son titulaire, pas à celui qui la tient.',

    metadata = {
      display = {
        { key = 'ownerName', label = 'item.meta.owner' },
        { key = 'cardNumber', label = 'item.meta.cardNumber' },
        { key = 'expiresAt', label = 'item.meta.expiresAt' },
      },
    },
  },

  ore = {
    name = 'ore',
    label = 'Minerai',
    type = 'item',

    weight = 800,
    image = 'ore.png',

    stackable = false,
    unique = true,
    usable = false,
    closeOnUse = false,

    description = 'Un morceau de roche brute. Sa pureté varie d\'un fragment à l\'autre.',

    metadata = {
      display = {
        { key = 'purity', label = 'item.meta.purity', format = 'percent' },
        { key = 'origin', label = 'item.meta.origin' },
      },
    },
  },

  lockpick = {
    name = 'lockpick',
    label = 'Crochet',
    type = 'item',

    weight = 30,
    image = 'lockpick.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = false,

    description = 'Une tige de métal tordue. Elle ne survit pas à beaucoup de serrures.',

    uses = 5,
    useTime = 4000,
  },

  radio = {
    name = 'radio',
    label = 'Radio',
    type = 'item',

    weight = 450,
    image = 'radio.png',

    stackable = false,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Un émetteur-récepteur portatif.',
  },

  cash = {
    name = 'cash',
    label = 'Espèces',
    type = 'item',

    weight = 1,
    image = 'cash.png',

    stackable = true,
    unique = false,
    usable = false,
    closeOnUse = false,

    description = 'Des billets usés.',
  },

  --- The game hands these out as weapons, and this resource does not.
  ---
  --- A flashlight is a torch and a jerrycan is a container; neither is
  --- something a character draws on somebody. They are declared here as plain
  --- items, and `name` still carries the name the game knows them by, so the
  --- client can hand over the right object when one is used.
  ---
  --- The game counts what is left in a can as ammunition. It is not
  --- ammunition, so it is not called that: the instance carries how much is
  --- left in it, under a name that says so.
  flashlight = {
    name = 'WEAPON_FLASHLIGHT',
    label = 'Lampe torche',
    type = 'item',

    weight = 400,
    image = 'flashlight.png',

    stackable = false,
    unique = false,
    usable = true,
    closeOnUse = true,

    description = 'Une lampe de poche robuste. Elle éclaire loin et se voit de loin.',
  },

  --- Twenty litres of petrol weigh about fifteen kilos, can included.
  petrolcan = {
    name = 'WEAPON_PETROLCAN',
    label = 'Jerrican d\'essence',
    type = 'item',

    weight = 15000,
    image = 'petrolcan.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Vingt litres d\'essence. Le bouchon ferme mal.',

    metadata = {
      display = {
        { key = 'content', label = 'item.meta.content', format = 'percent' },
      },
    },
  },

  hazardcan = {
    name = 'WEAPON_HAZARDCAN',
    label = 'Bidon de produit',
    type = 'item',

    weight = 16000,
    image = 'hazardcan.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'Un bidon marqué de pictogrammes que personne ne lit.',

    metadata = {
      display = {
        { key = 'content', label = 'item.meta.content', format = 'percent' },
      },
    },
  },

  fertilizercan = {
    name = 'WEAPON_FERTILIZERCAN',
    label = 'Bidon d\'engrais',
    type = 'item',

    weight = 16000,
    image = 'fertilizercan.png',

    stackable = false,
    unique = true,
    usable = true,
    closeOnUse = true,

    description = 'De l\'engrais liquide, concentré.',

    metadata = {
      display = {
        { key = 'content', label = 'item.meta.content', format = 'percent' },
      },
    },
  },
}
