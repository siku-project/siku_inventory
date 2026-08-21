<script setup lang="ts">
import { defineAsyncComponent } from 'vue'
import InventoryView from './views/InventoryView.vue'
import InteractionPrompt from './components/inventory/InteractionPrompt.vue'
import { useInventoryStore } from './stores/inventory'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null

const store = useInventoryStore()
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <InventoryView v-else />

    <Transition name="prompt">
      <InteractionPrompt v-if="store.prompt && !store.open" :prompt="store.prompt" />
    </Transition>
  </VApp>
</template>

<style scoped>
.prompt-enter-active,
.prompt-leave-active {
  transition:
    opacity 0.16s ease,
    transform 0.16s ease;
}

.prompt-enter-from,
.prompt-leave-to {
  opacity: 0;
  transform: translate(-50%, 6px);
}
</style>
