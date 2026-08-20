<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Component } from 'vue'
import DevTopBar from '@/components/boilerplate/DevTopBar.vue'
import DevFab from '@/components/boilerplate/DevFab.vue'
import DevViewSelector from '@/components/boilerplate/DevViewSelector.vue'
import InventoryView from '@/views/InventoryView.vue'

const viewComponents: Record<string, Component> = {
  Inventaire: InventoryView,
}

const views: string[] = Object.keys(viewComponents)
const currentView = ref('none')

const activeComponent = computed<Component | null>(() =>
  currentView.value !== 'none' ? (viewComponents[currentView.value] ?? null) : null,
)

const handleSelectView = (view: string) => {
  currentView.value = view
}
</script>

<template>
  <div
    class="fixed inset-0 h-full w-full bg-gray-900 bg-[url('/boilerplate-background.jpg')] bg-contain bg-center bg-no-repeat transition-all duration-300 md:bg-cover"
  >
    <component :is="activeComponent" v-if="activeComponent" />

    <DevTopBar />
    <DevFab :current-view="currentView" />
    <DevViewSelector :views="views" :current-view="currentView" @select-view="handleSelectView" />
  </div>
</template>
