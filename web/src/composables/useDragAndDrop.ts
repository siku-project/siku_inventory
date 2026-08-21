import { computed, ref } from 'vue'
import type { ContainerRef, DragPayload, ItemDefinition, ItemStack } from '@/types/inventory'

const dragging = ref<DragPayload | null>(null)
const hovered = ref<string | null>(null)

/** The container has to be part of the key: hotbar 1 is not carried slot 1. */
const keyOf = (ref: ContainerRef): string =>
  ref.container === 'ground'
    ? `ground:${ref.dropId ?? 'loose'}:${ref.slot ?? 0}`
    : `${ref.container}:${ref.slot ?? 0}`

/**
 * One drag at a time, shared by every slot. Keeping it module-level rather
 * than per-component is what lets a slot know it is a valid target without
 * the grid having to thread the payload down.
 */
export const useDragAndDrop = () => {
  const begin = (ref: ContainerRef, stack: ItemStack, definition: ItemDefinition): void => {
    dragging.value = { ref, stack, definition }
  }

  const end = (): void => {
    dragging.value = null
    hovered.value = null
  }

  const enter = (ref: ContainerRef): void => {
    hovered.value = keyOf(ref)
  }

  const leave = (ref: ContainerRef): void => {
    if (hovered.value === keyOf(ref)) {
      hovered.value = null
    }
  }

  const isSource = (ref: ContainerRef): boolean =>
    dragging.value !== null && keyOf(dragging.value.ref) === keyOf(ref)

  const isHovered = (ref: ContainerRef): boolean => hovered.value === keyOf(ref)

  return {
    dragging: computed(() => dragging.value),
    isDragging: computed(() => dragging.value !== null),
    begin,
    end,
    enter,
    leave,
    isSource,
    isHovered,
  }
}
