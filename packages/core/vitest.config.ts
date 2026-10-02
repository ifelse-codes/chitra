import { defineConfig } from "vitest/config";
import { readFileSync } from "node:fs";

const pkg = JSON.parse(
  readFileSync(new URL("./package.json", import.meta.url), "utf8"),
);

export default defineConfig({
  // Same define as build.mjs — src/index.ts reads __CHITRA_VERSION__, so without
  // this every test that imports the package entry throws a ReferenceError.
  // Keeping them in step is the point: one source, the manifest. S41 req. 2.
  define: { __CHITRA_VERSION__: JSON.stringify(pkg.version) },
  test: {
    globals: true,
    environment: "node",
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      thresholds: {
        statements: 90,
        branches: 85,
        functions: 90,
        lines: 90,
      },
    },
  },
});
