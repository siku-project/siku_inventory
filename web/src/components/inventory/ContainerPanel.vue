<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ItemSlot from '@/components/inventory/ItemSlot.vue'
import WeightBar from '@/components/inventory/WeightBar.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useDragAndDrop } from '@/composables/useDragAndDrop'
import type { ContainerRef, ItemStack, SecondaryContainer } from '@/types/inventory'

const props = defineProps<{ container: SecondaryContainer }>()

const emit = defineEmits<{
  context: [payload: { event: MouseEvent; reference: ContainerRef; stack: ItemStack }]
  hover: [payload: { event: MouseEvent | null; stack?: ItemStack; reference?: ContainerRef }]
  activate: [slot: number]
  dropOn: [slot: number]
  dropLoose: []
}>()

const { t } = useI18n()
const store = useInventoryStore()
const drag = useDragAndDrop()

const slots = computed(() =>
  Array.from({ length: props.container.slots }, (_, index) => {
    const slot = index + 1

    return { slot, stack: store.containerStackAt(slot) }
  }),
)

const referenceOf = (slot: number): ContainerRef => ({ container: 'secondary', slot })
</script>

<template>
  <section
    class="box sk-panel"
    :class="{ 'box--target': drag.isDragging.value && !container.readOnly }"
    v-drop="{ onDrop: () => emit('dropLoose'), disabled: container.readOnly }"
  >
    <header class="box__head">
      <div class="box__identity">
        <v-icon class="sk-icon box__glyph" size="19">{{ container.icon }}</v-icon>

        <div class="box__names">
          <p class="box__title">{{ container.label }}</p>
          <p class="sk-label box__count">
            {{ t('inventory.slots', { used: store.containerUsedSlots, total: container.slots }) }}
          </p>
        </div>
      </div>

      <WeightBar
        :weight="container.weight"
        :max-weight="container.maxWeight"
        :ratio="store.containerWeightRatio"
      />
    </header>

    <div class="sk-rule sk-rule--strong"></div>

    <div class="box__body">
      <div class="box__grid sk-scroll">
        <ItemSlot
          v-for="entry in slots"
          :key="entry.slot"
          :reference="referenceOf(entry.slot)"
          :stack="entry.stack"
          :definition="entry.stack ? store.definitionOf(entry.stack.item) : undefined"
          :index="entry.slot"
          :readonly="container.readOnly"
          @activate="emit('activate', entry.slot)"
          @drop="emit('dropOn', entry.slot)"
          @context="
            entry.stack &&
            emit('context', {
              event: $event,
              reference: referenceOf(entry.slot),
              stack: entry.stack,
            })
          "
          @hover="
            emit('hover', { event: $event, stack: entry.stack, reference: referenceOf(entry.slot) })
          "
        />
      </div>

      <div v-if="store.isContainerEmpty" class="box__hint" aria-hidden="true">
        <div class="box__plate">
          <v-icon class="sk-icon" size="26">{{ container.icon }}</v-icon>
          <p class="box__hintTitle">{{ t('container.empty') }}</p>
          <p class="box__hintText">{{ t('container.emptyHint') }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
/**
 * The second panel is the bag's twin, one column narrower: same header, same
 * weight gauge, same grid. Whatever opens it — a locker, a trunk, a shop
 * reserve — the player is looking at the same thing they already know.
 */
.box {
  display: flex;
  height: var(--sk-panel-height);
  min-height: 0;
  flex-direction: column;
  width: calc(4 * var(--sk-slot) + 3 * var(--sk-slot-gap) + 2 * var(--sk-panel-pad));
  transition:
    border-color 0.16s ease,
    box-shadow 0.16s ease;
}

.box--target {
  border-color: var(--sk-accent-border);
  box-shadow:
    var(--sk-shadow-panel),
    inset 0 0 0 1px rgba(108, 182, 246, 0.16);
}

.box__head {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  gap: 22px;
  padding: 26px var(--sk-panel-pad) 22px;
}

.box__identity {
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
}

.box__glyph {
  flex-shrink: 0;
}

.box__names {
  min-width: 0;
}

.box__title {
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 21px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: var(--sk-text);
}

.box__count {
  margin: 6px 0 0;
  letter-spacing: 0.18em;
}

.box__body {
  position: relative;
  display: flex;
  min-height: 0;
  flex: 1;
}

.box__grid {
  display: grid;
  min-height: 0;
  flex: 1;
  align-content: start;
  gap: var(--sk-slot-gap);
  grid-template-columns: repeat(4, minmax(0, 1fr));
  overflow-y: auto;
  padding: 20px var(--sk-panel-pad) 24px;
}

.box__hint {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.box__plate {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 9px;
  border-radius: var(--sk-radius-panel);
  border: 1px solid var(--sk-border-soft);
  background: rgba(11, 12, 14, 0.95);
  padding: 24px 34px;
  text-align: center;
  box-shadow: 0 24px 50px -26px rgba(0, 0, 0, 0.9);
}

.box__hintTitle {
  margin: 4px 0 0;
  font-size: 14px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.box__hintText {
  margin: 0;
  font-size: 12px;
  color: var(--sk-text-soft);
}
</style>
