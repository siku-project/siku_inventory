<script setup lang="ts">
import { computed } from 'vue'
import { formatWeight, formatWeightValue } from '@/utils/weight'

const props = defineProps<{
  weight: number
  maxWeight: number
  ratio: number
}>()

const percent = computed(() => `${Math.min(100, Math.round(props.ratio * 100))}%`)
const isTight = computed(() => props.ratio >= 0.85)
const isFull = computed(() => props.ratio >= 1)
</script>

<template>
  <div class="bar">
    <p class="bar__value sk-mono">
      <span class="bar__used" :class="{ 'bar__used--tight': isTight }">
        {{ formatWeightValue(weight, maxWeight) }}
      </span>
      <span class="bar__max">/ {{ formatWeight(maxWeight) }}</span>
    </p>

    <div class="bar__track">
      <span
        class="bar__fill"
        :class="{ 'bar__fill--tight': isTight, 'bar__fill--full': isFull }"
        :style="{ width: percent }"
      >
        <span class="bar__edge" aria-hidden="true"></span>
      </span>
    </div>
  </div>
</template>

<style scoped>
/** The track spans the header; the reading sits above it, hard right. */
.bar {
  display: flex;
  flex-direction: column;
  gap: 9px;
}

.bar__value {
  display: flex;
  align-items: baseline;
  justify-content: flex-end;
  gap: 7px;
  margin: 0;
  font-size: 13px;
  letter-spacing: 0.01em;
}

.bar__used {
  font-size: 17px;
  font-weight: 600;
  color: var(--sk-text);
}

.bar__used--tight {
  color: #e6bd85;
}

.bar__max {
  color: var(--sk-text-soft);
}

.bar__track {
  position: relative;
  height: 7px;
  width: 100%;
  overflow: hidden;
  border-radius: 9999px;
  background: rgba(255, 255, 255, 0.07);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.04);
}

.bar__fill {
  position: absolute;
  inset: 0 auto 0 0;
  border-radius: 9999px;
  background: linear-gradient(90deg, rgba(108, 182, 246, 0.55) 0%, var(--sk-accent) 100%);
  transition:
    width 0.28s cubic-bezier(0.22, 0.6, 0.2, 1),
    background 0.2s ease;
}

/** The leading edge reads as frost catching the light, not as a glow. */
.bar__edge {
  position: absolute;
  inset: 0 0 0 auto;
  width: 24px;
  border-radius: 9999px;
  background: linear-gradient(90deg, transparent 0%, var(--sk-frost) 100%);
  opacity: 0.85;
}

.bar__fill--tight {
  background: linear-gradient(90deg, rgba(213, 164, 95, 0.5) 0%, #d5a45f 100%);
}

.bar__fill--full {
  background: linear-gradient(90deg, rgba(248, 113, 113, 0.5) 0%, #f87171 100%);
}
</style>
