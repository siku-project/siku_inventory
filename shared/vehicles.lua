--- Vehicle storage.
---
--- What a vehicle carries, and where. Two compartments, both real places a
--- character has to be to reach them: the glovebox from a front seat, the boot
--- from outside, standing at whichever end of the car it happens to be.
---
--- A vehicle is identified by its plate. Not by its model, not by the entity
--- it happens to be right now — a car driven away and parked again is the same
--- car, and what was in the boot is still in the boot.
---
--- Sizes by class
---   Every class below names what its two compartments hold. `slots` is how
---   many stacks fit, `maxWeight` how many grams. These are the numbers to
---   tune for a server: they are written against a character who carries 35 kg,
---   so a glovebox holding a few kilos and a boot holding a few dozen keeps
---   the difference between what you carry and what you drive meaningful.
---
---   A class that names nothing has no compartment of that sort. A bicycle
---   carries nothing; a boat has no boot.
---
--- Exceptions by model
---   Most cars follow their class. The ones that do not are named in
---   `Models`, by model name rather than by hash — the hash is worked out on
---   load, and a name is something a person can read and correct.
---
---   trunk    false to say the model has no boot at all, `'front'` when the
---            boot is under the bonnet, or a table to give it its own size.
---   glovebox false when there is none, or a table for its own size.
Vehicles = {
  --- What each vehicle class holds. The names are this resource's own; the
  --- game numbers them, and the mapping lives beside this file.
  Classes = {
    compact = {
      trunk = { slots = 12, maxWeight = 40000 },
      glovebox = { slots = 4, maxWeight = 4000 },
    },

    sedan = {
      trunk = { slots = 20, maxWeight = 70000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    suv = {
      trunk = { slots = 28, maxWeight = 110000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    coupe = {
      trunk = { slots = 16, maxWeight = 55000 },
      glovebox = { slots = 4, maxWeight = 4000 },
    },

    muscle = {
      trunk = { slots = 20, maxWeight = 75000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    sportsclassic = {
      trunk = { slots = 14, maxWeight = 45000 },
      glovebox = { slots = 4, maxWeight = 4000 },
    },

    sports = {
      trunk = { slots = 14, maxWeight = 45000 },
      glovebox = { slots = 4, maxWeight = 4000 },
    },

    super = {
      trunk = { slots = 10, maxWeight = 30000 },
      glovebox = { slots = 3, maxWeight = 3000 },
    },

    motorcycle = {
      trunk = { slots = 3, maxWeight = 8000 },
      glovebox = false,
    },

    offroad = {
      trunk = { slots = 28, maxWeight = 120000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    industrial = {
      trunk = { slots = 34, maxWeight = 200000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    utility = {
      trunk = { slots = 30, maxWeight = 150000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    van = {
      trunk = { slots = 40, maxWeight = 250000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    --- A bicycle has nowhere to put anything.
    cycle = false,

    boat = {
      trunk = false,
      glovebox = { slots = 10, maxWeight = 30000 },
    },

    helicopter = {
      trunk = false,
      glovebox = { slots = 12, maxWeight = 40000 },
    },

    plane = {
      trunk = false,
      glovebox = { slots = 16, maxWeight = 60000 },
    },

    service = {
      trunk = { slots = 24, maxWeight = 100000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    emergency = {
      trunk = { slots = 24, maxWeight = 100000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    military = {
      trunk = { slots = 30, maxWeight = 180000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    commercial = {
      trunk = { slots = 40, maxWeight = 300000 },
      glovebox = { slots = 5, maxWeight = 5000 },
    },

    --- A train is scenery with wheels.
    train = false,
  },

  --- The models that do not follow their class.
  Models = {
    --- Engine at the back, so the boot is under the bonnet.
    jester = { trunk = 'front' },
    adder = { trunk = 'front' },
    reaper = { trunk = 'front' },
    torero = { trunk = 'front' },
    italigtb = { trunk = 'front' },
    italigtb2 = { trunk = 'front' },
    vacca = { trunk = 'front' },

    --- Nowhere to put anything behind the seats.
    osiris = { trunk = false },
    pfister811 = { trunk = false },
    penetrator = { trunk = false },
    autarch = { trunk = false },
    bullet = { trunk = false },
    cheetah = { trunk = false },
    cyclone = { trunk = false },
    voltic = { trunk = false },
    entityxf = { trunk = false },
    t20 = { trunk = false },
    taipan = { trunk = false },
    tezeract = { trunk = false },
    turismor = { trunk = false },
    fmj = { trunk = false },
    infernus = { trunk = false },
    nero2 = { trunk = false },
    vagner = { trunk = false },
    visione = { trunk = false },
    prototipo = { trunk = false },
    zentorno = { trunk = false },

    --- An open frame with a roll cage and nothing else.
    trophytruck = { trunk = false, glovebox = false },
    trophytruck2 = { trunk = false, glovebox = false },

    --- A boot that exists but barely.
    xa21 = { trunk = { slots = 6, maxWeight = 12000 } },
  },
}
