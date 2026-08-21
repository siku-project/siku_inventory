<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const emit = defineEmits<{
  open: [action: 'wardrobe']
}>()

const { t } = useI18n()

/**
 * Secondary entry points sitting above the ground, deliberately quiet: they
 * open what the inventory is not, and should never compete with the stacks
 * for attention. The feature behind this one does not exist yet.
 */
const ACTIONS = [{ id: 'wardrobe', icon: 'mdi-hanger', label: 'inventory.wardrobe' }] as const
</script>

<template>
  <nav class="actions">
    <button
      v-for="action in ACTIONS"
      :key="action.id"
      type="button"
      class="action"
      @click="emit('open', action.id)"
    >
      <v-icon class="action__glyph" size="18">{{ action.icon }}</v-icon>
      <span class="action__label">{{ t(action.label) }}</span>
    </button>
  </nav>
</template>

<style scoped>
/* Pushed to the right and sized to its own content: this opens what the
   inventory is not, and has no business claiming the width of the ground. */
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.action {
  display: flex;
  align-items: center;
  gap: 10px;
  border-radius: var(--sk-radius-control);
  border: 1px solid var(--sk-border-soft);
  background: var(--sk-surface);
  padding: 14px 28px;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    color 0.16s ease;
}

.action:hover {
  border-color: var(--sk-border-hover);
  background: var(--sk-surface-hover);
}

.action__glyph {
  color: var(--sk-text-soft);
  transition: color 0.16s ease;
}

.action:hover .action__glyph {
  color: var(--sk-accent-text);
}

.action__label {
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.04em;
  color: var(--sk-text-muted);
}

.action:hover .action__label {
  color: var(--sk-text-body);
}
</style>
