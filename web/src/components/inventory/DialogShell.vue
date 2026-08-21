<script setup lang="ts">
defineProps<{
  title: string
  hint?: string
  width?: number
}>()

const emit = defineEmits<{
  close: []
}>()
</script>

<template>
  <!--
    Escape is handled once, at the window level, where the interface knows
    what to close first. Answering it here as well closed the dialog on the
    way up and left the window handler seeing none, which then closed the
    whole inventory on the very same keypress.
  -->
  <div class="scrim" @click.self="emit('close')">
    <div class="dialog" :style="{ width: `${width ?? 400}px` }" role="dialog">
      <header class="dialog__head">
        <h2 class="dialog__title">{{ title }}</h2>
        <p v-if="hint" class="dialog__hint">{{ hint }}</p>
      </header>

      <div class="sk-rule"></div>

      <div class="dialog__body sk-scroll">
        <slot />
      </div>

      <div class="sk-rule"></div>

      <footer class="dialog__foot">
        <slot name="actions" />
      </footer>
    </div>
  </div>
</template>

<style scoped>
.scrim {
  position: fixed;
  inset: 0;
  z-index: 90;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(5, 6, 8, 0.72);
  animation: fade 0.16s ease;
}

.dialog {
  display: flex;
  max-width: calc(100vw - 32px);
  flex-direction: column;
  overflow: hidden;
  border-radius: var(--sk-radius-panel);
  border: 1px solid var(--sk-border);
  background: var(--sk-panel-modal);
  box-shadow: var(--sk-shadow-panel);
  animation: rise 0.2s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.dialog__head {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 18px 22px 15px;
}

.dialog__title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: -0.01em;
  color: rgba(255, 255, 255, 0.96);
}

.dialog__hint {
  margin: 0;
  font-size: 12px;
  color: var(--sk-text-soft);
}

.dialog__body {
  display: flex;
  max-height: 64vh;
  flex-direction: column;
  gap: 14px;
  overflow-y: auto;
  padding: 18px 22px;
}

.dialog__foot {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
  padding: 15px 22px 18px;
}

@keyframes fade {
  from {
    opacity: 0;
  }
}

@keyframes rise {
  from {
    opacity: 0;
    transform: translateY(10px) scale(0.985);
  }
}
</style>
