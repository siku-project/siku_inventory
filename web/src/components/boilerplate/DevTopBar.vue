<script setup lang="ts">
const resourceName = 'siku_inventory'
const framework = 'Vue 3'
const isDev = import.meta.env.DEV
</script>

<template>
  <div class="fixed left-1/2 top-7 z-50 -translate-x-1/2">
    <div class="sk-panel flex items-center gap-6 px-7 py-3.5">
      <span class="sk-label">{{ resourceName }}</span>

      <span class="h-4 w-px bg-white/[0.08]"></span>

      <span class="text-xs font-medium text-sk-soft">{{ framework }}</span>

      <span class="h-4 w-px bg-white/[0.08]"></span>

      <span
        class="flex items-center gap-2.5 text-[10px] font-semibold uppercase tracking-[0.16em]"
        :class="isDev ? 'text-accent-text' : 'text-sk'"
      >
        <span
          class="h-1.5 w-1.5 rounded-full"
          :class="isDev ? 'bg-accent shadow-glow' : 'bg-white/70'"
        ></span>
        {{ isDev ? 'Dev' : 'Prod' }}
      </span>
    </div>
  </div>
</template>
