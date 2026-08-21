/**
 * `secondary` is the panel beside the bag, whatever happens to be in it. The
 * interface never names which container that is: the server knows what the
 * player opened, and a client that could name one could name another.
 */
export type ContainerKind = 'player' | 'ground' | 'hotbar' | 'secondary'

export type ItemType = 'item' | 'weapon' | 'component'

export type MetadataFormat = 'text' | 'number' | 'percent' | 'money' | 'date'

/** One declared, displayable property, in the order the item listed it. */
export interface MetadataField {
  key: string
  label: string
  format: MetadataFormat
}

export interface ItemDefinition {
  /** Internal identifier, what a stack stores and the catalogue is keyed by. */
  id: string
  /** Business name of the object, which is not always the identifier. */
  name: string
  label: string
  description: string
  type: ItemType
  weight: number
  image: string
  stackable: boolean
  maxStack?: number
  unique: boolean
  usable: boolean
  closeOnUse: boolean
  uses?: number
  decays: boolean
  /** Declared on a weapon: the ammunition it accepts. */
  ammoType?: string
  /** Declared on a weapon: the family it belongs to. */
  category?: string
  /** Declared on a component: the attachment slot it occupies. */
  slot?: string
  metadataFields?: MetadataField[]
}

export type ItemCatalogue = Record<string, ItemDefinition>

export type ItemMetadata = Record<string, string | number | boolean>

export interface ItemStack {
  slot: number
  /** The item identifier, matching a catalogue key. */
  item: string
  count: number
  weight: number
  uid?: string
  metadata?: ItemMetadata
  /** Uses left, for the kinds that count them. Never a quantity. */
  uses?: number
  maxUses?: number
  /** Share of shelf life left, 0 to 1. Absent when the kind never spoils. */
  freshness?: number
}

export interface GroundEntry extends Omit<ItemStack, 'slot'> {
  dropId: number
  slot: number
}

/** Any container shown beside the bag: a stash today, a trunk tomorrow. */
export interface SecondaryContainer {
  /** The family it belongs to, which is what a caller reasons about. */
  kind: string
  id: string
  label: string
  icon: string
  /** Shows what is inside and refuses every gesture that would move it. */
  readOnly?: boolean
  slots: number
  maxWeight: number
  weight: number
  stacks: Record<string, ItemStack>
}

/** The hint shown when something can be opened by pressing a key. */
export interface InteractionPrompt {
  label: string
  key: string
}

export interface PlayerInventory {
  id: number
  ownerType: string
  slots: number
  maxWeight: number
  weight: number
  hotbar: Record<string, ItemStack>
  stacks: Record<string, ItemStack>
}

export interface InventoryConfig {
  slots: number
  maxWeight: number
  hotbarSlots: number
}

export interface NearbyPlayer {
  id: number
  name: string
  distance: number
}

export interface CharacterIdentity {
  firstName: string
  lastName: string
}

export interface ContainerRef {
  container: ContainerKind
  slot?: number
  dropId?: number
}

export interface MoveRequest {
  from: ContainerRef
  to: ContainerRef
  count: number
}

export interface GiveRequest {
  slot: number
  count: number
  target: number
}

export interface UseRequest {
  slot: number
}

export interface SplitRequest {
  slot: number
  count: number
}

export interface InventoryState {
  inventory: PlayerInventory | null
  ground: GroundEntry[]
  container?: SecondaryContainer | null
}

/** Where a drag started, so a drop knows what it is carrying. */
export interface DragPayload {
  ref: ContainerRef
  stack: ItemStack
  definition: ItemDefinition
}
