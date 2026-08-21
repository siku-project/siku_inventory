<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useItemLabel } from '@/composables/useItemLabel'
import { formatWeight } from '@/utils/weight'
import { metadataRows } from '@/utils/metadata'
import type { FloatingPlacement } from '@/composables/useFloating'
import type { ItemDefinition, ItemStack } from '@/types/inventory'

/** Two properties at most: the whole record belongs to the inspect panel. */
const PREVIEW_ROWS = 2

const props = defineProps<{
  stack: ItemStack
  definition: ItemDefinition
  placement: FloatingPlacement
}>()

const { t, te } = useI18n()
const { labelOf } = useItemLabel()

const label = computed(() => labelOf(props.definition))

const typeLabel = computed(() => {
  const key = `item.type.${props.definition.type}`

  return te(key) ? t(key) : props.definition.type
})

const facts = computed(() => {
  const rows = [
    { key: 'unit', label: t('item.unitWeight'), value: formatWeight(props.definition.weight) },
  ]

  if (props.stack.count > 1) {
    rows.push({ key: 'count', label: t('item.quantity'), value: String(props.stack.count) })
    rows.push({
      key: 'stack',
      label: t('item.stackWeight'),
      value: formatWeight(props.stack.weight),
    })
  }

  return rows
})

const properties = computed(() =>
  metadataRows(props.definition, props.stack.metadata, (key) => (te(key) ? t(key) : key)).slice(
    0,
    PREVIEW_ROWS,
  ),
)
</script>

<template>
  <div class="tip" :style="{ left: `${placement.left}px`, top: `${placement.top}px` }">
    <header class="tip__head">
      <span class="tip__art">
        <ItemArtwork :definition="definition" :label="label" />
      </span>

      <div class="tip__identity">
        <p class="tip__name">{{ label }}</p>

        <div class="tip__tags">
          <span class="tip__type">{{ typeLabel }}</span>
          <span v-if="definition.unique" class="tip__unique">{{ t('item.unique') }}</span>
        </div>
      </div>
    </header>

    <p v-if="definition.description" class="tip__description">{{ definition.description }}</p>

    <div class="sk-rule"></div>

    <dl class="tip__facts">
      <div v-for="fact in facts" :key="fact.key" class="tip__fact">
        <dt class="tip__key">{{ fact.label }}</dt>
        <dd class="tip__value sk-mono">{{ fact.value }}</dd>
      </div>
    </dl>

    <template v-if="properties.length > 0">
      <div class="sk-rule"></div>

      <dl class="tip__facts">
        <div v-for="property in properties" :key="property.key" class="tip__fact">
          <dt class="tip__key">{{ property.label }}</dt>
          <dd class="tip__value tip__value--frost sk-mono">{{ property.value }}</dd>
        </div>
      </dl>
    </template>
  </div>
</template>

<style scoped>
.tip {
  position: fixed;
  z-index: 70;
  display: flex;
  width: 286px;
  flex-direction: column;
  gap: 14px;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border);
  background: var(--sk-panel-modal);
  padding: 16px 18px;
  box-shadow: 0 30px 64px -30px rgba(0, 0, 0, 0.95);
  pointer-events: none;
}

.tip__head {
  display: flex;
  align-items: center;
  gap: 14px;
}

.tip__art {
  display: flex;
  height: 52px;
  width: 52px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-control);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.035);
  padding: 7px;
  font-size: 52px;
}

.tip__identity {
  min-width: 0;
}

.tip__name {
  margin: 0;
  font-size: 14.5px;
  font-weight: 600;
  letter-spacing: -0.005em;
  line-height: 1.3;
  color: var(--sk-text);
}

.tip__tags {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 6px;
}

.tip__type {
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--sk-text-soft);
}

.tip__unique {
  border-radius: 5px;
  border: 1px solid rgba(108, 182, 246, 0.3);
  background: var(--sk-accent-tint);
  padding: 2px 6px;
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--sk-accent-text);
}

.tip__description {
  margin: -2px 0 0;
  font-size: 12.2px;
  line-height: 1.55;
  color: var(--sk-text-muted);
}

.tip__facts {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin: 0;
}

.tip__fact {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 18px;
}

.tip__key {
  font-size: 11.5px;
  color: var(--sk-text-soft);
}

.tip__value {
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 12px;
  color: var(--sk-text-body);
}

.tip__value--frost {
  color: var(--sk-frost);
}
</style>
