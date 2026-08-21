import { computed, ref, shallowRef } from 'vue'
import { defineStore } from 'pinia'
import { createMockBridge } from '@/services/mockBridge'
import { createNuiBridge } from '@/services/nuiBridge'
import { applyLocale } from '@/utils/locale'
import type { BridgeSink, InventoryBridge, LocalePayload } from '@/services/bridge'
import type { CustomizationState, ReloadState } from '@/types/weapon'
import type {
  CharacterIdentity,
  ContainerRef,
  GroundEntry,
  InteractionPrompt,
  InventoryConfig,
  ItemCatalogue,
  ItemDefinition,
  ItemStack,
  NearbyPlayer,
  PlayerInventory,
  SecondaryContainer,
} from '@/types/inventory'

const FALLBACK_CONFIG: InventoryConfig = { slots: 40, maxWeight: 35000, hotbarSlots: 5 }
const REFUSAL_LIFETIME = 2600

const UNKNOWN_DEFINITION: ItemDefinition = {
  id: 'unknown',
  name: 'unknown',
  label: 'item.unknown',
  description: '',
  type: 'item',
  weight: 0,
  image: '',
  stackable: false,
  unique: false,
  usable: false,
  closeOnUse: false,
  decays: false,
}

export const useInventoryStore = defineStore('inventory', () => {
  const open = ref(false)
  const inventory = ref<PlayerInventory | null>(null)
  const ground = ref<GroundEntry[]>([])
  const container = ref<SecondaryContainer | null>(null)
  const prompt = ref<InteractionPrompt | null>(null)
  const catalogue = shallowRef<ItemCatalogue>({})
  const config = ref<InventoryConfig>({ ...FALLBACK_CONFIG })
  const identity = ref<CharacterIdentity | null>(null)
  const refusal = ref<string | null>(null)
  const notice = ref<string | null>(null)
  const customization = ref<CustomizationState | null>(null)
  const reloading = ref<ReloadState | null>(null)

  let bridge: InventoryBridge | null = null
  let refusalTimer: ReturnType<typeof setTimeout> | null = null
  let noticeTimer: ReturnType<typeof setTimeout> | null = null

  const sink: BridgeSink = {
    setOpen(next: boolean) {
      open.value = next
    },
    setState(state) {
      inventory.value = state.inventory
      ground.value = state.ground ?? []
      container.value = state.container ?? null
    },
    setGround(entries: GroundEntry[]) {
      ground.value = entries
    },
    setContainer(next: SecondaryContainer | null) {
      container.value = next
    },
    setPrompt(next: InteractionPrompt | null) {
      prompt.value = next
    },
    setCatalogue(next: ItemCatalogue) {
      catalogue.value = next
    },
    setConfig(next: InventoryConfig) {
      config.value = next
    },
    setIdentity(next: CharacterIdentity) {
      identity.value = next
    },
    setLocale(payload: LocalePayload) {
      applyLocale(payload)
    },
    setCustomization(next: CustomizationState | null) {
      customization.value = next
    },
    setReload(next: ReloadState | null) {
      reloading.value = next
    },
    refuse(reason: string) {
      notice.value = null
      refusal.value = reason

      if (refusalTimer) {
        clearTimeout(refusalTimer)
      }

      refusalTimer = setTimeout(() => {
        refusal.value = null
      }, REFUSAL_LIFETIME)
    },
  }

  const slotCount = computed(() => inventory.value?.slots ?? config.value.slots)
  const maxWeight = computed(() => inventory.value?.maxWeight ?? config.value.maxWeight)
  const weight = computed(() => inventory.value?.weight ?? 0)

  const weightRatio = computed(() => {
    if (maxWeight.value <= 0) {
      return 0
    }

    return Math.min(1, weight.value / maxWeight.value)
  })

  const usedSlots = computed(() => Object.keys(inventory.value?.stacks ?? {}).length)
  const isEmpty = computed(() => usedSlots.value === 0)
  const isGroundEmpty = computed(() => ground.value.length === 0)

  const containerUsedSlots = computed(() => Object.keys(container.value?.stacks ?? {}).length)
  const isContainerEmpty = computed(() => containerUsedSlots.value === 0)

  const containerWeightRatio = computed(() => {
    const open = container.value

    if (!open || open.maxWeight <= 0) {
      return 0
    }

    return Math.min(1, open.weight / open.maxWeight)
  })

  const characterName = computed(() => {
    const current = identity.value

    return current ? `${current.firstName} ${current.lastName}`.trim() : ''
  })

  const definitionOf = (item: string): ItemDefinition =>
    catalogue.value[item] ?? { ...UNKNOWN_DEFINITION, id: item, name: item }

  const stackAt = (slot: number): ItemStack | undefined => inventory.value?.stacks[String(slot)]

  const hotbarAt = (index: number): ItemStack | undefined =>
    inventory.value?.hotbar?.[String(index)]

  const containerStackAt = (slot: number): ItemStack | undefined =>
    container.value?.stacks[String(slot)]

  const hotbarSlots = computed(() =>
    Array.from({ length: config.value.hotbarSlots }, (_, position) => {
      const index = position + 1

      return { index, stack: hotbarAt(index) }
    }),
  )

  /**
   * A neutral transient message, sharing the refusal toast rather than adding
   * a second surface. Used for what the interface has to say that is not a
   * rejection.
   */
  const notify = (key: string): void => {
    refusal.value = null
    notice.value = key

    if (noticeTimer) {
      clearTimeout(noticeTimer)
    }

    noticeTimer = setTimeout(() => {
      notice.value = null
    }, REFUSAL_LIFETIME)
  }

  const start = async (): Promise<void> => {
    bridge = import.meta.env.DEV ? createMockBridge(sink) : createNuiBridge(sink)
    await bridge.start()
  }

  const move = async (from: ContainerRef, to: ContainerRef, count: number): Promise<void> => {
    await bridge?.move({ from, to, count })
  }

  const use = async (slot: number): Promise<void> => {
    await bridge?.use({ slot })
  }

  const split = async (slot: number, count: number): Promise<void> => {
    await bridge?.split({ slot, count })
  }

  const give = async (slot: number, count: number, target: number): Promise<void> => {
    await bridge?.give({ slot, count, target })
  }

  const nearbyPlayers = async (): Promise<NearbyPlayer[]> => (await bridge?.nearbyPlayers()) ?? []

  const close = async (): Promise<void> => {
    await bridge?.close()
  }

  const openCustomization = async (uid: string): Promise<void> => {
    await bridge?.openCustomization(uid)
  }

  /**
   * Fitting is a preview: it changes what the model shows and nothing else.
   * The whole arrangement is sent once, when the view is closed with a save.
   */
  const fitComponent = async (slot: string, item: string): Promise<void> => {
    await bridge?.fitComponent(slot, item)
  }

  const clearComponent = async (slot: string): Promise<void> => {
    await bridge?.clearComponent(slot)
  }

  const closeCustomization = async (save = true): Promise<void> => {
    await bridge?.closeCustomization(save)
  }

  /**
   * Filling a weapon is not a preview: the rounds leave the bag the moment the
   * server accepts, so the dialog closes on the way out rather than waiting to
   * be told what happened.
   */
  const reload = async (uid: string, magazine: number): Promise<void> => {
    reloading.value = null

    await bridge?.reload(uid, magazine)
  }

  const closeReload = (): void => {
    reloading.value = null
  }

  return {
    open,
    inventory,
    ground,
    container,
    prompt,
    catalogue,
    config,
    identity,
    refusal,
    notice,
    customization,
    reloading,
    slotCount,
    maxWeight,
    weight,
    weightRatio,
    usedSlots,
    isEmpty,
    isGroundEmpty,
    containerUsedSlots,
    isContainerEmpty,
    containerWeightRatio,
    characterName,
    hotbarSlots,
    definitionOf,
    stackAt,
    hotbarAt,
    containerStackAt,
    notify,
    start,
    move,
    use,
    split,
    give,
    nearbyPlayers,
    close,
    openCustomization,
    fitComponent,
    clearComponent,
    closeCustomization,
    reload,
    closeReload,
  }
})
