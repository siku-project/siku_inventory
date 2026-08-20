<script setup lang="ts">
import { ref, version as vueVersion } from 'vue'
import axios from 'axios'

defineProps<{
  currentView: string
}>()

const expanded = ref(false)

const resourceName = 'siku_inventory'

const deps = [
  { name: 'Vue', version: vueVersion },
  { name: 'Vuetify', version: '4.x' },
  { name: 'Pinia', version: '4.x' },
  { name: 'Axios', version: axios.VERSION ?? '1.x' },
  { name: 'Tailwind', version: '3.x' },
]
</script>

<template>
  <div
    class="fixed right-7 top-7 z-50"
    @mouseenter="expanded = true"
    @mouseleave="expanded = false"
  >
    <div
      class="sk-panel overflow-hidden transition-all duration-300 ease-out"
      :class="expanded ? 'w-64' : 'h-12 w-12 !rounded-full'"
    >
      <div v-if="!expanded" class="flex h-12 w-12 items-center justify-center">
        <v-icon class="text-sk-soft" size="17">mdi-code-tags</v-icon>
      </div>

      <div v-else class="flex flex-col gap-4 p-6">
        <span class="sk-label text-center">{{ resourceName }}</span>

        <div class="sk-rule w-full"></div>

        <div class="flex flex-col gap-2.5">
          <div v-for="dep in deps" :key="dep.name" class="flex items-center justify-between">
            <span class="text-xs font-medium text-sk-soft">{{ dep.name }}</span>
            <span class="sk-mono text-[11px] text-sk-body">{{ dep.version }}</span>
          </div>
        </div>

        <div class="sk-rule w-full"></div>

        <div class="flex items-center justify-between">
          <span class="text-xs font-medium text-sk-soft">View</span>
          <span
            class="text-xs font-medium"
            :class="currentView !== 'none' ? 'text-accent-text' : 'text-sk-faint'"
          >
            {{ currentView !== 'none' ? currentView : 'None' }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
