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
import { evalCode } from "../src/components/CatalogPage";

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
for (const r of RENDERERS) {
  const broken: string[] = [];
  for (const chart of CHARTS) {
    const res = evalCode(chart.code, r, "nord");
    checked++;
    if (res.exitCode !== 0 || res.ansi.length === 0) {
      failed++;
      broken.push(chart.id);
    }
  }
  if (broken.length > 0) {
    console.error(`FAIL  renderer=${r}: ${broken.length} charts — ${broken.join(", ")}`);
  } else {
    console.log(`ok    renderer=${r}  (all ${CHARTS.length} charts)`);
  }
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

console.log(`\n${checked - failed}/${checked} catalog example checks passed`);
process.exit(failed === 0 ? 0 : 1);
