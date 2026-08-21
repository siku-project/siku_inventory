const GRAMS_IN_KILO = 1000

/**
 * Turns grams into the unit a human would say out loud: grams below a kilo,
 * kilos above, and never a trailing zero that carries no information.
 */
export const formatWeight = (grams: number): string => {
  if (!Number.isFinite(grams) || grams <= 0) {
    return '0 g'
  }

  if (grams < GRAMS_IN_KILO) {
    return `${Math.round(grams)} g`
  }

  const kilos = grams / GRAMS_IN_KILO
  const rounded = Math.round(kilos * 10) / 10

  return `${Number.isInteger(rounded) ? rounded : rounded.toFixed(1)} kg`
}

/** Same as formatWeight, without the unit — for the left half of a ratio. */
export const formatWeightValue = (grams: number, referenceGrams: number): string => {
  if (referenceGrams < GRAMS_IN_KILO) {
    return String(Math.round(grams))
  }

  const kilos = grams / GRAMS_IN_KILO
  const rounded = Math.round(kilos * 10) / 10

  return Number.isInteger(rounded) ? String(rounded) : rounded.toFixed(1)
}

/** Formats a quantity so long stacks stay readable in a slot corner. */
export const formatCount = (count: number): string => {
  if (count < 1000) {
    return String(count)
  }

  if (count < 1000000) {
    const thousands = count / 1000

    return `${Number.isInteger(thousands) ? thousands : thousands.toFixed(1)}k`
  }

  return `${(count / 1000000).toFixed(1)}M`
}
