/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#000000',
          hover: '#333333',
        },
        secondary: {
          DEFAULT: '#666666',
          hover: '#999999',
        }
      }
    },
  },
  plugins: [],
};