# Session 28 review — sparkline lock (independent fidelity pass)

## Method controls

- Cold inputs only: contract `prompts/28-task-sparkline.md` + committed delivery
  diff `git diff main...session-28-sparkline`. No summary, STATE, or chat read.
- Trusted the diff, not any prose claim. Assumed the builder re-scoped to
  whatever yields green checkmarks; hunted the fakest checkmark.
- Source truth limited to the files the diff touches
  (`packages/core/src/charts/sparkline.ts`, `packages/core/tests/sparkline.test.ts`),
  read as committed state. Requirement count taken from the contract's 9 numbered
  requirements. Attestation SHA computed with the gate's own function
  (`scripts/verify-closeout.sh --inputs-sha 28`) after reviewing the committed diff.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Shape+shade columns: every reading one 2-wide column, ≤4 rows by share of range; shade `░ ▒ ▓ █` by share on grey ramp, intensity survives noColor | SHIPPED | `sparkline.ts:12 LEVEL_SHADES`, `sparkline.ts:19-20 CELLW=2, ROWS=4`, `sparkline.ts:78-85 columnAt` (`h = 1 + Math.round(share * (ROWS-1))`, `ti = floor(share*tones.length)`, `LEVEL_SHADES[ti]` + `tones[ti]`), `sparkline.ts:87-98 buildStrip` (4 rows); test `sparkline.test.ts:77-80` (shades survive stripAnsi), `sparkline.test.ts:115-129` (bottom strip row 8 chars = 4 cols × 2) |
| 2 | One accent, spent once: peak (ties → first) solid `█` accent; no `theme.colors[0]` teal flood | SHIPPED | `sparkline.ts:61 peakIndex = pts.indexOf(max)` (first tie), `sparkline.ts:82 if (i === peakIndex) return { h, glyph: "█", color: acc }`; `theme.colors[` absent from source (verify `source-locked` greps it); test `sparkline.test.ts:52-64` (census `other===0`, 4 accent solids = peak full height), `sparkline.test.ts:66-75` (ties → index 0, accent still exactly 4 solids) |
| 3 | Panel chrome: dashed frame, label on frame top, uppercase `SPARKLINE` eyebrow, two rule separators; bigger than bare one-line strip | SHIPPED | `sparkline.ts:112-122 buildLines` (`frameTop(effectiveWidth, title, …)`, `frameRule`, `frameRow(eyebrow SPARKLINE)`, strip rows, `frameRule`, summary row, `frameBottom`); test `sparkline.test.ts:27-36` (`/^┌╌/`, `/^└╌/`, exactly 2 `/^│ ╌+ │$/` rules, `SPARKLINE` present, uniform width), `sparkline.test.ts:38-43` (label `CPU` on frame top) |
| 4 | Facts foot: `n · min · max · last · peak` with peak accented (`showValue: false` drops `last`) | SHIPPED | `sparkline.ts:65-70 summaryPlain`, `sparkline.ts:100-110 buildSummary` (head in `theme.label` + `peak` in `acc`; `showValue === false` omits `last`); test `sparkline.test.ts:45-50` (`n 5 · min 1 · max 5 · last 4 · peak 5`, foot contains `theme.accent`), `sparkline.test.ts:131-137` (`showValue:false` drops `last`, keeps `peak 5`) |
| 5 | Width keeps meaning: plotted data columns; longer input deterministically downsampled; panel auto-expands (floor, never cap) | SHIPPED | `sparkline.ts:51-52 cols = max(1, width ?? finite.length)`, `pts = downsample(finite, cols)`, `sparkline.ts:149-155 downsample` (evenly spaced `Math.round(i*(n-1)/(cols-1))`, order-preserving, `cols===1` → first); `sparkline.ts:75-76 effectiveWidth = max(stripWidth+4, eyebrow+4, summaryPlain+4)` (floor, never cap); test `sparkline.test.ts:115-129` (8→4 columns, bottom row 8 wide, re-render identical = deterministic) |
| 6 | Renderer superseded: option stays accepted, one design renders | SHIPPED | Source drops `renderer` dispatch entirely (no `sparklineBlocks`/`sparklineAscii`/`BrailleCanvas` imports — removed vs base) while `SparklineOptions.renderer` still type-accepts; test `sparkline.test.ts:108-113` (blocks/braille/ascii all byte-identical to base) |
| 7 | Degenerate-safe: empty/all-non-finite → framed `n 0 · (no data)` + null facts; flat range safe; non-finite excluded from plot, facts, count; narrow-safe | SHIPPED | `sparkline.ts:47 finite` filter, `sparkline.ts:55 count = pts.length`, `sparkline.ts:66-67` empty → `n 0 · (no data)` still framed via `buildLines`, `sparkline.ts:80 share = max===min ? 1` (flat safe), `sparkline.ts:137-140` null facts; tests `sparkline.test.ts:82-92` (framed empty + all nulls), `sparkline.test.ts:94-100` (NaN/Infinity excluded, count 3), `sparkline.test.ts:102-106` (flat, no NaN), `sparkline.test.ts:158-161` (width 1 still `┌╌`) |
| 8 | Additive agent surface: `toJSON` keeps `type`/`data`/`label`/`plain`, adds facts incl. `peak {index, value}` | SHIPPED | `sparkline.ts:131-143 toJSON` (`type`, `data: opts.data`, `label`, `count/min/max/last`, `peak: { index: peakIndex, value: max }`, `plain`); test `sparkline.test.ts:139-150` (legacy keys + `count 3/min 1/max 42/last 42/peak {index:2,value:42}`) |
| 9 | Gates: new lock tests, full suite + typecheck green, verify green, demo green, README `### LOCKED` block, docs previews in sync, `dist/` rebuilt | SHIPPED | Lock tests: `sparkline.test.ts` rewritten to 15 S28 tests (panel, census, ties, foot, width, degenerate, additive). README: diff adds `### LOCKED: sparkline chart — session 28 design` block. Docs: diff updates `artifacts/chitra-docs/src/data/charts.ts` sparkline preview to the panel + `ansi-charts.json`. Verify/demo: new `scripts/verify-session-28.sh` (13 criteria incl. tonal census, ties-exclusivity, panel chrome, renderer-width, degenerate, source-locked, core tests, typecheck, readme block, drift gate, dist-carries-lock) and `scripts/demo-session-28.sh` (live falsifiable checks). `dist/` is gitignored (`.gitignore: dist/`), so absence from the committed diff is expected; the verify `dist-carries-lock` gate covers the local rebuild. No weak heading-grep proxy found — checks assert behavior (ANSI census, exact foot, downsample geometry). |

## Count and fakest green

9 of 9 SHIPPED.

Fakest green: the foot-agreement guarantee is the most re-scope-flavored checkmark — `sparkline.ts:53-54` defines every fact over the post-downsample PLOTTED points so the foot can never disagree with the strip, which makes agreement trivially true while silently redefining `n/min/max` away from the full input on downsampled renders.

Scope sentence: the delivery is a faithful build of the whole contract, not one narrow slice presented as the whole — every numbered requirement has real behavior plus a locking test behind it.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** b908a5ce63a3bd73824486cf5858b94dd46acab6af1b697217121f700a0370be
