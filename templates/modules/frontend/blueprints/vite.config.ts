import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
export default defineConfig({
  plugins: [vue()],
  server: { host: true, __VITE_PROXY__ },
  __VITE_BUILD__
})
