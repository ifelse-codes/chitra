/**
 * check-catalog-examples.ts — run EVERY catalog example through the real evaluator.
 *
 * Why this exists: S11's original verify script grepped the source for `new Function`,
 * `evalCode` and `catalog-page` and reported 14/14 ALL GREEN while 19 of the 20 chart
 * pages failed to render in a browser. A check that greps for the presence of code
 * cannot see whether that code works. This one executes it.
 *
 * Exit 0 = every example evaluated to real output. Exit 1 = at least one failed.
 */
import { CHARTS } from "../src/data/charts";
import { evalCode, applyOverrides } from "../src/components/CatalogPage";

const RENDERERS = ["braille", "blocks", "ascii"] as const;

let failed = 0;
let checked = 0;

for (const chart of CHARTS) {
  const res = evalCode(chart.code, "braille", "default");
  checked++;
  if (res.exitCode !== 0 || res.ansi.length === 0) {
    failed++;
    console.error(`FAIL  ${chart.id.padEnd(16)} ${res.error ?? "empty output"}`);
  } else {
    console.log(`ok    ${chart.id.padEnd(16)} ${res.ansi.length} chars`);
  }
}

// The renderer/theme switch rewrites the source before evaluating. Exercise every
// renderer against EVERY chart: testing one chart is not enough, because the chart
// that survived the original defect (line) is exactly the one that already declared
// a renderer key and so never took the injection path that was broken.
const byRenderer = new Map<string, Map<string, string>>();
for (const r of RENDERERS) {
  const broken: string[] = [];
  const outputs = new Map<string, string>();
  for (const chart of CHARTS) {
    const res = evalCode(chart.code, r, "nord");
    checked++;
    if (res.exitCode !== 0 || res.ansi.length === 0) {
      failed++;
      broken.push(chart.id);
    } else {
      outputs.set(chart.id, res.ansi);
    }
  }
  byRenderer.set(r, outputs);
  if (broken.length > 0) {
    console.error(`FAIL  renderer=${r}: ${broken.length} charts — ${broken.join(", ")}`);
  } else {
    console.log(`ok    renderer=${r}  (all ${CHARTS.length} charts)`);
  }
}

// "It did not throw" is not "it did the right thing". A cold review pointed out
// that turning injectOpt into `return code` would leave every check above green:
// each chart would simply render with its own built-in renderer.
//
// Asserting "output differs across renderers" is NOT enough on its own — many
// chitra charts (gauge, progress, pie, heatmap…) legitimately render identically
// under braille and ascii, so a no-op could hide behind them. So assert the
// REWRITE directly, per chart: the transformed source must actually carry the
// requested renderer and theme. That fails for every chart under a no-op, and it
// covers injectOpt's INSERT branch (charts with no renderer key) as well as its
// REPLACE branch — the insert branch is the one that broke 19 of 20 pages.
const notInjected: string[] = [];
for (const chart of CHARTS) {
  const out = applyOverrides(chart.code, "ascii", "monochrome");
  checked++;
  if (!/renderer:\s*"ascii"/.test(out) || !/theme:\s*"monochrome"/.test(out)) {
    failed++;
    notInjected.push(chart.id);
  }
}
if (notInjected.length > 0) {
  console.error(`FAIL  renderer/theme not injected into ${notInjected.length} chart(s) — ${notInjected.join(", ")}`);
} else {
  console.log(`ok    renderer + theme injected into all ${CHARTS.length} chart sources`);
}

// End-to-end corroboration: the rewrite must reach real OUTPUT. `> 0` would be
// satisfied forever by `line` alone — the one chart the original defect never
// broke — so the floor is pinned to the number measured on the working build.
// 5 of 20 charts honour the renderer (the rest are block/character charts that
// legitimately render identically); if that count drops, something regressed.
const braille = byRenderer.get("braille")!;
const ascii = byRenderer.get("ascii")!;
const comparable = [...braille.keys()].filter((id) => ascii.has(id));
const RENDERER_SENSITIVE_CHARTS = 5; // measured on the working build
const differing = comparable.filter((id) => braille.get(id) !== ascii.get(id));
checked++;
if (differing.length < RENDERER_SENSITIVE_CHARTS) {
  failed++;
  console.error(
    `FAIL  only ${differing.length} chart(s) changed OUTPUT between braille and ascii, expected >= ${RENDERER_SENSITIVE_CHARTS} — the rewrite is not reaching the renderer`,
  );
} else {
  console.log(`ok    renderer reaches output  (${differing.length}/${comparable.length} charts differ braille vs ascii, floor ${RENDERER_SENSITIVE_CHARTS})`);
}

// The Theme control had NO end-to-end assertion: the only theme coverage was a
// regex on rewritten source, so the feature could be entirely inert and still pass.
// Cold pass 6 named that the fakest green in the delivery. Assert that switching
// theme changes real OUTPUT, on the same measured-floor basis as the renderer.
const THEME_SENSITIVE_CHARTS = 19; // measured on the working build (all but heatmap)
const themeDiffering: string[] = [];
for (const chart of CHARTS) {
  const a = evalCode(chart.code, "braille", "default");
  const b = evalCode(chart.code, "braille", "monochrome");
  if (a.exitCode === 0 && b.exitCode === 0 && a.ansi !== b.ansi) themeDiffering.push(chart.id);
}
checked++;
if (themeDiffering.length < THEME_SENSITIVE_CHARTS) {
  failed++;
  console.error(
    `FAIL  only ${themeDiffering.length} chart(s) changed OUTPUT between themes, expected >= ${THEME_SENSITIVE_CHARTS} — the theme rewrite is not reaching the renderer`,
  );
} else {
  console.log(`ok    theme reaches output  (${themeDiffering.length}/${CHARTS.length} charts differ default vs monochrome, floor ${THEME_SENSITIVE_CHARTS})`);
}

// A deliberately broken buffer must be CAUGHT (exit 1 + message), never thrown.
const bad = evalCode("line({ data: [1,2,3] ).render();", "braille", "default");
checked++;
if (bad.exitCode === 0 || !bad.error) {
  failed++;
  console.error("FAIL  syntax error was not caught");
} else {
  console.log(`ok    syntax error caught: ${bad.error.slice(0, 40)}`);
}

// Pin the INPUTS as literals first. Deriving the expected total from the same
// arrays the loops iterate would let a deleted chart or renderer shrink `checked`
// and `EXPECTED_CHECKS` together, staying green at a smaller size — which is what
// the previous version actually did, despite its comment. Cold pass 6 caught it.
const EXPECTED_CHARTS = 20;
const EXPECTED_RENDERERS = 3;
if (CHARTS.length !== EXPECTED_CHARTS) {
  failed++;
  console.error(`FAIL  expected ${EXPECTED_CHARTS} charts, found ${CHARTS.length} — the input set changed`);
}
if (RENDERERS.length !== EXPECTED_RENDERERS) {
  failed++;
  console.error(`FAIL  expected ${EXPECTED_RENDERERS} renderers, found ${RENDERERS.length} — the input set changed`);
}
const EXPECTED_CHECKS = EXPECTED_CHARTS * (2 + EXPECTED_RENDERERS) + 3;
if (checked !== EXPECTED_CHECKS) {
  failed++;
  console.error(`FAIL  expected ${EXPECTED_CHECKS} checks, ran ${checked} — the suite changed shape`);
}

console.log(`\n${checked - failed}/${checked} catalog example checks passed`);
process.exit(failed === 0 ? 0 : 1);
