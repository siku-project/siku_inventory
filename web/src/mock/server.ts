import { MOCK_CATALOGUE } from '@/mock/catalogue'
import { MockContainer, type MockContainerSeed } from '@/mock/container'
import type {
  ContainerRef,
  GiveRequest,
  GroundEntry,
  InventoryState,
  ItemMetadata,
  ItemStack,
  MoveRequest,
  NearbyPlayer,
  PlayerInventory,
  SplitRequest,
} from '@/types/inventory'

const SLOTS = 40
const MAX_WEIGHT = 35000
const HOTBAR_SLOTS = 5
const HOTBAR_OFFSET = 1000

export interface MockOutcome {
  state: InventoryState
  refusal?: string
}

interface GroundStack extends ItemStack {
  dropId: number
}

const definitionOf = (item: string) => MOCK_CATALOGUE[item]

const unitWeight = (item: string): number => definitionOf(item)?.weight ?? 0

const maxStackOf = (item: string): number => {
  const definition = definitionOf(item)

  if (!definition || !definition.stackable || definition.unique) {
    return 1
  }

  return definition.maxStack ?? Number.POSITIVE_INFINITY
}

const signature = (metadata?: ItemMetadata): string => {
  if (!metadata) {
    return ''
  }

  return Object.keys(metadata)
    .sort()
    .map((key) => `${key}=${String(metadata[key])}`)
    .join(',')
}

/**
 * The one compatibility rule, mirroring CanStack on the server: kind,
 * identity, metadata and remaining uses must all agree. Freshness on purpose
 * does not, and a merge inherits the lower of the two.
 */
const canStack = (a: Partial<ItemStack>, b: Partial<ItemStack>): boolean => {
  if (!a.item || a.item !== b.item || a.uid || b.uid) {
    return false
  }

  const definition = definitionOf(a.item)

  if (!definition || !definition.stackable || definition.unique) {
    return false
  }

  if (a.uses !== b.uses) {
    return false
  }

  return signature(a.metadata) === signature(b.metadata)
}

const mergedFreshness = (a?: number, b?: number): number | undefined => {
  if (a === undefined) {
    return b
  }

  if (b === undefined) {
    return a
  }

  return Math.min(a, b)
}

const isHotbarSlot = (slot: number): boolean => slot > HOTBAR_OFFSET

let uidCounter = 1000

const nextUid = (): string => {
  uidCounter += 1

  return `mock-${uidCounter}`
}

/**
 * A stand-in for the server, used only by `bun run dev`. It applies the same
 * stacking, weight, slot and hotbar rules so the interface can be exercised
 * end to end without FiveM. Production never loads it.
 *
 * Like the real server it holds every stack in one map, hotbar included: a
 * hotbar slot is just a slot above the offset, which is what makes eviction
 * and weight behave here exactly as they do in game.
 */
/**
 * What the server keeps on each weapon instance. Fitted parts are stored
 * server-side and never reach the interface — the metadata a stack carries on
 * the wire is flat — so they are held apart here, the same way.
 */
const FITTED: Record<string, Record<string, { item: string; serial: string }>> = {
  'mock-pistol-1': {
    magazine: { item: 'at_clip_extended_pistol', serial: 'SK-2210-M' },
  },
}

export class MockServer {
  private inventory: PlayerInventory
  private stacks: Record<string, ItemStack>
  private ground: GroundStack[]
  private container: MockContainer | null = null
  private nextDropId = 1

  constructor(inventory: PlayerInventory, ground: GroundEntry[]) {
    this.inventory = inventory
    this.stacks = {}
    this.ground = ground.map((entry) => ({ ...entry }))
    this.nextDropId = ground.reduce((max, entry) => Math.max(max, entry.dropId), 0) + 1

    for (const [key, stack] of Object.entries(inventory.stacks)) {
      this.stacks[key] = { ...stack }
    }

    for (const [index, stack] of Object.entries(inventory.hotbar)) {
      const slot = HOTBAR_OFFSET + Number(index)

      this.stacks[String(slot)] = { ...stack, slot }
    }
  }

  snapshot(): InventoryState {
    const stacks: Record<string, ItemStack> = {}
    const hotbar: Record<string, ItemStack> = {}

    for (const [key, stack] of Object.entries(this.stacks)) {
      const slot = Number(key)
      const exposed = { ...stack, slot, weight: unitWeight(stack.item) * stack.count }

      if (isHotbarSlot(slot)) {
        hotbar[String(slot - HOTBAR_OFFSET)] = exposed
      } else {
        stacks[key] = exposed
      }
    }

    return {
      inventory: { ...this.inventory, weight: this.weight(), stacks, hotbar },
      ground: this.ground.map((entry) => ({
        ...entry,
        weight: unitWeight(entry.item) * entry.count,
      })),
      container: this.container ? this.container.snapshot() : null,
    }
  }

  /** Stands in for a stash the server agreed to open. */
  openContainer(seed: MockContainerSeed): void {
    this.container = new MockContainer(seed)
  }

  closeContainer(): void {
    this.container = null
  }

  private weight(): number {
    return Object.values(this.stacks).reduce(
      (total, stack) => total + unitWeight(stack.item) * stack.count,
      0,
    )
  }

  private freeWeight(): number {
    return Math.max(0, this.inventory.maxWeight - this.weight())
  }

  /** Only carried slots are candidates: the hotbar is filled on purpose. */
  private freeSlot(): number | null {
    for (let slot = 1; slot <= this.inventory.slots; slot += 1) {
      if (!this.stacks[String(slot)]) {
        return slot
      }
    }

    return null
  }

  private freeSlotCount(): number {
    let free = 0

    for (let slot = 1; slot <= this.inventory.slots; slot += 1) {
      if (!this.stacks[String(slot)]) {
        free += 1
      }
    }

    return free
  }

  private mergeableSlots(item: string, metadata?: ItemMetadata): number[] {
    const found: number[] = []

    for (const [key, stack] of Object.entries(this.stacks)) {
      const slot = Number(key)

      if (!isHotbarSlot(slot) && canStack(stack, { item, metadata })) {
        found.push(slot)
      }
    }

    return found.sort((a, b) => a - b)
  }

  private accepted(item: string, count: number, metadata?: ItemMetadata): number {
    const unit = unitWeight(item)
    const byWeight = unit > 0 ? Math.floor(this.freeWeight() / unit) : count

    if (byWeight <= 0) {
      return 0
    }

    const perSlot = maxStackOf(item)
    let room = 0

    for (const slot of this.mergeableSlots(item, metadata)) {
      const stack = this.stacks[String(slot)]

      if (stack) {
        room += perSlot === Number.POSITIVE_INFINITY ? count : perSlot - stack.count
      }
    }

    room += this.freeSlotCount() * (perSlot === Number.POSITIVE_INFINITY ? count : perSlot)

    return Math.max(0, Math.min(count, byWeight, room))
  }

  /**
   * Takes the whole instance as a template, like the server does, so that
   * freshness and remaining uses follow the units into their new home.
   */
  private addToInventory(instance: Partial<ItemStack> & { item: string }, count: number): number {
    const { item, metadata, uid } = instance
    const accepted = this.accepted(item, count, metadata)

    if (accepted <= 0) {
      return 0
    }

    let remaining = accepted
    const perSlot = maxStackOf(item)
    const definition = definitionOf(item)

    if (definition && !definition.unique) {
      for (const slot of this.mergeableSlots(item, metadata)) {
        if (remaining <= 0) {
          break
        }

        const stack = this.stacks[String(slot)]

        if (stack) {
          const room = perSlot === Number.POSITIVE_INFINITY ? remaining : perSlot - stack.count
          const moved = Math.min(room, remaining)

          stack.count += moved
          stack.freshness = mergedFreshness(stack.freshness, instance.freshness)
          remaining -= moved
        }
      }
    }

    let carried = uid

    while (remaining > 0) {
      const slot = this.freeSlot()

      if (!slot) {
        break
      }

      const portion =
        perSlot === Number.POSITIVE_INFINITY ? remaining : Math.min(perSlot, remaining)

      this.stacks[String(slot)] = {
        slot,
        item,
        count: portion,
        weight: unitWeight(item) * portion,
        metadata,
        uid: carried ?? (definition?.unique ? nextUid() : undefined),
        uses: instance.uses,
        freshness: instance.freshness,
      }

      remaining -= portion
      carried = undefined
    }

    return accepted - remaining
  }

  private takeFromSlot(slot: number, count: number): ItemStack | null {
    const key = String(slot)
    const stack = this.stacks[key]

    if (!stack || count <= 0) {
      return null
    }

    const moved = Math.min(count, stack.count)
    const taken: ItemStack = {
      slot,
      item: stack.item,
      count: moved,
      weight: unitWeight(stack.item) * moved,
      metadata: stack.metadata,
      uid: stack.uid,
    }

    if (moved >= stack.count) {
      delete this.stacks[key]
    } else {
      stack.count -= moved
    }

    return taken
  }

  private takeFromGround(dropId: number, slot: number, count: number): ItemStack | null {
    const index = this.ground.findIndex((entry) => entry.dropId === dropId && entry.slot === slot)

    if (index < 0 || count <= 0) {
      return null
    }

    const entry = this.ground[index]

    if (!entry) {
      return null
    }

    const moved = Math.min(count, entry.count)
    const taken: ItemStack = {
      slot: entry.slot,
      item: entry.item,
      count: moved,
      weight: unitWeight(entry.item) * moved,
      metadata: entry.metadata,
      uid: entry.uid,
    }

    if (moved >= entry.count) {
      this.ground.splice(index, 1)
    } else {
      entry.count -= moved
      entry.weight = unitWeight(entry.item) * entry.count
    }

    return taken
  }

  /**
   * Merges into the stacks already lying there before opening a new drop, so
   * six bottles put down one after another read as one stack. Compatibility
   * is asked of the same rule the inventory uses, which is what keeps two
   * different bank cards from ever becoming a stack of two.
   */
  private pushToGround(instance: ItemStack): void {
    let remaining = instance.count

    for (const entry of this.ground) {
      if (remaining <= 0) {
        break
      }

      if (!canStack(entry, instance)) {
        continue
      }

      const perSlot = maxStackOf(entry.item)
      const room = perSlot === Number.POSITIVE_INFINITY ? remaining : perSlot - entry.count
      const moved = Math.min(room, remaining)

      if (moved > 0) {
        entry.count += moved
        entry.freshness = mergedFreshness(entry.freshness, instance.freshness)
        remaining -= moved
      }
    }

    while (remaining > 0) {
      const perSlot = maxStackOf(instance.item)
      const portion =
        perSlot === Number.POSITIVE_INFINITY ? remaining : Math.min(perSlot, remaining)
      const dropId = this.nextDropId

      this.nextDropId += 1
      this.ground.push({
        dropId,
        slot: 1,
        item: instance.item,
        count: portion,
        weight: unitWeight(instance.item) * portion,
        metadata: instance.metadata,
        uid: instance.uid,
        uses: instance.uses,
        freshness: instance.freshness,
      })

      remaining -= portion
    }
  }

  /** Turns a reference the interface sent into the slot it stands for. */
  private resolve(reference: ContainerRef): number | null {
    if (reference.container === 'hotbar') {
      const index = reference.slot ?? 0

      if (index < 1 || index > HOTBAR_SLOTS) {
        return null
      }

      return HOTBAR_OFFSET + index
    }

    if (reference.container !== 'player' || reference.slot === undefined) {
      return null
    }

    return isHotbarSlot(reference.slot) ? null : reference.slot
  }

  move(request: MoveRequest): MockOutcome {
    const { from, to, count } = request

    if (count <= 0) {
      return { state: this.snapshot(), refusal: 'invalid_quantity' }
    }

    if (from.container === 'secondary' || to.container === 'secondary') {
      return this.moveAcrossContainer(from, to, count)
    }

    if (from.container === 'player' && to.container === 'ground' && to.dropId === undefined) {
      return this.drop(from.slot ?? 0, count)
    }

    if (from.container === 'hotbar' && to.container === 'ground') {
      const slot = this.resolve(from)

      return slot === null
        ? { state: this.snapshot(), refusal: 'invalid_request' }
        : this.drop(slot, count)
    }

    if (from.container === 'ground') {
      const taken = this.takeFromGround(from.dropId ?? 0, from.slot ?? 0, count)

      if (!taken) {
        return { state: this.snapshot(), refusal: 'empty_slot' }
      }

      const target = to.container === 'player' && to.slot !== undefined ? this.resolve(to) : null
      const placed =
        target !== null ? this.placeInSlot(target, taken) : this.addToInventory(taken, taken.count)

      if (placed < taken.count) {
        this.pushToGround({ ...taken, count: taken.count - placed })
      }

      return { state: this.snapshot(), refusal: placed > 0 ? undefined : 'no_room' }
    }

    const fromSlot = this.resolve(from)

    if (fromSlot === null) {
      return { state: this.snapshot(), refusal: 'invalid_request' }
    }

    if (to.container === 'hotbar') {
      const hotbarSlot = this.resolve(to)

      return hotbarSlot === null
        ? { state: this.snapshot(), refusal: 'invalid_request' }
        : this.placeIntoHotbar(fromSlot, hotbarSlot, count)
    }

    if (to.container !== 'player') {
      return { state: this.snapshot(), refusal: 'invalid_request' }
    }

    if (to.slot === undefined) {
      return this.moveInside(fromSlot, null, count)
    }

    const toSlot = this.resolve(to)

    return toSlot === null
      ? { state: this.snapshot(), refusal: 'invalid_request' }
      : this.moveInside(fromSlot, toSlot, count)
  }

  /**
   * Moves between the bag and the panel beside it. Whatever the far side
   * refuses goes back to the very slot it came from, which is always able to
   * take it again — the rule the real transfer follows.
   */
  private moveAcrossContainer(from: ContainerRef, to: ContainerRef, count: number): MockOutcome {
    const container = this.container

    if (!container) {
      return { state: this.snapshot(), refusal: 'unreachable' }
    }

    if (from.container === 'secondary' && to.container === 'secondary') {
      return this.moveInsideContainer(container, from.slot ?? 0, to.slot, count)
    }

    if (from.container === 'secondary') {
      const taken = container.take(from.slot ?? 0, count)

      if (!taken) {
        return { state: this.snapshot(), refusal: 'empty_slot' }
      }

      const target = to.container === 'player' && to.slot !== undefined ? this.resolve(to) : null
      const placed =
        target !== null ? this.placeInSlot(target, taken) : this.addToInventory(taken, taken.count)

      if (placed < taken.count) {
        container.place(from.slot ?? 0, { ...taken, count: taken.count - placed })
      }

      return { state: this.snapshot(), refusal: placed > 0 ? undefined : 'no_room' }
    }

    const fromSlot = this.resolve(from)

    if (fromSlot === null) {
      return { state: this.snapshot(), refusal: 'invalid_request' }
    }

    const taken = this.takeFromSlot(fromSlot, count)

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const placed =
      to.slot !== undefined ? container.place(to.slot, taken) : container.add(taken, taken.count)

    if (placed < taken.count) {
      this.placeInSlot(fromSlot, { ...taken, count: taken.count - placed })
    }

    return { state: this.snapshot(), refusal: placed > 0 ? undefined : 'no_room' }
  }

  private moveInsideContainer(
    container: MockContainer,
    fromSlot: number,
    toSlot: number | undefined,
    count: number,
  ): MockOutcome {
    if (fromSlot === toSlot) {
      return { state: this.snapshot(), refusal: 'same_slot' }
    }

    const source = container.stackAt(fromSlot)

    if (!source) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const target = toSlot === undefined ? undefined : container.stackAt(toSlot)

    if (toSlot !== undefined && target) {
      const first = container.take(fromSlot, source.count)
      const second = container.take(toSlot, target.count)

      if (first && second) {
        container.place(fromSlot, second)
        container.place(toSlot, first)
      }

      return { state: this.snapshot() }
    }

    const taken = container.take(fromSlot, Math.min(count, source.count))

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const placed =
      toSlot === undefined ? container.add(taken, taken.count) : container.place(toSlot, taken)

    if (placed < taken.count) {
      container.place(fromSlot, { ...taken, count: taken.count - placed })
    }

    return { state: this.snapshot(), refusal: placed > 0 ? undefined : 'no_room' }
  }

  private placeInSlot(slot: number, instance: ItemStack): number {
    const key = String(slot)
    const existing = this.stacks[key]
    const unit = unitWeight(instance.item)
    const byWeight = unit > 0 ? Math.floor(this.freeWeight() / unit) : instance.count

    if (!existing) {
      const perSlot = maxStackOf(instance.item)
      const placed = Math.min(
        instance.count,
        byWeight,
        perSlot === Number.POSITIVE_INFINITY ? instance.count : perSlot,
      )

      if (placed <= 0) {
        return 0
      }

      this.stacks[key] = {
        slot,
        item: instance.item,
        count: placed,
        weight: unit * placed,
        metadata: instance.metadata,
        uid: instance.uid,
        uses: instance.uses,
        freshness: instance.freshness,
      }

      return placed
    }

    if (!canStack(existing, instance)) {
      return 0
    }

    const perSlot = maxStackOf(instance.item)
    const room = perSlot === Number.POSITIVE_INFINITY ? instance.count : perSlot - existing.count
    const placed = Math.min(instance.count, byWeight, room)

    if (placed <= 0) {
      return 0
    }

    existing.count += placed
    existing.freshness = mergedFreshness(existing.freshness, instance.freshness)

    return placed
  }

  /**
   * Fills a hotbar slot, sending whatever sat there back to the carried grid.
   * The eviction is checked before anything is committed, so a full grid
   * refuses the exchange instead of losing the evicted stack.
   */
  private placeIntoHotbar(fromSlot: number, hotbarSlot: number, count: number): MockOutcome {
    if (fromSlot === hotbarSlot) {
      return { state: this.snapshot(), refusal: 'same_slot' }
    }

    const source = this.stacks[String(fromSlot)]

    if (!source) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const occupant = this.stacks[String(hotbarSlot)]

    if (occupant && canStack(occupant, source)) {
      return this.moveInside(fromSlot, hotbarSlot, count)
    }

    const taken = this.takeFromSlot(fromSlot, Math.min(count, source.count))

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const evicted = occupant ? this.takeFromSlot(hotbarSlot, occupant.count) : null

    if (evicted && this.accepted(evicted.item, evicted.count, evicted.metadata) < evicted.count) {
      this.stacks[String(hotbarSlot)] = evicted
      this.addToInventory(taken, taken.count)

      return { state: this.snapshot(), refusal: 'no_room' }
    }

    this.stacks[String(hotbarSlot)] = { ...taken, slot: hotbarSlot }

    if (evicted) {
      this.addToInventory(evicted, evicted.count)
    }

    return { state: this.snapshot() }
  }

  private moveInside(fromSlot: number, toSlot: number | null, count: number): MockOutcome {
    if (fromSlot === toSlot) {
      return { state: this.snapshot(), refusal: 'same_slot' }
    }

    const source = this.stacks[String(fromSlot)]

    if (!source) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const wanted = Math.min(count, source.count)
    const target = toSlot === null ? undefined : this.stacks[String(toSlot)]

    if (toSlot !== null && target && !canStack(target, source)) {
      if (wanted < source.count) {
        return { state: this.snapshot(), refusal: 'occupied_slot' }
      }

      this.stacks[String(fromSlot)] = { ...target, slot: fromSlot }
      this.stacks[String(toSlot)] = { ...source, slot: toSlot }

      return { state: this.snapshot() }
    }

    const taken = this.takeFromSlot(fromSlot, wanted)

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const placed =
      toSlot === null ? this.addToInventory(taken, taken.count) : this.placeInSlot(toSlot, taken)

    if (placed < taken.count) {
      this.placeInSlot(fromSlot, { ...taken, count: taken.count - placed })
    }

    return { state: this.snapshot(), refusal: placed > 0 ? undefined : 'no_room' }
  }

  /** Reached through move(); the ground is named as a container, never a slot. */
  private drop(slot: number, count: number): MockOutcome {
    const taken = this.takeFromSlot(slot, count)

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    this.pushToGround(taken)

    return { state: this.snapshot() }
  }

  /**
   * Detaches part of a stack into a free carried slot. Deliberately not a
   * move: handing the quantity back to the inventory would merge it straight
   * into the stack it came from.
   */
  split(request: SplitRequest): MockOutcome {
    const { slot, count } = request

    if (isHotbarSlot(slot)) {
      return { state: this.snapshot(), refusal: 'invalid_slot' }
    }

    const stack = this.stacks[String(slot)]

    if (!stack) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const definition = definitionOf(stack.item)

    if (stack.uid || !definition?.stackable || definition.unique) {
      return { state: this.snapshot(), refusal: 'not_stackable' }
    }

    if (count < 1 || count >= stack.count) {
      return { state: this.snapshot(), refusal: 'invalid_quantity' }
    }

    const destination = this.freeSlot()

    if (!destination) {
      return { state: this.snapshot(), refusal: 'no_free_slot' }
    }

    const taken = this.takeFromSlot(slot, count)

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    this.stacks[String(destination)] = {
      slot: destination,
      item: taken.item,
      count: taken.count,
      weight: unitWeight(taken.item) * taken.count,
      metadata: taken.metadata ? { ...taken.metadata } : undefined,
    }

    return { state: this.snapshot() }
  }

  use(slot: number): MockOutcome {
    const stack = this.stacks[String(slot)]

    if (!stack) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    const definition = definitionOf(stack.item)

    if (!definition?.usable) {
      return { state: this.snapshot(), refusal: 'not_usable' }
    }

    /**
     * A weapon and a box of rounds are used without being spent: one is drawn,
     * the other opens the choice of what to fill. Both are answered by the
     * bridge, which is why neither is consumed here.
     */
    if (definition.type === 'weapon' || this.isAmmo(stack.item)) {
      return { state: this.snapshot() }
    }

    this.takeFromSlot(slot, 1)

    return { state: this.snapshot() }
  }

  /** Whether an item is a round, told apart the way the catalogue tells it. */
  private isAmmo(item: string): boolean {
    const definition = definitionOf(item)

    return definition?.type === 'item' && item.startsWith('ammo-')
  }

  /** How many rounds of a kind the character is carrying. */
  countItem(item: string): number {
    return Object.values(this.stacks)
      .filter((stack) => stack.item === item)
      .reduce((total, stack) => total + stack.count, 0)
  }

  /** The weapons carried that a kind of round fits, loaded state included. */
  weaponsTaking(
    ammoItem: string,
  ): { uid: string; item: string; ammo: number; components: Record<string, string> }[] {
    return Object.entries(this.stacks)
      .filter(([, stack]) => definitionOf(stack.item)?.ammoType === ammoItem)
      .sort(([a], [b]) => Number(a) - Number(b))
      .map(([, stack]) => ({
        uid: stack.uid ?? stack.item,
        item: stack.item,
        ammo: Number(stack.metadata?.ammo ?? 0),
        components: Object.fromEntries(
          Object.entries(FITTED[stack.uid ?? ''] ?? {}).map(([slot, part]) => [slot, part.item]),
        ),
      }))
  }

  /**
   * Fills a weapon out of the bag, the way the server does it: the rounds are
   * removed and written onto the instance in one go, or nothing moves.
   */
  reload(uid: string, magazine: number): MockOutcome {
    const entry = Object.values(this.stacks).find((stack) => stack.uid === uid)
    const ammoItem = entry && definitionOf(entry.item)?.ammoType

    if (!entry || !ammoItem) {
      return { state: this.snapshot(), refusal: 'unknown_weapon' }
    }

    const loaded = Number(entry.metadata?.ammo ?? 0)
    const room = magazine - loaded

    if (room <= 0) {
      return { state: this.snapshot(), refusal: 'already_loaded' }
    }

    const carried = this.countItem(ammoItem)

    if (carried <= 0) {
      return { state: this.snapshot(), refusal: 'no_ammo' }
    }

    let moving = Math.min(room, carried)
    const moved = moving

    for (const [slot, stack] of Object.entries(this.stacks)) {
      if (moving <= 0) {
        break
      }

      if (stack.item !== ammoItem) {
        continue
      }

      const taken = Math.min(moving, stack.count)

      moving -= taken
      stack.count -= taken

      if (stack.count <= 0) {
        delete this.stacks[slot]
      } else {
        stack.weight = (definitionOf(stack.item)?.weight ?? 0) * stack.count
      }
    }

    entry.metadata = { ...entry.metadata, ammo: loaded + moved }

    return { state: this.snapshot() }
  }

  give(request: GiveRequest, players: NearbyPlayer[]): MockOutcome {
    if (!players.some((player) => player.id === request.target)) {
      return { state: this.snapshot(), refusal: 'target_unavailable' }
    }

    const taken = this.takeFromSlot(request.slot, request.count)

    if (!taken) {
      return { state: this.snapshot(), refusal: 'empty_slot' }
    }

    return { state: this.snapshot() }
  }
}

export const MOCK_LIMITS = { SLOTS, MAX_WEIGHT, HOTBAR_SLOTS, HOTBAR_OFFSET }
