<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import InventoryPanel from '@/components/inventory/InventoryPanel.vue'
import GroundPanel from '@/components/inventory/GroundPanel.vue'
import GroundActions from '@/components/inventory/GroundActions.vue'
import ContainerPanel from '@/components/inventory/ContainerPanel.vue'
import ItemTooltip from '@/components/inventory/ItemTooltip.vue'
import ItemContextMenu from '@/components/inventory/ItemContextMenu.vue'
import QuantityDialog from '@/components/inventory/QuantityDialog.vue'
import GiveDialog from '@/components/inventory/GiveDialog.vue'
import InspectDialog from '@/components/inventory/InspectDialog.vue'
import WeaponDialog from '@/components/weapon/WeaponDialog.vue'
import ReloadDialog from '@/components/weapon/ReloadDialog.vue'
import DragGhost from '@/components/inventory/DragGhost.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import { useFloating } from '@/composables/useFloating'
import { useItemActions, type ActionTarget, type ItemAction } from '@/composables/useItemActions'
import type { ContainerRef, GroundEntry, ItemStack } from '@/types/inventory'

const TOOLTIP_SIZE = { width: 286, height: 300 }
const MENU_ROW = 38
const MENU_SIZE = { width: 176, height: 4 * MENU_ROW + 10 }

const { t, te } = useI18n()
const store = useInventoryStore()
const drag = useDragAndDrop()
const actions = useItemActions()

const tooltip = ref<ActionTarget | null>(null)
const tooltipPlacement = useFloating()
const menu = ref<ActionTarget | null>(null)
const menuPlacement = useFloating()
const menuActions = ref<ItemAction[]>([])

const toast = computed(() => {
  if (store.refusal) {
    const key = `error.${store.refusal}`

    return { tone: 'refusal', text: te(key) ? t(key) : t('error.refused') }
  }

  if (store.notice) {
    return { tone: 'notice', text: te(store.notice) ? t(store.notice) : store.notice }
  }

  return null
})

const targetOf = (reference: ContainerRef, stack: ItemStack): ActionTarget => ({
  ref: reference,
  stack,
  definition: store.definitionOf(stack.item),
})

const closeMenu = (): void => {
  menu.value = null
}

const showTooltip = (payload: {
  event: MouseEvent | null
  stack?: ItemStack
  reference?: ContainerRef
}): void => {
  if (!payload.event || !payload.stack || drag.isDragging.value || menu.value) {
    tooltip.value = null

    return
  }

  tooltip.value = targetOf(payload.reference ?? { container: 'player' }, payload.stack)
  tooltipPlacement.place({ x: payload.event.clientX, y: payload.event.clientY }, TOOLTIP_SIZE)
}

const openMenu = (payload: {
  event: MouseEvent
  reference: ContainerRef
  stack: ItemStack
}): void => {
  const candidate = targetOf(payload.reference, payload.stack)
  const offered = actions.actionsFor(candidate)

  tooltip.value = null

  if (offered.length === 0) {
    closeMenu()

    return
  }

  menu.value = candidate
  menuActions.value = offered
  menuPlacement.place({ x: payload.event.clientX, y: payload.event.clientY }, MENU_SIZE, 2)
}

const pickAction = async (action: ItemAction): Promise<void> => {
  const candidate = menu.value

  closeMenu()

  if (candidate) {
    await actions.run(action, candidate)
  }
}

/** Double-click moves a stack to the other side, the fastest common gesture. */
const activatePlayerSlot = async (slot: number): Promise<void> => {
  const stack = store.stackAt(slot)

  if (!stack) {
    return
  }

  /**
   * The other side is whatever the panel beside the bag is showing. Storing
   * a whole stack away is never a loss, so it goes without asking; leaving it
   * on the ground still does.
   */
  if (store.container && !store.container.readOnly) {
    await store.move({ container: 'player', slot }, { container: 'secondary' }, stack.count)

    return
  }

  if (stack.count > 1) {
    actions.openQuantity({
      purpose: 'drop',
      target: targetOf({ container: 'player', slot }, stack),
    })

    return
  }

  await store.move({ container: 'player', slot }, { container: 'ground' }, 1)
}

/** Nothing leaves or enters a container that may only be looked at. */
const isSealed = (): boolean => store.container?.readOnly === true

const activateContainerSlot = async (slot: number): Promise<void> => {
  const stack = store.containerStackAt(slot)

  if (!stack || isSealed()) {
    return
  }

  await store.move({ container: 'secondary', slot }, { container: 'player' }, stack.count)
}

const dropOnContainerSlot = async (slot: number): Promise<void> => {
  const payload = drag.dragging.value

  drag.end()

  if (!payload || payload.ref.container === 'ground' || isSealed()) {
    return
  }

  await store.move(payload.ref, { container: 'secondary', slot }, payload.stack.count)
}

const dropOnContainer = async (): Promise<void> => {
  const payload = drag.dragging.value

  drag.end()

  if (!payload || payload.ref.container === 'ground' || payload.ref.container === 'secondary') {
    return
  }

  if (isSealed()) {
    return
  }

  await store.move(payload.ref, { container: 'secondary' }, payload.stack.count)
}

const activateGroundEntry = async (entry: GroundEntry): Promise<void> => {
  await store.move(
    { container: 'ground', dropId: entry.dropId, slot: entry.slot },
    { container: 'player' },
    entry.count,
  )
}

/** Double-click on a hotbar cell sends the whole stack back to the grid. */
const activateHotbarSlot = async (index: number): Promise<void> => {
  const stack = store.hotbarAt(index)

  if (!stack) {
    return
  }

  await store.move({ container: 'hotbar', slot: index }, { container: 'player' }, stack.count)
}

const dropOnPlayerSlot = async (slot: number): Promise<void> => {
  const payload = drag.dragging.value

  drag.end()

  if (!payload) {
    return
  }

  await store.move(payload.ref, { container: 'player', slot }, payload.stack.count)
}

/**
 * Dropping onto a hotbar cell asks how much to keep at hand when there is
 * more than one to choose from, and goes straight through otherwise.
 */
const dropOnHotbar = async (index: number): Promise<void> => {
  const payload = drag.dragging.value

  drag.end()

  if (!payload || payload.ref.container === 'ground' || payload.ref.container === 'secondary') {
    return
  }

  if (payload.ref.container === 'hotbar') {
    if (payload.ref.slot !== index) {
      await store.move(payload.ref, { container: 'hotbar', slot: index }, payload.stack.count)
    }

    return
  }

  if (payload.stack.count > 1) {
    actions.openQuantity({
      purpose: 'hotbar',
      target: targetOf(payload.ref, payload.stack),
      hotbarIndex: index,
    })

    return
  }

  await store.move(payload.ref, { container: 'hotbar', slot: index }, 1)
}

/**
 * Leaving something on the ground asks how much, exactly like the context
 * menu does. Dropping a whole stack because the gesture happened to be a drag
 * was the one place a quantity could not be chosen.
 */
const dropOnGround = async (): Promise<void> => {
  const payload = drag.dragging.value

  drag.end()

  if (!payload || payload.ref.container === 'ground' || payload.ref.slot === undefined) {
    return
  }

  if (payload.stack.count > 1) {
    actions.openQuantity({ purpose: 'drop', target: targetOf(payload.ref, payload.stack) })

    return
  }

  await store.move(payload.ref, { container: 'ground' }, 1)
}

/** The feature behind it lives elsewhere; the entry point exists now. */
const openSide = (action: 'wardrobe'): void => {
  store.notify(`soon.${action}`)
}

const confirmQuantity = async (count: number): Promise<void> => {
  const intent = actions.quantityIntent.value

  actions.closeDialog()

  if (!intent) {
    return
  }

  if (intent.purpose === 'hotbar' && intent.hotbarIndex !== undefined) {
    await store.move(intent.target.ref, { container: 'hotbar', slot: intent.hotbarIndex }, count)

    return
  }

  if (intent.purpose === 'drop') {
    await store.move(intent.target.ref, { container: 'ground' }, count)

    return
  }

  const slot = intent.target.ref.slot

  if (slot !== undefined) {
    await store.split(slot, count)
  }
}

const confirmGive = async (payload: { count: number; target: number }): Promise<void> => {
  const candidate = actions.target.value

  actions.closeDialog()

  if (candidate && candidate.ref.slot !== undefined) {
    await store.give(candidate.ref.slot, payload.count, payload.target)
  }
}

const onKeydown = (event: KeyboardEvent): void => {
  if (event.key !== 'Escape') {
    return
  }

  /** The weapon panels sit over everything, so they are what Escape closes. */
  if (store.reloading) {
    store.closeReload()

    return
  }

  if (store.customization) {
    void store.closeCustomization(true)

    return
  }

  if (actions.dialog.value) {
    actions.closeDialog()

    return
  }

  if (menu.value) {
    closeMenu()

    return
  }

  void store.close()
}

/**
 * A state push means the stack under the cursor may no longer exist, so the
 * hover surfaces are dropped rather than left describing a vanished item.
 */
watch([() => store.inventory, () => store.ground, () => store.container], () => {
  tooltip.value = null
  closeMenu()
})

/**
 * A press is not a drag: the tooltip only has to go once the browser actually
 * starts one. Watching the shared drag state covers every source at once —
 * the carried grid, the hotbar and the ground all begin their drags here.
 */
watch(drag.isDragging, (dragging) => {
  if (dragging) {
    tooltip.value = null
    closeMenu()
  }
})

onMounted(async () => {
  window.addEventListener('keydown', onKeydown)
  window.addEventListener('mousedown', closeMenu)
  await nextTick()
  await store.start()
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeydown)
  window.removeEventListener('mousedown', closeMenu)
})
</script>

<template>
  <Transition name="screen">
    <div v-if="store.open" class="screen">
      <div class="screen__veil" aria-hidden="true"></div>

      <div class="screen__layout">
        <InventoryPanel
          @context="openMenu"
          @hover="showTooltip"
          @activate="activatePlayerSlot"
          @drop-on="dropOnPlayerSlot"
          @hotbar-activate="activateHotbarSlot"
          @hotbar-drop="dropOnHotbar"
        />

        <div class="screen__gap" v-drop="{ onDrop: dropOnGround }"></div>

        <div class="screen__side">
          <ContainerPanel
            v-if="store.container"
            :container="store.container"
            @context="openMenu"
            @hover="showTooltip"
            @activate="activateContainerSlot"
            @drop-on="dropOnContainerSlot"
            @drop-loose="dropOnContainer"
          />

          <template v-else>
            <GroundActions @open="openSide" />

            <GroundPanel
              @context="openMenu"
              @hover="showTooltip"
              @activate="activateGroundEntry"
              @drop-loose="dropOnGround"
            />
          </template>
        </div>
      </div>

      <DragGhost />

      <Transition name="fade">
        <ItemTooltip
          v-if="tooltip"
          :stack="tooltip.stack"
          :definition="tooltip.definition"
          :placement="tooltipPlacement.placement.value"
        />
      </Transition>

      <Transition name="fade">
        <ItemContextMenu
          v-if="menu"
          :actions="menuActions"
          :placement="menuPlacement.placement.value"
          @pick="pickAction"
          @mousedown.stop
        />
      </Transition>

      <Transition name="fade">
        <div v-if="toast" class="toast" :class="`toast--${toast.tone}`">
          <v-icon class="sk-icon toast__glyph" size="15">
            {{ toast.tone === 'refusal' ? 'mdi-alert-circle-outline' : 'mdi-information-outline' }}
          </v-icon>
          {{ toast.text }}
        </div>
      </Transition>

      <QuantityDialog
        v-if="actions.dialog.value === 'quantity' && actions.target.value"
        :stack="actions.target.value.stack"
        :definition="actions.target.value.definition"
        :purpose="actions.quantityIntent.value?.purpose ?? 'drop'"
        @confirm="confirmQuantity"
        @close="actions.closeDialog()"
      />

      <GiveDialog
        v-if="actions.dialog.value === 'give' && actions.target.value"
        :stack="actions.target.value.stack"
        :definition="actions.target.value.definition"
        @confirm="confirmGive"
        @close="actions.closeDialog()"
      />

      <InspectDialog
        v-if="actions.dialog.value === 'inspect' && actions.target.value"
        :stack="actions.target.value.stack"
        :definition="actions.target.value.definition"
        @close="actions.closeDialog()"
      />

      <WeaponDialog
        v-if="store.customization"
        :state="store.customization"
        @close="store.closeCustomization(true)"
      />

      <ReloadDialog v-if="store.reloading" :state="store.reloading" @close="store.closeReload()" />
    </div>
  </Transition>
</template>

<style scoped>
.screen {
  position: fixed;
  inset: 0;
  overflow: hidden;
  user-select: none;
}

.screen__veil {
  position: absolute;
  inset: 0;
  background: radial-gradient(120% 90% at 50% 50%, rgba(6, 7, 9, 0.6) 0%, rgba(6, 7, 9, 0.86) 100%);
}

.screen__layout {
  position: relative;
  display: flex;
  height: 100%;
  align-items: center;
  justify-content: center;
  padding: 40px 48px;
}

/** The side column matches the inventory; the ground fills what is left. */
.screen__side {
  display: flex;
  height: var(--sk-panel-height);
  min-height: 0;
  flex-direction: column;
  gap: 13px;
}

.screen__gap {
  flex: 1;
  align-self: stretch;
  min-width: 48px;
}

.toast {
  position: fixed;
  bottom: 34px;
  left: 50%;
  display: flex;
  align-items: center;
  gap: 9px;
  transform: translateX(-50%);
  border-radius: var(--sk-radius-control);
  border: 1px solid var(--sk-border);
  background: var(--sk-panel-modal);
  padding: 11px 20px;
  font-size: 12.5px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.toast--refusal {
  border-color: rgba(248, 113, 113, 0.35);
  background: rgba(30, 16, 18, 0.94);
  color: rgba(252, 165, 165, 0.96);
}

.toast--refusal .toast__glyph {
  color: rgba(248, 113, 113, 0.8);
}

.toast--notice .toast__glyph {
  color: var(--sk-accent-text);
}

.screen-enter-active,
.screen-leave-active {
  transition: opacity 0.18s ease;
}

.screen-enter-from,
.screen-leave-to {
  opacity: 0;
}

.screen-enter-active :deep(.sk-panel),
.screen-leave-active :deep(.sk-panel) {
  transition: transform 0.22s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.screen-enter-from :deep(.sk-panel) {
  transform: translateY(12px) scale(0.99);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.14s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
