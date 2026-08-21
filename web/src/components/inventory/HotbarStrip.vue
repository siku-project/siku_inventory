<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ItemSlot from '@/components/inventory/ItemSlot.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import type { ContainerRef, ItemStack } from '@/types/inventory'

const emit = defineEmits<{
  hover: [payload: { event: MouseEvent | null; stack?: ItemStack; reference?: ContainerRef }]
  activate: [index: number]
  dropOn: [index: number]
}>()

const { t } = useI18n()
const store = useInventoryStore()
const drag = useDragAndDrop()

const referenceOf = (index: number): ContainerRef => ({ container: 'hotbar', slot: index })
</script>

<template>
  <section class="hotbar">
    <header class="hotbar__head">
      <!-- Deliberately untranslated: the hotbar is called that in every language. -->
      <span class="sk-label hotbar__title">Hotbar</span>
      <span v-if="drag.isDragging.value" class="hotbar__hint">
        {{ t('inventory.hotbarEmpty') }}
      </span>
    </header>

    <div
      class="hotbar__row"
      :style="{ gridTemplateColumns: `repeat(${store.hotbarSlots.length}, minmax(0, 1fr))` }"
    >
      <ItemSlot
        v-for="cell in store.hotbarSlots"
        :key="cell.index"
        :reference="referenceOf(cell.index)"
        :stack="cell.stack"
        :definition="cell.stack ? store.definitionOf(cell.stack.item) : undefined"
        :badge="String(cell.index)"
        @activate="emit('activate', cell.index)"
        @drop="emit('dropOn', cell.index)"
        @hover="
          emit('hover', { event: $event, stack: cell.stack, reference: referenceOf(cell.index) })
        "
      />
    </div>
  </section>
</template>

<style scoped>
.hotbar {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.hotbar__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 14px;
}

.hotbar__title {
  color: var(--sk-text-muted);
}

.hotbar__hint {
  font-size: 11px;
  color: var(--sk-accent-text);
}

.hotbar__row {
  display: grid;
  gap: var(--sk-slot-gap);
}
</style>
