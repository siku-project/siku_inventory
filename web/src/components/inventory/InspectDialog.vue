<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import DialogShell from '@/components/inventory/DialogShell.vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useItemLabel } from '@/composables/useItemLabel'
import { formatWeight } from '@/utils/weight'
import { metadataRows } from '@/utils/metadata'
import type { ItemDefinition, ItemStack } from '@/types/inventory'

const props = defineProps<{
  stack: ItemStack
  definition: ItemDefinition
}>()

const emit = defineEmits<{
  close: []
}>()

const { t, te } = useI18n()
const { labelOf } = useItemLabel()

const label = computed(() => labelOf(props.definition))

const typeLabel = computed(() => {
  const key = `item.type.${props.definition.type}`

  return te(key) ? t(key) : props.definition.type
})

/**
 * Rendered from what the server chose to expose and from how the definition
 * asked for it to be read. An item growing a new public property shows it
 * without a change here.
 */
const properties = computed(() =>
  metadataRows(props.definition, props.stack.metadata, (key) => (te(key) ? t(key) : key)),
)

const facts = computed(() => {
  const rows = [
    { key: 'unit', label: t('item.unitWeight'), value: formatWeight(props.definition.weight) },
    { key: 'quantity', label: t('item.quantity'), value: String(props.stack.count) },
  ]

  if (props.stack.count > 1) {
    rows.push({
      key: 'stack',
      label: t('item.stackWeight'),
      value: formatWeight(props.stack.weight),
    })
  }

  return rows
})
</script>

<template>
  <DialogShell :title="t('dialog.inspectTitle')" :width="500" @close="emit('close')">
    <div class="head">
      <span class="head__art">
        <ItemArtwork :definition="definition" :label="label" />
      </span>

      <div class="head__text">
        <p class="head__name">{{ label }}</p>

        <div class="head__tags">
          <span class="head__type">{{ typeLabel }}</span>
          <span v-if="definition.unique" class="head__badge">{{ t('item.unique') }}</span>
        </div>

        <p v-if="definition.description" class="head__description">{{ definition.description }}</p>
      </div>
    </div>

    <section class="section">
      <span class="section__label">{{ t('inventory.weight') }}</span>

      <div class="facts">
        <div v-for="fact in facts" :key="fact.key" class="facts__row">
          <span class="facts__key">{{ fact.label }}</span>
          <span class="facts__value sk-mono">{{ fact.value }}</span>
        </div>
      </div>
    </section>

    <section class="section">
      <span class="section__label">{{ t('dialog.properties') }}</span>

      <div v-if="properties.length > 0" class="facts">
        <div v-for="property in properties" :key="property.key" class="facts__row">
          <span class="facts__key">{{ property.label }}</span>
          <span class="facts__value facts__value--frost sk-mono">{{ property.value }}</span>
        </div>
      </div>

      <p v-else class="section__empty">{{ t('dialog.noProperties') }}</p>
    </section>

    <template #actions>
      <button type="button" class="sk-btn sk-btn--ghost" @click="emit('close')">
        {{ t('action.cancel') }}
      </button>
    </template>
  </DialogShell>
</template>

<style scoped>
.head {
  display: flex;
  gap: 20px;
}

.head__art {
  display: flex;
  height: 92px;
  width: 92px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.035);
  padding: 12px;
  font-size: 92px;
}

.head__text {
  display: flex;
  min-width: 0;
  flex-direction: column;
  justify-content: center;
  gap: 8px;
}

.head__name {
  margin: 0;
  font-size: 19px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: var(--sk-text);
}

.head__tags {
  display: flex;
  align-items: center;
  gap: 10px;
}

.head__type {
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--sk-text-soft);
}

.head__badge {
  border-radius: 5px;
  border: 1px solid rgba(108, 182, 246, 0.32);
  background: var(--sk-accent-tint);
  padding: 2px 8px;
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--sk-accent-text);
}

.head__description {
  margin: 2px 0 0;
  font-size: 12.4px;
  line-height: 1.55;
  color: var(--sk-text-muted);
}

.section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  border-top: 1px solid var(--sk-rule);
  padding-top: 18px;
}

.section__label {
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--sk-text-soft);
}

.section__empty {
  margin: 0;
  font-size: 12.2px;
  color: var(--sk-text-soft);
}

.facts {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.facts__row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 20px;
}

.facts__key {
  font-size: 12px;
  color: var(--sk-text-muted);
}

.facts__value {
  overflow-wrap: anywhere;
  text-align: right;
  font-size: 12.5px;
  color: var(--sk-text-body);
}

.facts__value--frost {
  color: var(--sk-frost);
}
</style>
