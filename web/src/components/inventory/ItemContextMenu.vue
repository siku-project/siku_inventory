<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { FloatingPlacement } from '@/composables/useFloating'
import type { ItemAction } from '@/composables/useItemActions'

defineProps<{
  actions: ItemAction[]
  placement: FloatingPlacement
}>()

const emit = defineEmits<{
  pick: [action: ItemAction]
}>()

const { t } = useI18n()

const ICONS: Record<ItemAction, string> = {
  use: 'mdi-hand-back-right-outline',
  customize: 'mdi-tools',
  split: 'mdi-call-split',
  give: 'mdi-account-arrow-right-outline',
  drop: 'mdi-tray-arrow-down',
  inspect: 'mdi-information-outline',
  take: 'mdi-tray-arrow-up',
}
</script>

<template>
  <div class="menu" :style="{ left: `${placement.left}px`, top: `${placement.top}px` }">
    <button
      v-for="action in actions"
      :key="action"
      type="button"
      class="menu__row"
      :class="{ 'menu__row--danger': action === 'drop' }"
      @click="emit('pick', action)"
    >
      <v-icon size="15">{{ ICONS[action] }}</v-icon>
      <span>{{ t(`action.${action}`) }}</span>
    </button>
  </div>
</template>

<style scoped>
.menu {
  position: fixed;
  z-index: 80;
  display: flex;
  min-width: 172px;
  flex-direction: column;
  gap: 1px;
  border-radius: 11px;
  border: 1px solid var(--sk-border);
  background: var(--sk-panel-modal);
  padding: 5px;
  box-shadow: 0 28px 60px -28px rgba(0, 0, 0, 0.95);
}

.menu__row {
  display: flex;
  align-items: center;
  gap: 10px;
  border-radius: 7px;
  padding: 9px 11px;
  text-align: left;
  font-size: 12.6px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.78);
  transition:
    background 0.16s ease,
    color 0.16s ease;
}

.menu__row:hover {
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.96);
}

.menu__row--danger:hover {
  background: rgba(248, 113, 113, 0.12);
  color: rgba(252, 165, 165, 0.95);
}
</style>
