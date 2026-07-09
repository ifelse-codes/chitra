// Build the publishable dist/ for @chitra/core.
// Emits single-file ESM + CJS bundles via esbuild; declarations come from tsc
// (see the build script in package.json). The library has zero runtime deps,
// so bundling is fully self-contained.
import { build } from "esbuild";
import { rmSync } from "node:fs";

rmSync(new URL("./dist", import.meta.url), { recursive: true, force: true });

const common = {
  entryPoints: ["src/index.ts"],
  bundle: true,
  platform: "node",
  target: "es2022",
  logLevel: "info",
};

await Promise.all([
  build({ ...common, format: "esm", outfile: "dist/index.js" }),
  build({ ...common, format: "cjs", outfile: "dist/index.cjs" }),
]);
