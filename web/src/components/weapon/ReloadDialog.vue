<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import DialogShell from '@/components/inventory/DialogShell.vue'
import ItemArtwork from '@/components/inventory/ItemArtwork.vue'
import { useInventoryStore } from '@/stores/inventory'
import { useItemLabel } from '@/composables/useItemLabel'
import type { ReloadState } from '@/types/weapon'

const props = defineProps<{
  state: ReloadState
}>()

const emit = defineEmits<{
  close: []
}>()

const { t } = useI18n()
const store = useInventoryStore()
const { labelOf } = useItemLabel()

const chosen = ref<string | null>(null)

const ammo = computed(() => store.definitionOf(props.state.ammoItem))
const ammoLabel = computed(() => labelOf(ammo.value))

/**
 * Every weapon the rounds fit, full ones included. One that cannot take
 * anything is shown unavailable rather than hidden: the player owns it, and
 * seeing it greyed out answers "why is it not here" before it is asked.
 */
const targets = computed(() =>
  props.state.weapons.map((weapon) => ({
    ...weapon,
    definition: store.definitionOf(weapon.item),
    label: labelOf(store.definitionOf(weapon.item)),
    full: weapon.room <= 0,
  })),
)

const selectable = computed(() => targets.value.find((target) => target.uid === chosen.value))

const confirm = async (): Promise<void> => {
  const target = selectable.value

  if (!target || target.full) {
    return
  }

  await store.reload(target.uid, target.magazine)
}
</script>

<template>
  <DialogShell
    :title="t('reload.title')"
    :hint="targets.length > 0 ? t('reload.hint') : undefined"
    :width="520"
    @close="emit('close')"
  >
    <header class="ammo">
      <span class="ammo__art">
        <ItemArtwork :definition="ammo" :label="ammoLabel" />
      </span>

      <div class="ammo__text">
        <p class="ammo__name">{{ ammoLabel }}</p>
        <p class="ammo__stock sk-mono">{{ t('reload.carried') }} · {{ state.carried }}</p>
      </div>
    </header>

    <div class="sk-rule sk-rule--strong"></div>

    <section v-if="targets.length > 0" class="targets">
      <button
        v-for="target in targets"
        :key="target.uid"
        type="button"
        class="target"
        :class="{ 'target--chosen': chosen === target.uid, 'target--full': target.full }"
        :disabled="target.full"
        @click="chosen = target.uid"
      >
        <span class="target__art">
          <ItemArtwork :definition="target.definition" :label="target.label" />
        </span>

        <span class="target__text">
          <span class="target__name">{{ target.label }}</span>
          <span class="target__state sk-mono">
            {{ t('reload.state', { loaded: target.ammo, magazine: target.magazine }) }}
          </span>
        </span>

        <span v-if="target.full" class="target__tag">{{ t('reload.full') }}</span>
        <v-icon v-else-if="chosen === target.uid" class="target__mark" size="15">mdi-check</v-icon>
      </button>
    </section>

    <section v-else class="none">
      <v-icon class="sk-icon" size="24">mdi-pistol</v-icon>
      <p class="none__title">{{ t('reload.none') }}</p>
      <p class="none__hint">{{ t('reload.noneHint') }}</p>
    </section>

    <template #actions>
      <button type="button" class="sk-btn" @click="emit('close')">
        {{ t('action.cancel') }}
      </button>

      <button
        v-if="targets.length > 0"
        type="button"
        class="sk-btn sk-btn--primary"
        :disabled="!selectable || selectable.full"
        @click="confirm"
      >
        {{ t('reload.confirm') }}
      </button>
    </template>
  </DialogShell>
</template>

<style scoped>
.ammo {
  display: flex;
  align-items: center;
  gap: 16px;
}

.ammo__art {
  display: flex;
  height: 58px;
  width: 58px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: var(--sk-radius-tile);
  border: 1px solid var(--sk-border-soft);
  background: rgba(255, 255, 255, 0.035);
  padding: 9px;
  font-size: 58px;
}

.ammo__name {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: -0.012em;
  color: var(--sk-text);
}

.ammo__stock {
  margin: 4px 0 0;
  font-size: 11.5px;
  letter-spacing: 0.03em;
  color: var(--sk-text-soft);
}

.targets {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.target {
  display: flex;
  width: 100%;
  align-items: center;
  gap: 13px;
  border-radius: var(--sk-radius-row);
  border: 1px solid var(--sk-border-soft);
  background: var(--sk-surface);
  padding: 10px 15px 10px 11px;
  text-align: left;
  transition:
    border-color 0.16s ease,
    background 0.16s ease;
}

.target:hover:not(:disabled):not(.target--chosen) {
  border-color: var(--sk-border-hover);
  background: var(--sk-surface-hover);
}

.target--chosen {
  border-color: var(--sk-accent-border);
  background: var(--sk-accent-tint);
}

/* A weapon that cannot take a round is still the player's: dimmed, not gone. */
.target--full {
  cursor: default;
  opacity: 0.42;
}

.target__art {
  display: flex;
  height: 34px;
  width: 34px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  font-size: 34px;
}

.target__text {
  display: flex;
  min-width: 0;
  flex: 1;
  flex-direction: column;
  gap: 3px;
}

.target__name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.target--chosen .target__name {
  color: var(--sk-frost);
}

.target__state {
  font-size: 11px;
  color: var(--sk-text-soft);
}

.target__tag {
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--sk-text-soft);
}

.target__mark {
  color: var(--sk-accent);
}

.none {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 22px 12px 14px;
  text-align: center;
}

.none__title {
  margin: 5px 0 0;
  font-size: 13px;
  font-weight: 500;
  color: var(--sk-text-body);
}

.none__hint {
  margin: 0;
  max-width: 38ch;
  font-size: 11.5px;
  line-height: 1.5;
  color: var(--sk-text-soft);
}
</style>
