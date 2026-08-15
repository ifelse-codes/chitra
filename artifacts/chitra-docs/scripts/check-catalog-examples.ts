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
// each chart would simply render with its own built-in renderer. So assert the
// injection actually CHANGED something — at least one chart must render
// differently under a different renderer, and switching themes must alter output.
const braille = byRenderer.get("braille")!;
const ascii = byRenderer.get("ascii")!;
const differing = [...braille.keys()].filter((id) => braille.get(id) !== ascii.get(id));
checked++;
if (differing.length === 0) {
  failed++;
  console.error("FAIL  renderer injection is a NO-OP — braille and ascii output are identical for all charts");
} else {
  console.log(`ok    renderer injection takes effect  (${differing.length}/${braille.size} charts differ braille vs ascii)`);
}

// Same argument for the theme switch, which rides the second injectOpt call.
const themed = CHARTS.filter((c) => {
  const a = evalCode(c.code, "braille", "default");
  const b = evalCode(c.code, "braille", "monochrome");
  return a.exitCode === 0 && b.exitCode === 0 && a.ansi !== b.ansi;
});
checked++;
if (themed.length === 0) {
  failed++;
  console.error("FAIL  theme injection is a NO-OP — default and monochrome output are identical for all charts");
} else {
  console.log(`ok    theme injection takes effect  (${themed.length}/${CHARTS.length} charts differ default vs monochrome)`);
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
