import { useI18n } from 'vue-i18n'
import type { ItemDefinition } from '@/types/inventory'

/**
 * Item labels arrive either as a translation key (`item.water`) or as a plain
 * string a server owner typed straight into the config. One helper decides
 * which, so every surface renders the same name.
 */
export const useItemLabel = () => {
  const { t } = useI18n()

  const labelOf = (definition?: ItemDefinition): string => {
    if (!definition) {
      return ''
    }

    return definition.label.startsWith('item.') ? t(definition.label) : definition.label
  }

  return { labelOf }
}
