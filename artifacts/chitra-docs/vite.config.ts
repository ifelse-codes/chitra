import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

// PORT / BASE_PATH were Replit-scaffold requirements. They were hard throws, so a
// human who followed the README and ran `pnpm run build` got a stack trace while
// CI — which exports both — was green. Default them; CI still overrides.
// S41 requirement 11.
const rawPort = process.env.PORT ?? "5000";

const port = Number(rawPort);

if (Number.isNaN(port) || port <= 0) {
  throw new Error(`Invalid PORT value: "${rawPort}"`);
}

const basePath = process.env.BASE_PATH ?? "/";

// One id per dev-server boot — editor overrides in localStorage are scoped to
// it, so they live exactly until the server restarts.
const bootId = `boot-${Date.now()}`;

export default defineConfig({
  base: basePath,
  plugins: [
    {
      name: "chitra-boot-id",
      transformIndexHtml() {
        return [
          {
            tag: "script",
            children: `window.__CHITRA_BOOT_ID__ = ${JSON.stringify(bootId)};`,
            injectTo: "head-prepend",
          },
        ];
      },
    },
    react(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      "@": path.resolve(import.meta.dirname, "src"),
    },
    dedupe: ["react", "react-dom"],
  },
  root: path.resolve(import.meta.dirname),
  build: {
    outDir: path.resolve(import.meta.dirname, "dist/public"),
    emptyOutDir: true,
  },
  server: {
    port,
    strictPort: true,
    host: "0.0.0.0",
    allowedHosts: true,
    fs: {
      strict: true,
      allow: [
        path.resolve(import.meta.dirname),
        path.resolve(import.meta.dirname, "../../packages/core"),
      ],
    },
  },
  preview: {
    port,
    host: "0.0.0.0",
    allowedHosts: true,
  },
});
