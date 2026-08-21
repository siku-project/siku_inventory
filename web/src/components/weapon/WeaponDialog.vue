<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import DialogShell from '@/components/inventory/DialogShell.vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import AttachmentRow from '@/components/weapon/AttachmentRow.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useItemLabel } from '@/composables/useItemLabel'
import { metadataRows } from '@/utils/metadata'
import { formatWeight } from '@/utils/weight'
import type { CustomizationState } from '@/types/weapon'

const props = defineProps<{
  state: CustomizationState
}>()

const emit = defineEmits<{
  close: []
}>()

const { t, te } = useI18n()
const store = useInventoryStore()
const { labelOf } = useItemLabel()

const weapon = computed(() => props.state.weapon)
const definition = computed(() => store.definitionOf(weapon.value.item))
const label = computed(() => labelOf(definition.value))

const categoryLabel = computed(() => {
  const key = `weapon.category.${definition.value.category}`

  return te(key) ? t(key) : t('item.type.weapon')
})

const facts = computed(() => {
  const rows = [
    { key: 'weight', label: t('item.unitWeight'), value: formatWeight(definition.value.weight) },
  ]

  if (weapon.value.ammoType) {
    rows.push({ key: 'ammo', label: t('item.meta.ammoType'), value: weapon.value.ammoType })
  }

  return rows
})

const properties = computed(() =>
  metadataRows(definition.value, weapon.value.metadata, (key) => (te(key) ? t(key) : key)),
)

/**
 * Only the slots worth showing: one the weapon takes a carried part for, or
 * one already holding something. A slot with nothing to offer is not an empty
 * box — it simply is not there.
 */
const rows = computed(() =>
  props.state.slots
    .map((slot) => ({
      slot,
      choices: props.state.available.filter((entry) => entry.componentSlot === slot.id),
      fitted: props.state.components[slot.id],
    }))
    .filter((row) => row.choices.length > 0 || row.fitted),
)

const fittedCount = computed(() => Object.keys(props.state.components).length)
</script>

<template>
  <DialogShell :title="t('dialog.customizeTitle')" :width="560" @close="emit('close')">
    <header class="weapon">
      <span class="weapon__art">
        <ItemArtwork :definition="definition" :label="label" />
      </span>

      <div class="weapon__text">
        <p class="weapon__name">{{ label }}</p>
        <p class="weapon__kind">{{ categoryLabel }} · {{ weapon.name }}</p>
      </div>
    </header>

    <section class="facts">
      <div v-for="fact in facts" :key="fact.key" class="facts__row">
        <span class="facts__key">{{ fact.label }}</span>
        <span class="facts__value sk-mono">{{ fact.value }}</span>
      </div>

      <div v-for="property in properties" :key="property.key" class="facts__row">
        <span class="facts__key">{{ property.label }}</span>
        <span class="facts__value facts__value--frost sk-mono">{{ property.value }}</span>
      </div>
    </section>

    <div class="sk-rule sk-rule--strong"></div>

    <section v-if="rows.length > 0" class="slots">
      <header class="slots__head">
        <span class="sk-label">{{ t('weapon.attachments') }}</span>
        <span class="slots__count sk-mono">{{ fittedCount }} / {{ rows.length }}</span>
      </header>

      <AttachmentRow
        v-for="row in rows"
        :key="row.slot.id"
        :attachment="row.slot"
        :choices="row.choices"
        :fitted="row.fitted"
        @pick="store.fitComponent(row.slot.id, $event)"
        @clear="store.clearComponent(row.slot.id)"
      />
    </section>

    <section v-else class="none">
      <v-icon class="sk-icon" size="24">mdi-toolbox-outline</v-icon>
      <p class="none__title">{{ t('weapon.nothingToFit') }}</p>
      <p class="none__hint">{{ t('weapon.nothingToFitHint') }}</p>
    </section>

    <template #actions>
      <button type="button" class="sk-btn sk-btn--primary" @click="emit('close')">
        {{ t('action.close') }}
      </button>
    </template>
  </DialogShell>
</template>

<style scoped>
.weapon {
  display: flex;
  align-items: center;
  gap: 18px;
}

.weapon__art {
  display: flex;
  height: 78px;
  width: 78px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.035);
  padding: 11px;
  font-size: 78px;
}

.weapon__text {
  min-width: 0;
}

.weapon__name {
  margin: 0;
  font-size: 19px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: var(--sk-text);
}

.weapon__kind {
  margin: 5px 0 0;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 11px;
  letter-spacing: 0.04em;
  color: var(--sk-text-soft);
}

.facts {
  display: flex;
  flex-direction: column;
  gap: 9px;
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

.slots {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.slots__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.slots__count {
  font-size: 12px;
  color: var(--sk-text-soft);
}

.none {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 22px 12px 14px;
  text-align: center;
}

.none__title {
  margin: 5px 0 0;
  font-size: 13px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.none__hint {
  margin: 0;
  max-width: 38ch;
  font-size: 11.5px;
  line-height: 1.5;
  color: var(--sk-text-soft);
}
</style>
