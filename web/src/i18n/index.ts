import { createI18n } from 'vue-i18n'

/**
 * Starts empty on purpose: strings live in translations/<language>.lua and
 * are pushed into the interface at startup, so a server owner edits one file
 * rather than two.
 */
export const i18n = createI18n({
  legacy: false,
  locale: 'fr',
  fallbackLocale: 'fr',
  messages: { fr: {}, en: {} },
  globalInjection: true,
  missingWarn: false,
  fallbackWarn: false,
})

export default i18n
