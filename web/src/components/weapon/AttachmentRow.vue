<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useItemLabel } from '@/composables/useItemLabel'
import type { AvailableComponent, WeaponSlot } from '@/types/weapon'

const props = defineProps<{
  attachment: WeaponSlot
  /** The carried components that belong in this slot. */
  choices: AvailableComponent[]
  /** What is fitted right now, if anything. */
  fitted?: string
}>()

const emit = defineEmits<{
  pick: [item: string]
  clear: []
}>()

const { t } = useI18n()
const store = useInventoryStore()
const { labelOf } = useItemLabel()

const options = computed(() =>
  props.choices.map((choice) => ({
    item: choice.item,
    definition: store.definitionOf(choice.item),
    label: labelOf(store.definitionOf(choice.item)),
    chosen: props.fitted === choice.item,
  })),
)
</script>

<template>
  <section class="row">
    <header class="row__head">
      <span class="sk-label row__name">{{ t(attachment.label) }}</span>
      <span v-if="fitted" class="row__state">{{ t('weapon.installed') }}</span>
    </header>

    <!--
      One button per part the player owns for this slot, plus a way out.
      Selecting is the whole interaction: no dragging, no target to miss.
    -->
    <div class="row__options">
      <button
        v-for="option in options"
        :key="option.item"
        type="button"
        class="option"
        :class="{ 'option--chosen': option.chosen }"
        @click="option.chosen ? emit('clear') : emit('pick', option.item)"
      >
        <span class="option__art">
          <ItemArtwork :definition="option.definition" :label="option.label" />
        </span>

        <span class="option__label">{{ option.label }}</span>

        <v-icon v-if="option.chosen" class="option__mark" size="14">mdi-check</v-icon>
      </button>

      <button
        type="button"
        class="option option--none"
        :class="{ 'option--chosen': !fitted }"
        @click="emit('clear')"
      >
        <span class="option__label">{{ t('weapon.none') }}</span>
        <v-icon v-if="!fitted" class="option__mark" size="14">mdi-check</v-icon>
      </button>
    </div>
  </section>
</template>

<style scoped>
.row {
  display: flex;
  flex-direction: column;
  gap: 11px;
}

.row__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 14px;
}

.row__name {
  color: var(--sk-text-muted);
}

.row__state {
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--sk-accent-text);
}

.row__options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.option {
  position: relative;
  display: flex;
  align-items: center;
  gap: 10px;
  border-radius: var(--sk-radius-row);
  border: 1px solid var(--sk-border-soft);
  background: var(--sk-surface);
  padding: 9px 14px 9px 10px;
  transition:
    border-color 0.16s ease,
    background 0.16s ease,
    color 0.16s ease;
}

.option:hover:not(.option--chosen) {
  border-color: var(--sk-border-hover);
  background: var(--sk-surface-hover);
}

.option--chosen {
  border-color: var(--sk-accent-border);
  background: var(--sk-accent-tint);
}

.option__art {
  display: flex;
  height: 30px;
  width: 30px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  font-size: 30px;
}

.option__label {
  font-size: 12.5px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.option--chosen .option__label {
  color: var(--sk-frost);
}

.option__mark {
  color: var(--sk-accent);
}

/** The way out sits at the end of the row, plainer than the parts. */
.option--none {
  padding-left: 14px;
  background: transparent;
}

.option--none .option__label {
  color: var(--sk-text-soft);
}

.option--none.option--chosen .option__label {
  color: var(--sk-accent-text);
}
</style>
