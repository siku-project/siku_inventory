import './assets/main.css'
import '@mdi/font/css/materialdesignicons.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
import 'vuetify/styles'

import App from './App.vue'
import i18n from './i18n'
import { vDrag, vDrop } from './directives/drag'

const vuetify = createVuetify({
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
  theme: {
    defaultTheme: 'siku',
    themes: {
      siku: {
        dark: true,
        colors: {
          background: '#0b0c0e',
          surface: '#0f1114',
          primary: '#6cb6f6',
          secondary: '#9ed0fb',
          error: '#f87171',
          info: '#6cb6f6',
          success: '#6ec49b',
          warning: '#d5a45f',
          'on-primary': '#050a10',
          'on-background': '#ffffff',
          'on-surface': '#ffffff',
        },
      },
    },
  },
})

const app = createApp(App)

app.use(createPinia())
app.use(vuetify)
app.use(i18n)

app.directive('drag', vDrag)
app.directive('drop', vDrop)

app.mount('#app')
