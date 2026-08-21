import { MOCK_CATALOGUE } from '@/mock/catalogue'
import type { ItemMetadata, ItemStack, SecondaryContainer } from '@/types/inventory'

const definitionOf = (item: string) => MOCK_CATALOGUE[item]

const unitWeight = (item: string): number => definitionOf(item)?.weight ?? 0

const maxStackOf = (item: string): number => {
  const definition = definitionOf(item)

  if (!definition || !definition.stackable || definition.unique) {
    return 1
  }

  return definition.maxStack ?? Number.POSITIVE_INFINITY
}

const signature = (metadata?: ItemMetadata): string =>
  metadata
    ? Object.keys(metadata)
        .sort()
        .map((key) => `${key}=${String(metadata[key])}`)
        .join(',')
    : ''

const canStack = (a: Partial<ItemStack>, b: Partial<ItemStack>): boolean => {
  if (!a.item || a.item !== b.item || a.uid || b.uid) {
    return false
  }

  const definition = definitionOf(a.item)

  if (!definition || !definition.stackable || definition.unique) {
    return false
  }

  return a.uses === b.uses && signature(a.metadata) === signature(b.metadata)
}

export interface MockContainerSeed {
  kind: string
  id: string
  label: string
  icon: string
  slots: number
  maxWeight: number
  items?: { item: string; count: number; metadata?: ItemMetadata; uid?: string }[]
}

/**
 * The second panel, standing in for whatever the server would have opened.
 * It carries the same weight, slot and stacking rules as the bag beside it,
 * because the point of the mock is to find out what a player would run into
 * before a player does.
 */
export class MockContainer {
  private readonly seed: MockContainerSeed
  private stacks: Record<string, ItemStack> = {}

  constructor(seed: MockContainerSeed) {
    this.seed = seed

    for (const entry of seed.items ?? []) {
      this.add(entry, entry.count)
    }
  }

  snapshot(): SecondaryContainer {
    const stacks: Record<string, ItemStack> = {}

    for (const [key, stack] of Object.entries(this.stacks)) {
      stacks[key] = { ...stack, weight: unitWeight(stack.item) * stack.count }
    }

    return {
      kind: this.seed.kind,
      id: this.seed.id,
      label: this.seed.label,
      icon: this.seed.icon,
      slots: this.seed.slots,
      maxWeight: this.seed.maxWeight,
      weight: this.weight(),
      stacks,
    }
  }

  weight(): number {
    return Object.values(this.stacks).reduce(
      (total, stack) => total + unitWeight(stack.item) * stack.count,
      0,
    )
  }

  stackAt(slot: number): ItemStack | undefined {
    return this.stacks[String(slot)]
  }

  private freeWeight(): number {
    return this.seed.maxWeight <= 0
      ? Number.POSITIVE_INFINITY
      : Math.max(0, this.seed.maxWeight - this.weight())
  }

  private freeSlot(): number | null {
    for (let slot = 1; slot <= this.seed.slots; slot += 1) {
      if (!this.stacks[String(slot)]) {
        return slot
      }
    }

    return null
  }

  private byWeight(item: string, count: number): number {
    const unit = unitWeight(item)
    const free = this.freeWeight()

    if (unit <= 0 || free === Number.POSITIVE_INFINITY) {
      return count
    }

    return Math.floor(free / unit)
  }

  add(instance: Partial<ItemStack> & { item: string }, count: number): number {
    const perSlot = maxStackOf(instance.item)
    let remaining = Math.min(count, this.byWeight(instance.item, count))

    if (remaining <= 0) {
      return 0
    }

    const placed = remaining

    for (const [key, stack] of Object.entries(this.stacks)) {
      if (remaining <= 0) {
        break
      }

      if (canStack(stack, instance)) {
        const room = perSlot === Number.POSITIVE_INFINITY ? remaining : perSlot - stack.count
        const moved = Math.min(room, remaining)

        stack.count += moved
        remaining -= moved
        this.stacks[key] = stack
      }
    }

    let carried = instance.uid

    while (remaining > 0) {
      const slot = this.freeSlot()

      if (!slot) {
        break
      }

      const portion =
        perSlot === Number.POSITIVE_INFINITY ? remaining : Math.min(perSlot, remaining)

      this.stacks[String(slot)] = {
        slot,
        item: instance.item,
        count: portion,
        weight: unitWeight(instance.item) * portion,
        metadata: instance.metadata,
        uid: carried,
        uses: instance.uses,
        freshness: instance.freshness,
      }

      remaining -= portion
      carried = undefined
    }

    return placed - remaining
  }

  place(slot: number, instance: ItemStack): number {
    const key = String(slot)
    const existing = this.stacks[key]

    if (slot < 1 || slot > this.seed.slots) {
      return 0
    }

    const perSlot = maxStackOf(instance.item)
    const allowed = this.byWeight(instance.item, instance.count)

    if (!existing) {
      const placed = Math.min(
        instance.count,
        allowed,
        perSlot === Number.POSITIVE_INFINITY ? instance.count : perSlot,
      )

      if (placed <= 0) {
        return 0
      }

      this.stacks[key] = {
        ...instance,
        slot,
        count: placed,
        weight: unitWeight(instance.item) * placed,
      }

      return placed
    }

    if (!canStack(existing, instance)) {
      return 0
    }

    const room = perSlot === Number.POSITIVE_INFINITY ? instance.count : perSlot - existing.count
    const placed = Math.min(instance.count, allowed, room)

    if (placed <= 0) {
      return 0
    }

    existing.count += placed

    return placed
  }

  take(slot: number, count: number): ItemStack | null {
    const key = String(slot)
    const stack = this.stacks[key]

    if (!stack || count <= 0) {
      return null
    }

    const moved = Math.min(count, stack.count)
    const taken: ItemStack = { ...stack, count: moved, weight: unitWeight(stack.item) * moved }

    if (moved >= stack.count) {
      delete this.stacks[key]
    } else {
      stack.count -= moved
    }

    return taken
  }
}
