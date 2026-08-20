<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  views: string[]
  currentView: string
}>()

const emit = defineEmits<{
  selectView: [view: string]
}>()

const open = ref(false)
</script>

<template>
  <div class="fixed bottom-7 right-7 z-50">
    <button
      type="button"
      class="sk-panel flex h-12 w-12 items-center justify-center !rounded-full"
      @click="open = true"
    >
      <v-icon class="text-sk-soft" size="17">mdi-view-dashboard-outline</v-icon>
    </button>

    <v-dialog v-model="open" max-width="440">
      <div class="sk-panel px-7 py-7">
        <p class="sk-label mb-6 text-center">Interfaces</p>

        <div v-if="views.length > 0" class="flex flex-col gap-2.5">
          <button
            v-for="view in views"
            :key="view"
            type="button"
            class="sk-row flex items-center justify-between px-5 py-3.5 text-left"
            :class="{ 'sk-row--active': currentView === view }"
            @click="emit('selectView', currentView === view ? 'none' : view)"
          >
            <span
              class="text-sm font-medium"
              :class="currentView === view ? 'text-accent-text' : 'text-sk-body'"
            >
              {{ view }}
            </span>
            <v-icon v-if="currentView === view" class="text-accent" size="14">mdi-check</v-icon>
          </button>
        </div>

        <div v-else class="flex flex-col items-center gap-5 py-10">
          <v-icon class="text-sk-faint" size="36">mdi-monitor-off</v-icon>
          <span class="text-sm font-medium text-sk-muted">Aucune interface disponible</span>
          <span class="text-xs text-sk-faint">Crée-en une et enregistre-la ici</span>
        </div>
      </div>
    </v-dialog>
  </div>
</template>
