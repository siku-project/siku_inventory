import { ref } from 'vue'

const MARGIN = 12

export interface FloatingPlacement {
  left: number
  top: number
}

/**
 * Places a floating element next to a point and keeps it inside the viewport.
 * Tooltips and context menus both need this, and both would otherwise clip on
 * the last row or the right-hand column.
 */
export const useFloating = () => {
  const placement = ref<FloatingPlacement>({ left: 0, top: 0 })

  const place = (
    anchor: { x: number; y: number },
    size: { width: number; height: number },
    offset = 14,
  ): FloatingPlacement => {
    const maxLeft = window.innerWidth - size.width - MARGIN
    const maxTop = window.innerHeight - size.height - MARGIN

    let left = anchor.x + offset
    let top = anchor.y + offset

    if (left > maxLeft) {
      left = anchor.x - size.width - offset
    }

    if (top > maxTop) {
      top = anchor.y - size.height - offset
    }

    placement.value = {
      left: Math.max(MARGIN, Math.min(left, Math.max(MARGIN, maxLeft))),
      top: Math.max(MARGIN, Math.min(top, Math.max(MARGIN, maxTop))),
    }

    return placement.value
  }

  return { placement, place }
}
