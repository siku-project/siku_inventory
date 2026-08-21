<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useItemLabel } from '@/composables/useItemLabel'
import DialogShell from '@/components/inventory/DialogShell.vue'
import EmptyState from '@/components/inventory/EmptyState.vue'
import { useInventoryStore } from '@/stores/inventory'
import type { ItemDefinition, ItemStack, NearbyPlayer } from '@/types/inventory'

const props = defineProps<{
  stack: ItemStack
  definition: ItemDefinition
}>()

const emit = defineEmits<{
  confirm: [payload: { count: number; target: number }]
  close: []
}>()

const { t } = useI18n()
const store = useInventoryStore()

const players = ref<NearbyPlayer[]>([])
const selected = ref<number | null>(null)
const amount = ref(1)
const loading = ref(true)

const max = computed(() => props.stack.count)

const { labelOf } = useItemLabel()

const label = computed(() => labelOf(props.definition))

const clamp = (value: number): number => Math.max(1, Math.min(max.value, Math.round(value) || 1))

const canConfirm = computed(() => selected.value !== null && amount.value >= 1)

onMounted(async () => {
  players.value = await store.nearbyPlayers()
  selected.value = players.value[0]?.id ?? null
  loading.value = false
})
</script>

<template>
  <DialogShell
    :title="t('dialog.giveTitle', { item: label })"
    :hint="t('dialog.giveHint')"
    :width="420"
    @close="emit('close')"
  >
    <EmptyState
      v-if="!loading && players.length === 0"
      icon="mdi-account-off-outline"
      :title="t('dialog.noPlayers')"
      :hint="t('dialog.noPlayersHint')"
    />

    <template v-else>
      <div class="players sk-scroll">
        <button
          v-for="player in players"
          :key="player.id"
          type="button"
          class="sk-row player"
          :class="{ 'sk-row--active': selected === player.id }"
          @click="selected = player.id"
        >
          <span class="player__name">{{ player.name }}</span>
          <span class="player__distance">{{ player.distance.toFixed(1) }} m</span>
        </button>
      </div>

      <div v-if="max > 1" class="quantity">
        <span class="quantity__label">{{ t('item.quantity') }}</span>
        <div class="quantity__controls">
          <input
            :value="amount"
            class="sk-field quantity__field"
            inputmode="numeric"
            @input="amount = clamp(Number(($event.target as HTMLInputElement).value))"
          />
          <button type="button" class="sk-btn sk-btn--ghost quantity__max" @click="amount = max">
            {{ t('dialog.max') }}
          </button>
        </div>
      </div>
    </template>

    <template #actions>
      <button type="button" class="sk-btn sk-btn--ghost" @click="emit('close')">
        {{ t('action.cancel') }}
      </button>
      <button
        type="button"
        class="sk-btn sk-btn--primary"
        :disabled="!canConfirm"
        @click="selected !== null && emit('confirm', { count: clamp(amount), target: selected })"
      >
        {{ t('action.give') }}
      </button>
    </template>
  </DialogShell>
</template>

<style scoped>
.players {
  display: flex;
  max-height: 210px;
  flex-direction: column;
  gap: 6px;
  overflow-y: auto;
  padding-right: 4px;
}

.player {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 11px 14px;
  text-align: left;
}

.player__name {
  font-size: 13px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.88);
}

.player__distance {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 10.5px;
  font-variant-numeric: tabular-nums;
  color: var(--sk-text-soft);
}

.quantity {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.quantity__label {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--sk-text-soft);
}

.quantity__controls {
  display: flex;
  gap: 8px;
}

.quantity__field {
  flex: 1;
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-variant-numeric: tabular-nums;
}

.quantity__max {
  padding: 10px 16px;
  font-size: 11px;
}
</style>
