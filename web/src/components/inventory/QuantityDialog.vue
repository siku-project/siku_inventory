<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import DialogShell from '@/components/inventory/DialogShell.vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useItemLabel } from '@/composables/useItemLabel'
import { formatWeight } from '@/utils/weight'
import type { ItemDefinition, ItemStack } from '@/types/inventory'

type Purpose = 'drop' | 'split' | 'hotbar'

const TITLES: Record<Purpose, string> = {
  drop: 'dialog.dropTitle',
  split: 'dialog.splitTitle',
  hotbar: 'dialog.hotbarTitle',
}

const HINTS: Record<Purpose, string> = {
  drop: 'dialog.quantityHint',
  split: 'dialog.splitHint',
  hotbar: 'dialog.hotbarHint',
}

const CONFIRMS: Record<Purpose, string> = {
  drop: 'action.dropConfirm',
  split: 'action.split',
  hotbar: 'action.confirm',
}

const props = defineProps<{
  stack: ItemStack
  definition: ItemDefinition
  purpose: Purpose
}>()

const emit = defineEmits<{
  confirm: [count: number]
  close: []
}>()

const { t } = useI18n()
const { labelOf } = useItemLabel()

const label = computed(() => labelOf(props.definition))

/**
 * Splitting the whole stack would only move it, so the last unit has to stay
 * behind. Every other intent may take everything.
 */
const max = computed(() =>
  props.purpose === 'split' ? Math.max(1, props.stack.count - 1) : props.stack.count,
)

const clamp = (value: number): number => Math.max(1, Math.min(max.value, Math.round(value) || 1))

const amount = ref(1)

watch(
  () => props.stack,
  () => {
    amount.value = 1
  },
)

watch(max, () => {
  amount.value = clamp(amount.value)
})

const title = computed(() => t(TITLES[props.purpose], { item: label.value }))
const hint = computed(() => t(HINTS[props.purpose]))
const confirmLabel = computed(() => t(CONFIRMS[props.purpose]))

const fill = computed(() => `${((amount.value - 1) / Math.max(1, max.value - 1)) * 100}%`)
const weightPreview = computed(() => formatWeight(props.definition.weight * amount.value))

const step = (delta: number): void => {
  amount.value = clamp(amount.value + delta)
}
</script>

<template>
  <DialogShell :title="title" :hint="hint" :width="404" @close="emit('close')">
    <div class="item">
      <span class="item__art">
        <ItemArtwork :definition="definition" :label="label" />
      </span>

      <div class="item__text">
        <p class="item__name">{{ label }}</p>
        <p class="item__held">{{ t('item.held', { count: stack.count }) }}</p>
      </div>
    </div>

    <div class="tally">
      <span class="tally__amount sk-mono">{{ amount }}</span>
      <span class="tally__max sk-mono">/ {{ max }}</span>
    </div>

    <input
      v-model.number="amount"
      class="range"
      type="range"
      min="1"
      step="1"
      :max="max"
      :aria-label="hint"
      :style="{ '--fill': fill }"
    />

    <div class="controls">
      <button
        type="button"
        class="sk-btn sk-btn--ghost step"
        :disabled="amount <= 1"
        :aria-label="`-1`"
        @click="step(-1)"
      >
        <v-icon size="15">mdi-minus</v-icon>
      </button>

      <input
        :value="amount"
        class="sk-field field sk-mono"
        inputmode="numeric"
        @input="amount = clamp(Number(($event.target as HTMLInputElement).value))"
      />

      <button
        type="button"
        class="sk-btn sk-btn--ghost step"
        :disabled="amount >= max"
        :aria-label="`+1`"
        @click="step(1)"
      >
        <v-icon size="15">mdi-plus</v-icon>
      </button>

      <button type="button" class="sk-btn sk-btn--ghost max" @click="amount = max">
        {{ t('dialog.max') }}
      </button>
    </div>

    <div class="preview">
      <span class="preview__key">{{ t('item.stackWeight') }}</span>
      <span class="preview__value sk-mono">{{ weightPreview }}</span>
    </div>

    <template #actions>
      <button type="button" class="sk-btn sk-btn--ghost" @click="emit('close')">
        {{ t('action.cancel') }}
      </button>
      <button type="button" class="sk-btn sk-btn--primary" @click="emit('confirm', clamp(amount))">
        {{ confirmLabel }}
      </button>
    </template>
  </DialogShell>
</template>

<style scoped>
.item {
  display: flex;
  align-items: center;
  gap: 14px;
}

.item__art {
  display: flex;
  height: 54px;
  width: 54px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-control);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.035);
  padding: 8px;
  font-size: 54px;
}

.item__text {
  min-width: 0;
}

.item__name {
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 14.5px;
  font-weight: 600;
  color: var(--sk-text);
}

.item__held {
  margin: 4px 0 0;
  font-size: 11.5px;
  color: var(--sk-text-soft);
}

.tally {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 8px;
  border-top: 1px solid var(--sk-rule);
  padding-top: 18px;
}

.tally__amount {
  font-size: 32px;
  font-weight: 600;
  letter-spacing: -0.02em;
  line-height: 1;
  color: var(--sk-text);
}

.tally__max {
  font-size: 15px;
  color: var(--sk-text-soft);
}

.range {
  width: 100%;
  height: 4px;
  appearance: none;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    var(--sk-accent) 0%,
    var(--sk-accent) var(--fill, 0%),
    rgba(255, 255, 255, 0.1) var(--fill, 0%)
  );
  cursor: pointer;
}

.range::-webkit-slider-thumb {
  appearance: none;
  height: 13px;
  width: 13px;
  border-radius: 9999px;
  background: var(--sk-frost);
  box-shadow: 0 0 0 3px rgba(108, 182, 246, 0.28);
  cursor: grab;
}

.controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.step {
  flex-shrink: 0;
  padding: 10px 12px;
}

.field {
  min-width: 0;
  flex: 1;
  text-align: center;
}

.max {
  flex-shrink: 0;
  padding: 10px 16px;
  font-size: 11px;
}

.preview {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.preview__key {
  font-size: 11.5px;
  color: var(--sk-text-soft);
}

.preview__value {
  font-size: 12px;
  color: var(--sk-text-body);
}
</style>
