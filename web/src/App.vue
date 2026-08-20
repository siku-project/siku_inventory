<script setup lang="ts">
import { defineAsyncComponent } from 'vue'
import InventoryView from './views/InventoryView.vue'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <InventoryView v-else />
  </VApp>
</template>
