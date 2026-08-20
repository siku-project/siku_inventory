/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        accent: {
          DEFAULT: '#6cb6f6',
          hover: '#8ac8fb',
          text: '#9ed0fb',
          ink: 'rgba(5, 10, 16, 0.94)',
        },
        sk: {
          veil: 'rgba(6, 7, 9, 0.88)',
          panel: 'rgba(11, 12, 14, 0.97)',
          surface: 'rgba(14, 15, 18, 0.72)',
          'surface-hover': 'rgba(22, 24, 28, 0.82)',
          'surface-active': 'rgba(18, 32, 46, 0.86)',
          field: 'rgba(255, 255, 255, 0.03)',
        },
      },
      borderColor: {
        sk: {
          DEFAULT: 'rgba(255, 255, 255, 0.08)',
          soft: 'rgba(255, 255, 255, 0.07)',
          hover: 'rgba(255, 255, 255, 0.14)',
          accent: 'rgba(108, 182, 246, 0.42)',
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
      borderRadius: {
        panel: '16px',
        tile: '11px',
        row: '10px',
        control: '9px',
        badge: '8px',
      },
      boxShadow: {
        panel: '0 44px 100px -44px rgba(0, 0, 0, 0.95)',
        primary: '0 10px 26px -14px rgba(108, 182, 246, 0.95)',
        glow: '0 0 14px rgba(108, 182, 246, 0.7)',
      },
      transitionDuration: {
        sk: '160ms',
      },
    },
  },
  plugins: [],
}
