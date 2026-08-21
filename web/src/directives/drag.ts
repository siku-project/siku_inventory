import type { Directive } from 'vue'
import {
  bindSource,
  bindTarget,
  pressSource,
  type DragSource,
  type DropTarget,
} from '@/composables/useDragAndDrop'

/**
 * Makes an element something a player can pick up.
 *
 * ```vue
 * <div v-drag="{ reference, stack, definition }">
 * ```
 *
 * A press is not yet a drag: the gesture only becomes one once the pointer has
 * travelled, which is what leaves a click and a double click intact on the very
 * same element. Passing no stack leaves the element inert, so an empty slot
 * needs no condition of its own.
 */
export const vDrag: Directive<HTMLElement, DragSource | null | undefined> = {
  mounted(element, binding) {
    bindSource(element, binding.value ?? null)

    element.addEventListener('pointerdown', (event) => pressSource(element, event))
  },
  updated(element, binding) {
    bindSource(element, binding.value ?? null)
  },
  unmounted(element) {
    bindSource(element, null)
  },
}

/**
 * Makes an element somewhere a drag can land.
 *
 * ```vue
 * <div v-drop="{ reference, onDrop: () => emit('drop') }">
 * ```
 *
 * The zone says what it does where it is written, rather than in a registry
 * kept somewhere else. Naming a reference also makes it highlight while the
 * pointer is over it; a zone without one accepts drops without pretending to
 * be a slot.
 */
export const vDrop: Directive<HTMLElement, DropTarget | null | undefined> = {
  mounted(element, binding) {
    bindTarget(element, binding.value ?? null)
  },
  updated(element, binding) {
    bindTarget(element, binding.value ?? null)
  },
  unmounted(element) {
    bindTarget(element, null)
  },
}
