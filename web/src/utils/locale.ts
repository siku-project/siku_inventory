import { i18n } from '@/i18n'
import type { LocalePayload } from '@/services/bridge'

/**
 * Applies the translation table pushed by the game. Strings live in
 * translations/<language>.lua and travel to the interface, so a server owner
 * edits one file rather than two.
 */
export const applyLocale = (payload: LocalePayload): void => {
  const web = payload.translations.web

  if (!web || typeof web !== 'object') {
    return
  }

  const language = payload.language as 'fr' | 'en'

  i18n.global.setLocaleMessage(language, web as Record<string, string>)
  i18n.global.locale.value = language
}
