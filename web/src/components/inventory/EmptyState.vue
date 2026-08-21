<script setup lang="ts">
defineProps<{
  icon: string
  title: string
  hint?: string
}>()
</script>

<template>
  <div class="empty">
    <span class="empty__icon">
      <v-icon size="26">{{ icon }}</v-icon>
    </span>
    <p class="empty__title">{{ title }}</p>
    <p v-if="hint" class="empty__hint">{{ hint }}</p>
  </div>
</template>

<style scoped>
.empty {
  display: flex;
  flex: 1;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 40px 20px;
  text-align: center;
}

.empty__icon {
  display: flex;
  height: 46px;
  width: 46px;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.02);
  color: var(--sk-text-faint);
}

.empty__title {
  margin: 0;
  font-size: 13.5px;
  font-weight: 500;
  color: var(--sk-text-muted);
}

.empty__hint {
  margin: 0;
  max-width: 30ch;
  font-size: 11.8px;
  color: var(--sk-text-faint);
}
</style>
