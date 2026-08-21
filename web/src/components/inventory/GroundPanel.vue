<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ItemSlot from '@/components/inventory/ItemSlot.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import type { ContainerRef, GroundEntry, ItemStack } from '@/types/inventory'

const emit = defineEmits<{
  context: [payload: { event: MouseEvent; reference: ContainerRef; stack: ItemStack }]
  hover: [payload: { event: MouseEvent | null; stack?: ItemStack; reference?: ContainerRef }]
  activate: [entry: GroundEntry]
  dropLoose: []
}>()

const { t } = useI18n()
const store = useInventoryStore()
const drag = useDragAndDrop()

const referenceOf = (entry: GroundEntry): ContainerRef => ({
  container: 'ground',
  dropId: entry.dropId,
  slot: entry.slot,
})
</script>

<template>
  <section
    class="ground sk-panel"
    :class="{ 'ground--target': drag.isDragging.value }"
    v-drop="{ onDrop: () => emit('dropLoose') }"
  >
    <header class="ground__head">
      <div class="ground__identity">
        <v-icon class="sk-icon ground__glyph" size="19">mdi-map-marker-outline</v-icon>

        <div>
          <p class="ground__title">{{ t('inventory.ground') }}</p>
          <p class="sk-label ground__count">
            {{ t('inventory.groundCount', store.ground.length) }}
          </p>
        </div>
      </div>
    </header>

    <div class="sk-rule sk-rule--strong"></div>

    <div class="ground__body">
      <div v-if="!store.isGroundEmpty" class="ground__grid sk-scroll">
        <ItemSlot
          v-for="entry in store.ground"
          :key="`${entry.dropId}-${entry.slot}`"
          :reference="referenceOf(entry)"
          :stack="entry"
          :definition="store.definitionOf(entry.item)"
          @activate="emit('activate', entry)"
          @context="emit('context', { event: $event, reference: referenceOf(entry), stack: entry })"
          @hover="emit('hover', { event: $event, stack: entry, reference: referenceOf(entry) })"
        />
      </div>

      <div class="zone" :class="{ 'zone--tall': store.isGroundEmpty }">
        <v-icon class="sk-icon zone__glyph" :size="store.isGroundEmpty ? 30 : 18">
          {{ store.isGroundEmpty ? 'mdi-package-variant' : 'mdi-tray-arrow-down' }}
        </v-icon>
        <p v-if="store.isGroundEmpty" class="zone__title">{{ t('inventory.groundEmpty') }}</p>
        <p class="zone__hint">{{ t('inventory.groundDrop') }}</p>
      </div>
    </div>
  </section>
</template>

<style scoped>
/**
 * The ground is stable whatever it holds. A panel that grew and shrank with
 * the number of stacks made the whole screen move every time something was
 * picked up. It stops short of the inventory's full height, and the room it
 * gives up is what the two side actions sit in.
 */
.ground {
  display: flex;
  min-height: 0;
  flex: 1;
  flex-direction: column;
  width: calc(4 * var(--sk-slot) + 3 * var(--sk-slot-gap) + 2 * var(--sk-panel-pad));
  transition:
    border-color 0.16s ease,
    box-shadow 0.16s ease;
}

.ground--target {
  border-color: var(--sk-accent-border);
  box-shadow:
    var(--sk-shadow-panel),
    inset 0 0 0 1px rgba(108, 182, 246, 0.16);
}

.ground__head {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 26px var(--sk-panel-pad) 22px;
}

.ground__identity {
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
}

.ground__glyph {
  flex-shrink: 0;
}

.ground__title {
  margin: 0;
  font-size: 21px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: var(--sk-text);
}

.ground__count {
  margin: 6px 0 0;
  letter-spacing: 0.18em;
}

.ground__body {
  display: flex;
  min-height: 0;
  flex: 1;
  flex-direction: column;
  gap: 16px;
  padding: 20px var(--sk-panel-pad) 22px;
}

/**
 * Whatever room the stacks leave is the drop target itself, so the panel says
 * what can be done with it instead of just being tall and empty. It grows
 * when the floor is bare and shrinks to a strip when it fills up.
 */
.zone {
  display: flex;
  flex: 1 1 auto;
  min-height: 92px;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 7px;
  border-radius: var(--sk-radius-tile);
  border: 1px dashed rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.012);
  padding: 16px;
  text-align: center;
  transition:
    border-color 0.16s ease,
    background 0.16s ease;
}

.ground--target .zone {
  border-color: var(--sk-accent-border);
  background: var(--sk-accent-tint);
}

.zone__glyph {
  margin-bottom: 2px;
}

.zone:not(.zone--tall) {
  flex-direction: row;
  gap: 11px;
}

.zone:not(.zone--tall) .zone__glyph {
  margin-bottom: 0;
}

.ground--target .zone__glyph {
  color: var(--sk-accent-text);
}

.zone__title {
  margin: 0;
  font-size: 14px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.zone__hint {
  margin: 0;
  font-size: 11.5px;
  color: var(--sk-text-soft);
}

.zone--tall {
  gap: 9px;
}

.ground__grid {
  display: grid;
  min-height: 0;
  flex: 0 1 auto;
  align-content: start;
  gap: var(--sk-slot-gap);
  grid-template-columns: repeat(4, minmax(0, 1fr));
  overflow-y: auto;
}
</style>
