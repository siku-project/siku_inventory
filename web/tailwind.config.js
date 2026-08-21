/**
 * The inventory itself is styled from the tokens in assets/theme.css; what is
 * left here is only what the dev boilerplate actually reaches for. Utilities
 * that mirrored a token nobody wrote as a class were dropped rather than kept
 * as a second, silently diverging copy of the palette.
 *
 * @type {import('tailwindcss').Config}
 */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        accent: {
          DEFAULT: '#6cb6f6',
          text: '#9ed0fb',
        },
      },
      textColor: {
        sk: {
          DEFAULT: 'rgba(255, 255, 255, 0.96)',
          body: 'rgba(255, 255, 255, 0.82)',
          muted: 'rgba(255, 255, 255, 0.5)',
          soft: 'rgba(255, 255, 255, 0.34)',
          faint: 'rgba(255, 255, 255, 0.26)',
        },
      },
      boxShadow: {
        glow: '0 0 14px rgba(108, 182, 246, 0.7)',
      },
    },
  },
  plugins: [],
}
