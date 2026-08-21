import { MOCK_LIMITS } from '@/mock/server'
import type {
  CharacterIdentity,
  GroundEntry,
  ItemStack,
  NearbyPlayer,
  PlayerInventory,
} from '@/types/inventory'

const stack = (
  slot: number,
  item: string,
  count: number,
  weight: number,
  extra?: Partial<ItemStack>,
): ItemStack => ({ slot, item, count, weight: weight * count, ...extra })

export const MOCK_IDENTITY: CharacterIdentity = {
  firstName: 'Elena',
  lastName: 'Vasseur',
}

export const MOCK_PLAYERS: NearbyPlayer[] = [
  { id: 12, name: 'Marcus Delacroix', distance: 1.2 },
  { id: 27, name: 'Naomi Okafor', distance: 2.4 },
  { id: 41, name: 'Tom Rivera', distance: 2.9 },
]

/**
 * The everyday state: a partly filled grid, a hotbar already holding stacks,
 * items with shipped artwork next to items without, and unique instances
 * carrying the metadata the inspect panel reads.
 */
const createMockInventory = (): PlayerInventory => ({
  id: 1,
  ownerType: 'character',
  slots: MOCK_LIMITS.SLOTS,
  maxWeight: MOCK_LIMITS.MAX_WEIGHT,
  weight: 0,
  hotbar: {
    '1': stack(1001, 'bandage', 6, 50),
    '2': stack(1002, 'water', 4, 10, { freshness: 0.55 }),
    '4': stack(1004, 'bread', 1, 150, { freshness: 0.04 }),
  },
  stacks: {
    '1': stack(1, 'water', 12, 10, { freshness: 0.82 }),
    '2': stack(2, 'bread', 3, 150, { freshness: 0.18 }),
    '3': stack(3, 'bandage', 8, 50),
    '5': stack(5, 'lockpick', 1, 30, { uid: 'mock-pick-1', uses: 3, maxUses: 5 }),
    '7': stack(7, 'phone', 1, 200, {
      uid: 'mock-phone-1',
      metadata: { number: '555-0142' },
    }),
    '8': stack(8, 'bank_card', 1, 5, {
      uid: 'mock-card-1',
      metadata: {
        ownerName: 'Elena Vasseur',
        cardNumber: '4977 •••• •••• 2318',
        expiresAt: '04/29',
      },
    }),
    '11': stack(11, 'ore', 1, 800, {
      uid: 'mock-ore-1',
      metadata: { purity: 42, origin: 'Carrière de Sandy Shores' },
    }),
    '12': stack(12, 'ore', 1, 800, {
      uid: 'mock-ore-2',
      metadata: { purity: 87, origin: 'Mine de Paleto' },
    }),
    '14': stack(14, 'cash', 2450, 1, { metadata: { amount: 2450 } }),
    '16': stack(16, 'radio', 1, 450),
    '18': stack(18, 'at_suppressor_light', 1, 280, { uid: 'mock-supp-1' }),
    '19': stack(19, 'at_flashlight', 1, 120, { uid: 'mock-flsh-1' }),
    '20': stack(20, 'at_clip_extended_pistol', 1, 280, { uid: 'mock-clip-1' }),
    '17': stack(17, 'pistol', 1, 1100, {
      uid: 'mock-pistol-1',
      metadata: { serial: 'SK-4471-B', ammo: 8 },
    }),

    /* A second weapon of another calibre, so the loading dialog has something
       to leave out, and rounds for both so it has something to put in. */
    '21': stack(21, 'carbinerifle', 1, 3600, {
      uid: 'mock-carbine-1',
      metadata: { serial: 'SK-8820-C', ammo: 30 },
    }),
    '22': stack(22, 'ammo-9', 40, 280),
    '23': stack(23, 'ammo-rifle', 60, 240),
  },
})

const createMockGround = (): GroundEntry[] => [
  { dropId: 1, slot: 1, item: 'water', count: 4, weight: 40, freshness: 0.6 },
  { dropId: 2, slot: 1, item: 'bandage', count: 5, weight: 250 },
  {
    dropId: 3,
    slot: 1,
    item: 'ore',
    count: 1,
    weight: 800,
    uid: 'mock-ore-3',
    metadata: { purity: 12, origin: 'Rivière de Grapeseed' },
  },
]

const GROUND_NAMES = ['bread', 'water', 'lockpick', 'radio', 'bandage', 'cash'] as const

/** Long enough that the ground grid has to scroll, which is the point of it. */
const GROUND_SPREAD = Array.from(
  { length: 26 },
  (_, index) => GROUND_NAMES[index % GROUND_NAMES.length] as string,
)

/**
 * Alternative starting points, reachable from the boilerplate so every state
 * can be looked at without hand-editing the store.
 */
export const MOCK_SCENARIOS = {
  filled: () => ({ inventory: createMockInventory(), ground: createMockGround() }),

  empty: () => ({
    inventory: { ...createMockInventory(), hotbar: {}, stacks: {} },
    ground: [] as GroundEntry[],
  }),

  /** Carried grid saturated: this is what refuses a hotbar eviction. */
  full: () => {
    const inventory = createMockInventory()
    inventory.stacks = {}

    for (let slot = 1; slot <= inventory.slots; slot += 1) {
      inventory.stacks[String(slot)] = stack(slot, 'ore', 1, 800, {
        uid: `mock-full-${slot}`,
        metadata: { purity: 10 + slot, origin: 'Carrière de Sandy Shores' },
      })
    }

    return { inventory, ground: createMockGround() }
  },

  /** Enough on the floor to exercise the ground grid and its scroll. */
  scattered: () => ({
    inventory: createMockInventory(),
    ground: GROUND_SPREAD.map((item, index) => ({
      dropId: index + 1,
      slot: 1,
      item,
      count: 1 + (index % 4),
      weight: 0,
    })),
  }),

  /** Nothing within reach, so the ground keeps its size on an empty state. */
  bare: () => ({ inventory: createMockInventory(), ground: [] as GroundEntry[] }),

  /**
   * Everything the ground stacking rules have to answer for: a compatible
   * stack to merge into, one already at its cap, and two instances whose
   * metadata make them different objects that must never merge.
   */
  stacking: () => {
    const inventory = createMockInventory()

    inventory.stacks = {
      '1': stack(1, 'water', 6, 10, { freshness: 0.9 }),
      '2': stack(2, 'bandage', 8, 50),
      '3': stack(3, 'bank_card', 1, 5, {
        uid: 'mock-card-2',
        metadata: { ownerName: 'Marcus Delacroix', cardNumber: '5188 •••• •••• 0043' },
      }),
    }

    return {
      inventory,
      ground: [
        { dropId: 1, slot: 1, item: 'water', count: 4, weight: 40, freshness: 0.45 },
        { dropId: 2, slot: 1, item: 'bandage', count: 20, weight: 1000 },
        {
          dropId: 3,
          slot: 1,
          item: 'bank_card',
          count: 1,
          weight: 5,
          uid: 'mock-card-9',
          metadata: { ownerName: 'Naomi Okafor', cardNumber: '4977 •••• •••• 7781' },
        },
      ] as GroundEntry[],
    }
  },

  /**
   * Exactly one free carried slot, holding a stack worth splitting: the last
   * split that can succeed, and the one after it that must not.
   */
  tight: () => {
    const inventory = createMockInventory()
    inventory.stacks = { '1': stack(1, 'bandage', 6, 50) }

    for (let slot = 2; slot < inventory.slots; slot += 1) {
      inventory.stacks[String(slot)] = stack(slot, 'ore', 1, 800, {
        uid: `mock-tight-${slot}`,
        metadata: { purity: 20 + slot, origin: 'Mine de Paleto' },
      })
    }

    return { inventory, ground: createMockGround() }
  },
} as const

export type MockScenario = keyof typeof MOCK_SCENARIOS

/**
 * Second containers to open beside the bag. Three shapes worth looking at:
 * one with room to spare, one already saturated, and one that holds nothing
 * at all — the state a locker spends most of its life in.
 */
export const MOCK_STASHES = {
  locker: () => ({
    kind: 'stash',
    id: 'policelocker',
    label: 'Casier personnel',
    icon: 'mdi-locker',
    slots: 24,
    maxWeight: 70000,
    items: [
      { item: 'bandage', count: 12 },
      { item: 'water', count: 6 },
      { item: 'ammo-9', count: 120 },
      { item: 'radio', count: 1 },
      { item: 'lockpick', count: 2 },
    ],
  }),

  evidence: () => ({
    kind: 'stash',
    id: 'policeevidence',
    label: 'Salle des scellés',
    icon: 'mdi-archive-outline',
    slots: 12,
    maxWeight: 4000,
    items: [
      { item: 'ore', count: 1, uid: 'mock-seal-1', metadata: { purity: 82, origin: 'Scellé 114' } },
      { item: 'ore', count: 1, uid: 'mock-seal-2', metadata: { purity: 41, origin: 'Scellé 115' } },
      { item: 'cash', count: 3200 },
    ],
  }),

  vacant: () => ({
    kind: 'stash',
    id: 'emslocker',
    label: 'Casier personnel',
    icon: 'mdi-locker',
    slots: 24,
    maxWeight: 70000,
    items: [],
  }),
} as const

export type MockStashName = keyof typeof MOCK_STASHES
