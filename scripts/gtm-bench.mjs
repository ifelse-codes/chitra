#!/usr/bin/env node
// S48 R3 — the benchmarks, measured (never claimed).
//
//   node scripts/gtm-bench.mjs [--json] [--iterations 200]
//
// Four numbers a developer wants before installing, all printed in one run:
//   deps=             runtime dependencies (the "zero-dependency" claim, counted)
//   tarball-bytes=    what `npm i` downloads
//   unpacked-bytes=   what it leaves on disk
//   render-median-ms= median time to render one 100-point line chart
//
// The README cites these WITH this script's name beside them; the session gate
// re-runs it and fails if a cited number no longer matches. Timing is a budget,
// not a fossil: the gate asserts the live median stays inside `render-budget-ms`,
// because a millisecond measured in October is wrong in December on someone
// else's machine.
//
// Exit codes: 0 = measured, 1 = a step failed.

const PKG_DIR = "packages/core";
const BUDGET_MS = 2;
const arg = (name, fallback) => {
  const i = process.argv.indexOf(name);
  return i === -1 ? fallback : process.argv[i + 1];
};
const iterations = Number(arg("--iterations", "200"));
const asJson = process.argv.includes("--json");

async function packInfo() {
  const { execFileSync } = await import("node:child_process");
  const out = execFileSync(
    "npm",
    ["pack", "--dry-run", "--json", "--silent"],
    { cwd: PKG_DIR, encoding: "utf8" }
  );
  const j = JSON.parse(out)[0];
  return { size: j.size, unpackedSize: j.unpackedSize, files: (j.files || []).length };
}

function median(xs) {
  const s = [...xs].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
}

async function main() {
  const { createRequire } = await import("node:module");
  const require = createRequire(import.meta.url);
  const manifest = require("../packages/core/package.json");
  const pkg = require("../packages/core/dist/index.cjs");

  const deps = Object.keys(manifest.dependencies || {}).length;
  const pack = await packInfo();

  // One standard chart: a 100-point line, the shape a dashboard actually renders.
  // Measured on `toPlain()` — the render itself, without the stdout write — so the
  // number says what the library costs, not what a terminal costs.
  const data = Array.from({ length: 100 }, (_, i) => Math.round(50 + 40 * Math.sin(i / 7)));
  const times = [];
  let sink = 0;
  for (let i = 0; i < iterations; i++) {
    const t0 = performance.now();
    const text = pkg.line({ data, title: "Benchmark", noColor: true }).toPlain();
    sink += text.length;
    times.push(performance.now() - t0);
  }
  if (sink < 0) console.log(sink); // unreachable: keeps the renders from being optimised away
  const medianMs = median(times.slice(Math.floor(iterations / 10)));

  const reading = {
    deps,
    "tarball-bytes": pack.size,
    "tarball-kb": (pack.size / 1024).toFixed(1),
    "unpacked-bytes": pack.unpackedSize,
    "unpacked-kb": (pack.unpackedSize / 1024).toFixed(1),
    "pack-files": pack.files,
    "render-median-ms": Number(medianMs.toFixed(2)),
    "render-budget-ms": BUDGET_MS,
    "render-iterations": iterations,
    node: process.version,
  };

  if (asJson) {
    console.log(JSON.stringify(reading, null, 2));
    return;
  }
  for (const [k, v] of Object.entries(reading)) console.log(`${k}=${v}`);
  const ok = reading["render-median-ms"] <= BUDGET_MS;
  console.log(
    `verdict=${ok ? "within render budget" : `OVER BUDGET: ${reading["render-median-ms"]}ms > ${BUDGET_MS}ms`}`
  );
  if (!ok) process.exit(1);
}

main().catch((err) => {
  console.error(`gtm-bench failed: ${err.message}`);
  process.exit(1);
});
