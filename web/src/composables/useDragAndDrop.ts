import { computed, readonly, ref } from 'vue'
import type { ContainerRef, DragPayload, ItemDefinition, ItemStack } from '@/types/inventory'

/** How far the pointer travels before a press becomes a drag rather than a click. */
const THRESHOLD = 4

/** What a slot offers when it is picked up. */
export interface DragSource {
  reference: ContainerRef
  stack?: ItemStack
  definition?: ItemDefinition
}

/** What a zone does when something lands on it. */
export interface DropTarget {
  reference?: ContainerRef
  onDrop: () => void
  disabled?: boolean
}

const sources = new WeakMap<HTMLElement, DragSource>()
const targets = new WeakMap<HTMLElement, DropTarget>()

const dragging = ref<DragPayload | null>(null)
const hovered = ref<string | null>(null)
const position = ref({ x: 0, y: 0 })

let pending: { payload: DragPayload; x: number; y: number } | null = null

/** The container has to be part of the key: hotbar 1 is not carried slot 1. */
export const keyOf = (reference: ContainerRef): string =>
  reference.container === 'ground'
    ? `ground:${reference.dropId ?? 'loose'}:${reference.slot ?? 0}`
    : `${reference.container}:${reference.slot ?? 0}`

/**
 * The zone under the pointer, and what it does.
 *
 * Asked of the document rather than of each zone: the pointer is what carries
 * the drag, so what lies beneath it is the one question that stays true
 * wherever it travels. Walking up from the deepest element lets a slot sit
 * inside a panel that is itself a zone.
 */
const targetUnder = (x: number, y: number): { element: HTMLElement; target: DropTarget } | null => {
  let element = document.elementFromPoint(x, y)

  while (element instanceof HTMLElement) {
    const target = targets.get(element)

    if (target && !target.disabled) {
      return { element, target }
    }

    element = element.parentElement
  }

  return null
}

const release = (): void => {
  pending = null
  dragging.value = null
  hovered.value = null
  document.body.classList.remove('is-dragging')
}

const onPointerMove = (event: PointerEvent): void => {
  if (pending) {
    const travelled = Math.abs(event.clientX - pending.x) + Math.abs(event.clientY - pending.y)

    if (travelled < THRESHOLD) {
      return
    }

    dragging.value = pending.payload
    pending = null
    document.body.classList.add('is-dragging')
  }

  if (!dragging.value) {
    return
  }

  position.value = { x: event.clientX, y: event.clientY }

  const found = targetUnder(event.clientX, event.clientY)

  hovered.value = found?.target.reference ? keyOf(found.target.reference) : null
}

const onPointerUp = (event: PointerEvent): void => {
  if (!dragging.value) {
    return release()
  }

  const found = targetUnder(event.clientX, event.clientY)

  /**
   * The drag is still live while the zone is told: a zone reads what is being
   * carried before it does anything with it, and clearing first would hand it
   * an empty hand every time. Releasing after covers the zones that do not.
   */
  found?.target.onDrop()
  release()
}

const onKeyDown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape') {
    release()
  }
}

window.addEventListener('pointermove', onPointerMove)
window.addEventListener('pointerup', onPointerUp)
window.addEventListener('pointercancel', release)
window.addEventListener('keydown', onKeyDown)

/**
 * Registers a slot as something that can be picked up. Used by `v-drag`.
 * @internal
 */
export const bindSource = (element: HTMLElement, source: DragSource | null): void => {
  if (source) {
    sources.set(element, source)
  } else {
    sources.delete(element)
  }
}

/**
 * Registers a zone as somewhere a drag can land. Used by `v-drop`.
 * @internal
 */
export const bindTarget = (element: HTMLElement, target: DropTarget | null): void => {
  if (target) {
    targets.set(element, target)
  } else {
    targets.delete(element)
  }
}

/**
 * Starts a press that may become a drag. Used by `v-drag`.
 * @internal
 */
export const pressSource = (element: HTMLElement, event: PointerEvent): void => {
  const source = sources.get(element)

  if (event.button !== 0 || !source?.stack || !source.definition) {
    return
  }

  pending = {
    payload: { ref: source.reference, stack: source.stack, definition: source.definition },
    x: event.clientX,
    y: event.clientY,
  }

  position.value = { x: event.clientX, y: event.clientY }
}

/**
 * One drag at a time, shared by every slot. Kept module-level rather than
 * per-component so a slot knows it is the source or the target without the
 * grid threading the payload down to it.
 *
 * Driven by the pointer rather than by the browser's own drag and drop: this
 * interface runs in a game overlay that fires `dragstart` without ever running
 * a drag — nothing follows the cursor, and no drop ever lands. So the gesture
 * is followed here, and the ghost is drawn by `DragGhost`.
 */
export const useDragAndDrop = () => {
  const isSource = (reference: ContainerRef): boolean =>
    dragging.value !== null && keyOf(dragging.value.ref) === keyOf(reference)

  const isHovered = (reference: ContainerRef): boolean => hovered.value === keyOf(reference)

  return {
    dragging: computed(() => dragging.value),
    isDragging: computed(() => dragging.value !== null),
    position: readonly(position),
    end: release,
    isSource,
    isHovered,
  }
}
