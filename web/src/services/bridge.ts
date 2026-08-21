import type {
  CharacterIdentity,
  GiveRequest,
  GroundEntry,
  InventoryConfig,
  InventoryState,
  InteractionPrompt,
  ItemCatalogue,
  MoveRequest,
  NearbyPlayer,
  SecondaryContainer,
  SplitRequest,
  UseRequest,
} from '@/types/inventory'
import type { CustomizationState, ReloadState } from '@/types/weapon'

export interface LocalePayload {
  language: string
  translations: Record<string, unknown>
}

/**
 * Everything the outside world may push into the interface. The store owns
 * the one implementation and hands it to whichever bridge is active, so the
 * mock and the real client feed the exact same code path.
 */
export interface BridgeSink {
  setOpen(open: boolean): void
  setState(state: InventoryState): void
  /** Only what lies on the ground, when the world moved around the player. */
  setGround(entries: GroundEntry[]): void
  /** The panel beside the bag. `null` takes it away. */
  setContainer(container: SecondaryContainer | null): void
  /** `null` hides the hint. */
  setPrompt(prompt: InteractionPrompt | null): void
  setCatalogue(catalogue: ItemCatalogue): void
  setConfig(config: InventoryConfig): void
  setIdentity(identity: CharacterIdentity): void
  setLocale(payload: LocalePayload): void
  refuse(reason: string): void
  /** `null` closes the panel. */
  setCustomization(state: CustomizationState | null): void
  /** `null` closes the dialog. */
  setReload(state: ReloadState | null): void
}

/**
 * Everything the interface may ask of the outside world. Components never
 * touch this: they go through the store, which holds the one implementation
 * picked at startup.
 */
export interface InventoryBridge {
  start(): Promise<void>
  move(request: MoveRequest): Promise<void>
  use(request: UseRequest): Promise<void>
  split(request: SplitRequest): Promise<void>
  give(request: GiveRequest): Promise<void>
  nearbyPlayers(): Promise<NearbyPlayer[]>
  close(): Promise<void>

  /** Opens the customization view on a weapon instance. */
  openCustomization(uid: string): Promise<void>
  /** Previews a component in a slot. Nothing is persisted until the close. */
  fitComponent(slot: string, item: string): Promise<void>
  clearComponent(slot: string): Promise<void>
  /** Leaves the view, committing the previewed state when asked to save. */
  closeCustomization(save: boolean): Promise<void>

  /** Fills a weapon instance, naming the capacity the engine reported. */
  reload(uid: string, magazine: number): Promise<void>
}
