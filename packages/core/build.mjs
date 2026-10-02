// Build the publishable dist/ for @ifelse.codes/chitra.
// Emits single-file ESM + CJS bundles via esbuild; declarations come from tsc
// (see the build script in package.json). The library has zero runtime deps,
// so bundling is fully self-contained.
import { build } from "esbuild";
import { rmSync, readFileSync } from "node:fs";

const pkg = JSON.parse(
  readFileSync(new URL("./package.json", import.meta.url), "utf8"),
);

rmSync(new URL("./dist", import.meta.url), { recursive: true, force: true });

const common = {
  entryPoints: ["src/index.ts"],
  bundle: true,
  platform: "node",
  target: "es2022",
  logLevel: "info",
  // Single source of truth for the version: the manifest. S41 requirement 2.
  define: { __CHITRA_VERSION__: JSON.stringify(pkg.version) },
};

await Promise.all([
  build({ ...common, format: "esm", outfile: "dist/index.js" }),
  build({ ...common, format: "cjs", outfile: "dist/index.cjs" }),
]);
