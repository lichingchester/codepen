import { fileURLToPath, URL } from "node:url";

import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import glslify from "rollup-plugin-glslify";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(), glslify()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
});
