import { sendNuiCallback } from '@/utils/nui'
import type { BridgeSink, InventoryBridge, LocalePayload } from '@/services/bridge'
import type {
  CharacterIdentity,
  GiveRequest,
  GroundEntry,
  InventoryConfig,
  InteractionPrompt,
  InventoryState,
  ItemCatalogue,
  MoveRequest,
  NearbyPlayer,
  SecondaryContainer,
  SplitRequest,
  UseRequest,
} from '@/types/inventory'
import type { CustomizationState, ReloadState } from '@/types/weapon'

const EVENT = {
  ready: 'siku_inventory:nui:ready',
  close: 'siku_inventory:nui:close',
  move: 'siku_inventory:nui:move',
  use: 'siku_inventory:nui:use',
  split: 'siku_inventory:nui:split',
  give: 'siku_inventory:nui:give',
  nearby: 'siku_inventory:nui:nearbyPlayers',
  openCustomization: 'siku_inventory:nui:openCustomization',
  fitComponent: 'siku_inventory:nui:fitComponent',
  clearComponent: 'siku_inventory:nui:clearComponent',
  closeCustomization: 'siku_inventory:nui:closeCustomization',
  reload: 'siku_inventory:nui:reload',
} as const

interface NuiMessage {
  action?: unknown
  open?: unknown
  state?: unknown
  catalogue?: unknown
  config?: unknown
  identity?: unknown
  locale?: unknown
  reason?: unknown
  customization?: unknown
  reload?: unknown
  ground?: unknown
  container?: unknown
  prompt?: unknown
}

const isObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null

/**
 * Talks to the FiveM client. Actions are fire-and-forget; state always comes
 * back through a pushed message rather than a return value, which is what
 * keeps the server the single source of truth.
 */
export const createNuiBridge = (sink: BridgeSink): InventoryBridge => {
  const handle = (event: MessageEvent<NuiMessage>): void => {
    const data = event.data

    if (!data || typeof data.action !== 'string') {
      return
    }

    switch (data.action) {
      case 'siku_inventory:nui:setOpen':
        sink.setOpen(data.open === true)
        break
      case 'siku_inventory:nui:setState':
        if (isObject(data.state)) {
          sink.setState(data.state as unknown as InventoryState)
        }
        break
      case 'siku_inventory:nui:setGround':
        sink.setGround(Array.isArray(data.ground) ? (data.ground as GroundEntry[]) : [])
        break
      case 'siku_inventory:nui:setContainer':
        sink.setContainer(
          isObject(data.container) ? (data.container as unknown as SecondaryContainer) : null,
        )
        break
      case 'siku_inventory:nui:setPrompt':
        sink.setPrompt(isObject(data.prompt) ? (data.prompt as unknown as InteractionPrompt) : null)
        break
      case 'siku_inventory:nui:setCatalogue':
        if (isObject(data.catalogue)) {
          sink.setCatalogue(data.catalogue as ItemCatalogue)
        }
        break
      case 'siku_inventory:nui:setConfig':
        if (isObject(data.config)) {
          sink.setConfig(data.config as unknown as InventoryConfig)
        }
        break
      case 'siku_inventory:nui:setIdentity':
        if (isObject(data.identity)) {
          sink.setIdentity(data.identity as unknown as CharacterIdentity)
        }
        break
      case 'siku_inventory:nui:setLocale':
        if (isObject(data.locale)) {
          sink.setLocale(data.locale as unknown as LocalePayload)
        }
        break
      case 'siku_inventory:nui:actionRefused':
        sink.refuse(typeof data.reason === 'string' ? data.reason : 'refused')
        break
      case 'siku_inventory:nui:setCustomization':
        sink.setCustomization(
          isObject(data.customization)
            ? (data.customization as unknown as CustomizationState)
            : null,
        )
        break
      case 'siku_inventory:nui:setReload':
        sink.setReload(isObject(data.reload) ? (data.reload as unknown as ReloadState) : null)
        break
      default:
        break
    }
  }

  return {
    async start() {
      window.addEventListener('message', handle)
      await sendNuiCallback(EVENT.ready)
    },

    async move(request: MoveRequest) {
      await sendNuiCallback(EVENT.move, request)
    },

    async use(request: UseRequest) {
      await sendNuiCallback(EVENT.use, request)
    },

    async split(request: SplitRequest) {
      await sendNuiCallback(EVENT.split, request)
    },

    async give(request: GiveRequest) {
      await sendNuiCallback(EVENT.give, request)
    },

    async nearbyPlayers() {
      const players = await sendNuiCallback<undefined, NearbyPlayer[]>(EVENT.nearby)

      return players ?? []
    },

    async close() {
      await sendNuiCallback(EVENT.close)
    },

    async openCustomization(uid: string) {
      await sendNuiCallback(EVENT.openCustomization, { uid })
    },

    async fitComponent(slot: string, item: string) {
      await sendNuiCallback(EVENT.fitComponent, { slot, item })
    },

    async clearComponent(slot: string) {
      await sendNuiCallback(EVENT.clearComponent, { slot })
    },

    async reload(uid: string, magazine: number) {
      await sendNuiCallback(EVENT.reload, { uid, magazine })
    },

    async closeCustomization(save: boolean) {
      await sendNuiCallback(EVENT.closeCustomization, { save })
    },
  }
}
