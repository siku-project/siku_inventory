import { computed, ref } from 'vue'
import { useInventoryStore } from '@/stores/inventory'
import type { ContainerRef, ItemDefinition, ItemStack } from '@/types/inventory'

export type ItemAction = 'use' | 'customize' | 'split' | 'give' | 'drop' | 'inspect' | 'take'

export interface ActionTarget {
  ref: ContainerRef
  stack: ItemStack
  definition: ItemDefinition
}

export type DialogKind = 'quantity' | 'give' | 'inspect'

export interface QuantityIntent {
  purpose: 'drop' | 'split' | 'hotbar'
  target: ActionTarget
  hotbarIndex?: number
}

/**
 * Holds what the interface is currently asking the player about. Menus and
 * dialogs read from here rather than each keeping their own open flag, which
 * is what guarantees only one of them shows at a time.
 */
export const useItemActions = () => {
  const store = useInventoryStore()

  const dialog = ref<DialogKind | null>(null)
  const target = ref<ActionTarget | null>(null)
  const quantityIntent = ref<QuantityIntent | null>(null)

  /**
   * A stack can only be split when there is something to leave behind, and
   * splitting is a question about stacking rather than about identity: a kind
   * that never stacks has nothing to detach, and an instance carrying its own
   * identity is one object however its kind is declared.
   */
  const isSplittable = (candidate: ActionTarget): boolean =>
    candidate.definition.stackable && !candidate.stack.uid && candidate.stack.count > 1

  /** Only the actions the item can actually answer to, never a disabled row. */
  const actionsFor = (candidate: ActionTarget): ItemAction[] => {
    /** Searching somebody shows what they carry; taking it is not on offer. */
    if (candidate.ref.container === 'secondary' && store.container?.readOnly) {
      return ['inspect']
    }

    if (candidate.ref.container === 'ground' || candidate.ref.container === 'secondary') {
      return ['take', 'inspect']
    }

    if (candidate.ref.container === 'hotbar') {
      return []
    }

    const actions: ItemAction[] = []

    if (candidate.definition.usable) {
      actions.push('use')
    }

    /**
     * Only a weapon instance can be customized: the view is built around one
     * tracked object, and a stack of two would have no single thing to fit
     * components to.
     */
    if (candidate.definition.type === 'weapon' && candidate.stack.uid) {
      actions.push('customize')
    }

    if (isSplittable(candidate)) {
      actions.push('split')
    }

    actions.push('give', 'drop', 'inspect')

    return actions
  }

  const closeDialog = (): void => {
    dialog.value = null
    quantityIntent.value = null
  }

  const openInspect = (candidate: ActionTarget): void => {
    target.value = candidate
    dialog.value = 'inspect'
  }

  const openGive = (candidate: ActionTarget): void => {
    target.value = candidate
    dialog.value = 'give'
  }

  const openQuantity = (intent: QuantityIntent): void => {
    target.value = intent.target
    quantityIntent.value = intent
    dialog.value = 'quantity'
  }

  const run = async (action: ItemAction, candidate: ActionTarget): Promise<void> => {
    const slot = candidate.ref.slot ?? 0

    if (action === 'use') {
      await store.use(slot)

      return
    }

    if (action === 'inspect') {
      openInspect(candidate)

      return
    }

    if (action === 'give') {
      openGive(candidate)

      return
    }

    if (action === 'take') {
      await store.move(candidate.ref, { container: 'player' }, candidate.stack.count)

      return
    }

    if (action === 'split') {
      openQuantity({ purpose: 'split', target: candidate })

      return
    }

    if (action === 'customize') {
      await store.openCustomization(candidate.stack.uid ?? '')

      return
    }

    if (candidate.stack.count > 1) {
      openQuantity({ purpose: 'drop', target: candidate })

      return
    }

    /**
     * Named by container rather than by raw slot: a hotbar reference carries
     * an index, and the server is the side that knows what slot that stands
     * for. Passing the index as a slot would reach into the carried grid.
     */
    await store.move(candidate.ref, { container: 'ground' }, 1)
  }

  return {
    dialog: computed(() => dialog.value),
    target: computed(() => target.value),
    quantityIntent: computed(() => quantityIntent.value),
    actionsFor,
    run,
    openInspect,
    openGive,
    openQuantity,
    closeDialog,
  }
}
