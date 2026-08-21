import type { ItemMetadata } from '@/types/inventory'

export interface WeaponSlot {
  id: string
  label: string
}

/** One component the player is carrying that this weapon actually takes. */
export interface AvailableComponent {
  item: string
  /** The attachment slot it occupies once fitted. */
  componentSlot: string
}

export interface CustomizedWeapon {
  uid: string
  item: string
  /** The name the game knows the weapon by. */
  name: string
  ammoType?: string
  metadata?: ItemMetadata
  components: Record<string, string>
}

/**
 * Everything the customization panel reads.
 *
 * `available` has already been filtered by the engine on the client: a part
 * the weapon does not take never reaches here. The fitted components are the
 * session's working copy — they change as the player experiments and only
 * reach the server when the panel is closed with a save.
 */
export interface CustomizationState {
  weapon: CustomizedWeapon
  slots: WeaponSlot[]
  available: AvailableComponent[]
  components: Record<string, string>
}

/** One weapon the rounds being used could go into. */
export interface ReloadTarget {
  uid: string
  item: string
  /** Rounds it is carrying right now. */
  ammo: number
  /** What the game says it holds when full. */
  magazine: number
  /** What it could still take, zero when it is already full. */
  room: number
}

/**
 * Everything the reload dialog reads.
 *
 * `magazine` and `room` were worked out on the client against the engine: the
 * server knows what is carried, only the game knows how much fits.
 */
export interface ReloadState {
  /** The ammunition being used. */
  ammoItem: string
  /** How many rounds of it the character is carrying. */
  carried: number
  weapons: ReloadTarget[]
}
