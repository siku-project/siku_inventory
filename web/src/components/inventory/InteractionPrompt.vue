<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { InteractionPrompt } from '@/types/inventory'

defineProps<{ prompt: InteractionPrompt }>()

const { t } = useI18n()
</script>

<template>
  <div class="hint">
    <kbd class="hint__key">{{ prompt.key }}</kbd>

    <span class="hint__text">
      <span class="hint__verb">{{ t('prompt.open') }}</span>
      <span class="hint__label">{{ prompt.label }}</span>
    </span>
  </div>
</template>

<style scoped>
/**
 * The one thing this interface draws over the world rather than instead of
 * it. It sits low and off to the side, where a subtitle would: something the
 * player reads without looking away from what they walked up to.
 */
.hint {
  position: fixed;
  bottom: 13vh;
  left: 50%;
  display: flex;
  align-items: center;
  gap: 12px;
  transform: translateX(-50%);
  border-radius: var(--sk-radius-control);
  border: 1px solid var(--sk-border);
  background: var(--sk-panel-modal);
  padding: 10px 18px 10px 11px;
  pointer-events: none;
  user-select: none;
}

.hint__key {
  display: flex;
  min-width: 28px;
  height: 28px;
  align-items: center;
  justify-content: center;
  border-radius: 7px;
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.05);
  padding: 0 8px;
  font-family: inherit;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.04em;
  color: var(--sk-text);
  text-transform: uppercase;
}

.hint__text {
  display: flex;
  align-items: baseline;
  gap: 6px;
  font-size: 13px;
}

.hint__verb {
  color: var(--sk-text-soft);
}

.hint__label {
  font-weight: 500;
  color: var(--sk-text-body);
}
</style>
