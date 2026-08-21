<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ItemSlot from '@/components/inventory/ItemSlot.vue'
import WeightBar from '@/components/inventory/WeightBar.vue'
import HotbarStrip from '@/components/inventory/HotbarStrip.vue'
import { useInventoryStore } from '@/stores/inventory'
import type { ContainerRef, ItemStack } from '@/types/inventory'

const emit = defineEmits<{
  context: [payload: { event: MouseEvent; reference: ContainerRef; stack: ItemStack }]
  hover: [payload: { event: MouseEvent | null; stack?: ItemStack; reference?: ContainerRef }]
  activate: [slot: number]
  dropOn: [slot: number]
  hotbarActivate: [index: number]
  hotbarDrop: [index: number]
}>()

const { t } = useI18n()
const store = useInventoryStore()

const slots = computed(() =>
  Array.from({ length: store.slotCount }, (_, index) => {
    const slot = index + 1

    return { slot, stack: store.stackAt(slot) }
  }),
)

const referenceOf = (slot: number): ContainerRef => ({ container: 'player', slot })
</script>

<template>
  <section class="panel sk-panel">
    <header class="panel__head">
      <div class="panel__identity">
        <span class="sk-bar panel__accent"></span>

        <div class="panel__names">
          <p class="panel__name">{{ store.characterName || t('inventory.title') }}</p>
          <p class="sk-label panel__slots">
            {{ t('inventory.slots', { used: store.usedSlots, total: store.slotCount }) }}
          </p>
        </div>
      </div>

      <WeightBar :weight="store.weight" :max-weight="store.maxWeight" :ratio="store.weightRatio" />
    </header>

    <div class="sk-rule sk-rule--strong"></div>

    <div class="panel__body">
      <div class="panel__grid sk-scroll">
        <ItemSlot
          v-for="entry in slots"
          :key="entry.slot"
          :reference="referenceOf(entry.slot)"
          :stack="entry.stack"
          :definition="entry.stack ? store.definitionOf(entry.stack.item) : undefined"
          :index="entry.slot"
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

      <div v-if="store.isEmpty" class="panel__hint" aria-hidden="true">
        <div class="panel__plate">
          <v-icon class="sk-icon" size="26">mdi-bag-personal-outline</v-icon>
          <p class="panel__hintTitle">{{ t('inventory.empty') }}</p>
          <p class="panel__hintText">{{ t('inventory.emptyHint') }}</p>
        </div>
      </div>
    </div>

    <div class="sk-rule sk-rule--strong"></div>

    <footer class="panel__foot">
      <HotbarStrip
        @hover="emit('hover', $event)"
        @activate="emit('hotbarActivate', $event)"
        @drop-on="emit('hotbarDrop', $event)"
      />
    </footer>
  </section>
</template>

<style scoped>
/**
 * Five columns, whatever the slot count. The grid is what scrolls; the header
 * and the hotbar stay where the player left them.
 */
.panel {
  display: flex;
  height: var(--sk-panel-height);
  min-height: 0;
  flex-direction: column;
  width: calc(5 * var(--sk-slot) + 4 * var(--sk-slot-gap) + 2 * var(--sk-panel-pad));
}

.panel__head {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  gap: 22px;
  padding: 26px var(--sk-panel-pad) 22px;
}

.panel__identity {
  display: flex;
  align-items: center;
  gap: 16px;
  min-width: 0;
}

.panel__accent {
  height: 42px;
}

.panel__names {
  min-width: 0;
}

.panel__name {
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 21px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: var(--sk-text);
}

.panel__slots {
  margin: 6px 0 0;
  letter-spacing: 0.18em;
}

.panel__body {
  position: relative;
  display: flex;
  min-height: 0;
  flex: 1;
}

.panel__grid {
  display: grid;
  min-height: 0;
  flex: 1;
  align-content: start;
  gap: var(--sk-slot-gap);
  grid-template-columns: repeat(5, minmax(0, 1fr));
  overflow-y: auto;
  padding: 20px var(--sk-panel-pad);
}

.panel__hint {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.panel__plate {
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

.panel__hintTitle {
  margin: 4px 0 0;
  font-size: 14px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.panel__hintText {
  margin: 0;
  font-size: 12px;
  color: var(--sk-text-soft);
}

.panel__foot {
  flex-shrink: 0;
  padding: 20px var(--sk-panel-pad) 24px;
}
</style>
