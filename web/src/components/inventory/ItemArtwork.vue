<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { itemImage } from '@/utils/itemImage'
import type { ItemDefinition } from '@/types/inventory'

const props = defineProps<{
  definition: ItemDefinition
  label: string
}>()

const broken = ref(false)

/** The definition names its file; a missing one falls back, never breaks. */
const source = computed(() => itemImage(props.definition.image))

const fallbackIcon = computed(() =>
  props.definition.type === 'weapon' ? 'mdi-pistol' : 'mdi-cube-outline',
)

watch(source, () => {
  broken.value = false
})
</script>

<template>
  <span class="art">
    <img
      v-if="source && !broken"
      class="art__image"
      :src="source"
      :alt="label"
      draggable="false"
      @error="broken = true"
    />

    <span v-else class="art__fallback">
      <v-icon class="art__glyph" size="52%">{{ fallbackIcon }}</v-icon>
      <span class="art__initial">{{ label.slice(0, 1).toUpperCase() }}</span>
    </span>
  </span>
</template>

<style scoped>
.art {
  display: flex;
  height: 100%;
  width: 100%;
  align-items: center;
  justify-content: center;
}

.art__image {
  max-height: 100%;
  max-width: 100%;
  object-fit: contain;
}

.art__fallback {
  position: relative;
  display: flex;
  height: 100%;
  width: 100%;
  align-items: center;
  justify-content: center;
}

.art__glyph {
  color: rgba(255, 255, 255, 0.16);
}

.art__initial {
  position: absolute;
  font-size: 0.42em;
  font-weight: 600;
  letter-spacing: 0.02em;
  line-height: 1;
  color: rgba(255, 255, 255, 0.52);
}
</style>
