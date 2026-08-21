import type { ItemDefinition, ItemMetadata, MetadataFormat } from '@/types/inventory'

export interface MetadataRow {
  key: string
  label: string
  value: string
}

const NUMBER = new Intl.NumberFormat('fr-FR')

/**
 * Renders one metadata value the way its declaration asked for. The interface
 * never knows what a property means: the item definition says how to read it,
 * so a new property shows up correctly without a change here.
 */
const render = (value: unknown, format: MetadataFormat): string => {
  const text = String(value)

  if (format === 'text' || typeof value === 'boolean') {
    return text
  }

  const numeric = Number(value)

  if (!Number.isFinite(numeric)) {
    return text
  }

  if (format === 'percent') {
    return `${NUMBER.format(numeric)} %`
  }

  if (format === 'money') {
    return `$ ${NUMBER.format(numeric)}`
  }

  if (format === 'date') {
    return new Date(numeric).toLocaleDateString('fr-FR')
  }

  return NUMBER.format(numeric)
}

/**
 * Turns the metadata of an instance into rows ready to display, keeping only
 * the keys the definition declared and in the order it listed them.
 *
 * @param definition The item kind.
 * @param metadata What the instance carries.
 * @param translate Resolves a translation key, falling back to the key itself.
 */
export const metadataRows = (
  definition: ItemDefinition | undefined,
  metadata: ItemMetadata | undefined,
  translate: (key: string) => string,
): MetadataRow[] => {
  const fields = definition?.metadataFields

  if (!fields || !metadata) {
    return []
  }

  return fields
    .filter((field) => metadata[field.key] !== undefined)
    .map((field) => ({
      key: field.key,
      label: translate(field.label),
      value: render(metadata[field.key], field.format),
    }))
}
