<script setup lang="ts">
import { computed } from 'vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import { useItemLabel } from '@/composables/useItemLabel'
import { formatCount } from '@/utils/weight'

/**
 * What the player is carrying between two slots.
 *
 * The browser draws nothing here — the gesture is followed by hand — so the
 * thing being moved has to be drawn too, or a drag is a slot going faint and
 * nothing else. It sits above everything and lets every pointer through, so
 * the zone underneath stays the one being asked about.
 */
const drag = useDragAndDrop()
const { labelOf } = useItemLabel()

const carried = computed(() => drag.dragging.value)
const label = computed(() => labelOf(carried.value?.definition))

const placement = computed(() => ({
  transform: `translate3d(${drag.position.value.x}px, ${drag.position.value.y}px, 0)`,
}))
</script>

<template>
  <Teleport to="body">
    <div v-if="carried" class="ghost" aria-hidden="true" :style="placement">
      <span v-if="carried.stack.count > 1" class="ghost__count">
        {{ formatCount(carried.stack.count) }}
      </span>

      <ItemArtwork :definition="carried.definition" :label="label" />
    </div>
  </Teleport>
</template>

<style scoped>
.ghost {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 400;
  display: flex;
  width: var(--sk-slot);
  height: var(--sk-slot);
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border-hover);
  background: var(--sk-surface-hover);
  box-shadow: 0 18px 40px rgba(0, 0, 0, 0.55);
  padding: 10px;
  pointer-events: none;
  /** Centred on the pointer, so what is carried sits where it is pointed. */
  margin: calc(var(--sk-slot) / -2) 0 0 calc(var(--sk-slot) / -2);
  will-change: transform;
}

.ghost__count {
  position: absolute;
  top: 6px;
  right: 8px;
  font-size: 11px;
  font-variant-numeric: tabular-nums;
  color: var(--sk-text-soft);
}
</style>
