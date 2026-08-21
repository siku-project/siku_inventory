<script setup lang="ts">
import { computed } from 'vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import { useItemLabel } from '@/composables/useItemLabel'
import { formatCount, formatWeight } from '@/utils/weight'
import type { ContainerRef, ItemDefinition, ItemStack } from '@/types/inventory'

const props = defineProps<{
  reference: ContainerRef
  stack?: ItemStack
  definition?: ItemDefinition
  index?: number
  badge?: string
  /** Shows what is there and refuses every gesture that would move it. */
  readonly?: boolean
}>()

const emit = defineEmits<{
  activate: []
  context: [event: MouseEvent]
  hover: [event: MouseEvent | null]
  drop: []
}>()

const drag = useDragAndDrop()
const { labelOf } = useItemLabel()

const filled = computed(() => Boolean(props.stack && props.definition))
const label = computed(() => labelOf(props.definition))

/**
 * A tool shows what it has left rather than what it weighs: how many uses
 * remain is the number a player actually acts on.
 */
const footNote = computed(() => {
  const stack = props.stack

  if (!stack) {
    return ''
  }

  if (stack.uses !== undefined && stack.maxUses !== undefined) {
    return `${stack.uses} / ${stack.maxUses}`
  }

  return formatWeight(stack.weight)
})

const isSource = computed(() => drag.isSource(props.reference))
const isTargeted = computed(() => drag.isDragging.value && drag.isHovered(props.reference))

const onDragStart = (event: DragEvent): void => {
  if (!props.stack || !props.definition || props.readonly) {
    event.preventDefault()

    return
  }

  event.dataTransfer?.setData('text/plain', String(props.stack.slot))

  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move'
  }

  drag.begin(props.reference, props.stack, props.definition)
}

const onDragOver = (event: DragEvent): void => {
  if (!drag.isDragging.value || props.readonly) {
    return
  }

  event.preventDefault()
  drag.enter(props.reference)
}
</script>

<template>
  <div
    class="slot"
    :class="{
      'slot--filled': filled,
      'slot--source': isSource,
      'slot--target': isTargeted,
    }"
    :draggable="filled && !readonly"
    :title="filled ? label : undefined"
    role="button"
    tabindex="0"
    @dragstart="onDragStart"
    @dragend="drag.end()"
    @dragover="onDragOver"
    @dragleave="drag.leave(reference)"
    @drop.prevent="!readonly && emit('drop')"
    @dblclick="!readonly && emit('activate')"
    @contextmenu.prevent="emit('context', $event)"
    @mouseenter="emit('hover', $event)"
    @mousemove="emit('hover', $event)"
    @mouseleave="emit('hover', null)"
    @keydown.enter.prevent="emit('activate')"
  >
    <span v-if="badge" class="slot__badge" :class="{ 'slot__badge--lit': filled }">
      {{ badge }}
    </span>
    <span v-else-if="index !== undefined && !filled" class="slot__index">{{ index }}</span>

    <template v-if="filled && stack && definition">
      <span v-if="definition.unique" class="slot__unique" aria-hidden="true"></span>
      <span v-if="stack.count > 1" class="slot__count">{{ formatCount(stack.count) }}</span>

      <span class="slot__art">
        <ItemArtwork :definition="definition" :label="label" />
      </span>

      <span class="slot__foot">
        <span class="slot__label">{{ label }}</span>
        <span class="slot__weight sk-mono">{{ footNote }}</span>
      </span>

      <span v-if="stack.freshness !== undefined" class="slot__decay" aria-hidden="true">
        <span
          class="slot__decayFill"
          :class="{ 'slot__decayFill--low': stack.freshness <= 0.25 }"
          :style="{ width: `${Math.round(stack.freshness * 100)}%` }"
        ></span>
      </span>
    </template>
  </div>
</template>

<style scoped>
/**
 * The height is set rather than derived from an aspect ratio: a grid item
 * stretches to its row by default, and a row sized from a ratio that depends
 * on that same stretch collapses to the content height.
 */
.slot {
  position: relative;
  display: flex;
  height: var(--sk-slot);
  flex-direction: column;
  align-items: stretch;
  justify-content: center;
  overflow: hidden;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.022);
  padding: 10px;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    box-shadow 0.16s ease;
  user-select: none;
}

.slot--filled {
  background: var(--sk-surface);
  cursor: grab;
}

.slot--filled:hover {
  border-color: var(--sk-border-hover);
  background: var(--sk-surface-hover);
  box-shadow: inset 0 1px 0 0 rgba(255, 255, 255, 0.05);
}

.slot--filled:active {
  cursor: grabbing;
}

.slot--source {
  opacity: 0.3;
}

.slot--target {
  border-color: var(--sk-accent-border);
  background: var(--sk-accent-tint);
  box-shadow: inset 0 0 0 1px rgba(108, 182, 246, 0.22);
}

.slot__index {
  position: absolute;
  left: 9px;
  top: 7px;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 10px;
  font-variant-numeric: tabular-nums;
  color: rgba(255, 255, 255, 0.13);
}

.slot__badge {
  position: absolute;
  left: 9px;
  top: 7px;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 10.5px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.28);
}

.slot__badge--lit {
  color: var(--sk-accent-text);
}

.slot__art {
  display: flex;
  height: 54%;
  width: 100%;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
  font-size: calc(var(--sk-slot) * 0.54);
}

.slot__foot {
  display: flex;
  min-width: 0;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding-top: 7px;
}

.slot__label {
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11.6px;
  font-weight: 500;
  line-height: 1.25;
  color: rgba(255, 255, 255, 0.88);
}

.slot__weight {
  font-size: 10px;
  color: var(--sk-text-soft);
}

.slot__count {
  position: absolute;
  right: 7px;
  top: 6px;
  z-index: 1;
  border-radius: 6px;
  background: rgba(6, 8, 11, 0.78);
  padding: 2px 6px;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 11px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
  line-height: 1.3;
  color: var(--sk-frost);
}

/** A thread of a gauge along the bottom edge: readable, never loud. */
.slot__decay {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 2px;
  width: 100%;
  background: rgba(255, 255, 255, 0.06);
}

.slot__decayFill {
  display: block;
  height: 100%;
  background: var(--sk-frost-soft);
  transition: width 0.28s ease;
}

.slot__decayFill--low {
  background: rgba(213, 164, 95, 0.85);
}

.slot__unique {
  position: absolute;
  bottom: 8px;
  right: 8px;
  height: 4px;
  width: 4px;
  border-radius: 9999px;
  background: var(--sk-accent);
  box-shadow: 0 0 8px var(--sk-accent-glow);
}
</style>
