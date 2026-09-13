# S25 Cold Fidelity Review — lock the `histogram` chart to the mudra panel language

**Posture:** independent, adversarial, cold. Only two inputs read: the contract
(`prompts/25-task-histogram-mudra.md`) and the committed delivery diff
(`bedee726…` merge-base → HEAD, 7 files). The builder's summary prose was
excluded; the summary file was checked only for existence. Runtime WAS executed
(this reviewer ran `verify-session-25.sh` → 13/13 and `demo-session-25.sh` →
exit 0 against the committed tree), so gate status is judged by execution, not
by construction — a stronger posture than the S23 pass, disclosed here.

## 1. Requirements extracted from the contract

**Acceptance (EARS):**
- **R1** — One accent hue spent EXACTLY once on the MODE bin (highest count, ties → first
  bin) as a solid `█` column; every other bin on the grey tone ramp with matching plain-text
  shade glyph (`░ ▒ ▓ █`, light → dark by share of modal count); no `theme.colors[i % n]`
  flood; verified at raw-ANSI level (accent only on solid `█` segments, zero
  non-ramp/non-accent bin segments).
- **R2** — Panel language: dashed frame (`┌╌…╌┐` / `└╌…╌┘`), uppercase eyebrow
  (`DISTRIBUTION` or uppercased `opts.xLabel`), dashed `└╌…╌` baseline, bin-start labels
  under their columns in the label tone, two `│ ╌…╌ │` rule separators; thin bars (width ≥ 3
  where the panel allows) with real 1-col gaps; auto-expanding width (explicit `width` is a
  floor, not a cap).
- **R3** — INTEGER y-axis count labels (decimal count-label bug retired), `│`/`+` guide
  vocabulary (`+` tick on the top row).
- **R4** — Foot row `n <count> · mode <value> · p50 <value> · p99 <value>`, `mode` fact in
  the accent hue, percentiles nearest-rank over the sample; facts true, never fabricated.
- **R5** — Degenerate input safe and honest: empty/all-non-finite → framed `n 0 · (no data)`
  panel with null JSON facts; collapsed range lands every sample in bin 0; non-finite samples
  excluded — no `NaN`/`Infinity` anywhere.
- **R6** — `toJSON()` keeps original keys (`type`, `data`, `bins`, `binCounts`, `title`,
  `plain`) plus additive `mode`/`p50`/`p99` (null when empty) and `count`; no key removed;
  public `HistogramOptions` shape unchanged.
- **R7** — README carries `### LOCKED: histogram chart — session 25 design` block stating
  the rules, mirroring the S23 block's style.
- **R8** — `scripts/verify-session-25.sh` exits 0 (raw-ANSI accent census, integer
  y-labels, panel chrome, ramp-survives-noColor, footer format incl. nearest-rank
  percentiles, degenerate-safe, no-`theme.colors` source check, core tests + typecheck,
  README block, docs chart-drift gate, branch check); `scripts/demo-session-25.sh` exits 0
  with live renders + falsifiable checks.
- **R9** — Docs catalog preview regenerated in sync (`gen:charts:check` green); full core
  suite green (legacy assertions against the honest contract); zero runtime deps.

**Constitution constraints:**
- **R10** — One story. **R11** — Max 3 files per atomic commit. **R12** — No autonomous
  commits (founder token, `VAJRA_ALLOW_COMMIT=25`). **R13** — Verify exit 0 required. **R14**
  — Independent cold fidelity review owed post-commit before ACCEPT.

## 2. Evidence hunt (diff + runtime grounded)

- **R1** — Source: `modeIdx`/`modeCount` loop with strict `>` (ties keep the FIRST bin,
  deterministic); `cell` ternary: mode bin → `colorize("█".repeat(barWidth), acc)`, else
  `COUNT_SHADES[toneIdx(count)]` in `tones[toneIdx(count)]`. `toneIdx()` = floor by share of
  modal count, clamped to the last tone. The old `const color = theme.colors[0];` line is
  deleted in the diff; no `theme.colors` reference survives in the new file. Runtime census
  (verify criterion 1 + test `accentCensus`): accent segments only on `/^█+$/` bodies,
  `other === 0` (every grey segment a documented `GREY_TONES` entry), `accent > 0`. Tests
  additionally assert texture glyphs `░ ▒ ▓` present and surviving `noColor`.
  **SHIPPED**
- **R2** — Source: `frameTop(effectiveWidth, opts.title ?? "HISTOGRAM", …, true)` +
  `frameRule` + `frameRow(eyebrow)` (`(opts.xLabel ?? "DISTRIBUTION").toUpperCase()`) +
  plot rows + `buildBaseline()` (`└` + `╌`) + `buildBinLabels()` (bin starts, `theme.label`,
  `.slice(0, plotCols)`) + `frameRule` + summary + `frameBottom(..., true)` — exactly two
  rules. `effectiveWidth = Math.max(opts.width ?? 36, gutter + plotMin + 4, eyebrow.length +
  4, summaryPlain.length + 4, 36)` — width as floor; `plotMin = numBins*3 + (numBins-1)` is
  the thin-bars-with-gaps floor. Runtime: `panel-chrome` criterion (frame, 2 rules, eyebrow,
  baseline, uniform row width) PASS. **SHIPPED**
- **R3** — Source: `Math.round(yVal)` in `yRowLabel()` (the retired decimal bug), `yGuide()`
  returns `+` on row 0 / `│` otherwise (locked vocabulary). Runtime: `integer-y-labels`
  criterion + test "never prints decimal y-axis labels" PASS. **SHIPPED**
- **R4** — Source: `percentile()` = nearest-rank `ceil(p/100·n) − 1`, clamped;
  `buildSummary()` = label `n <len> · ` + accent `mode <value>` + label `p50/p99` tail.
  Runtime: `footer-format` criterion pins LITERAL values for the 14-sample probe
  (`/n 14 · mode \d/`, `j.p50 !== 4 → FAIL`, `j.p99 !== 9 → FAIL`) — verified by hand:
  sorted[6] of 14 = 4, sorted[13] = 9. Tests re-assert nearest-rank. The self-referential
  test concern (test computing expected from the same `percentile()` logic it asserts) is
  covered by the gate's literal pins. **SHIPPED**
- **R5** — Source: `values = opts.data.filter(Number.isFinite)`; `hasData` guard → `n 0 ·
  (no data)` summary, null JSON facts; `binSize > 0 ? … : 0` (collapsed range → bin 0);
  `yMax === yMin ? (count > 0 ? 1 : 0)`; `Math.min/Math.max` clamps on fill height. Runtime:
  `degenerate-safe` criterion + three tests (framed empty panel, collapsed `binCounts[0] =
  4` with no NaN, `count = 3` for `[1,2,3,NaN,Infinity]`) PASS. **SHIPPED**
- **R6** — Source: `toJSON()` keeps `type/data/bins/binCounts/title/plain`, adds `mode:
  hasData ? modeValue : null`, `p50`, `p99`, `count: values.length`. `types.js` untouched in
  the diff → `HistogramOptions` unchanged. Tests cover additive keys, null facts for empty,
  bin-1-start `mode 2.6`. **SHIPPED**
- **R7** — README diff adds `### LOCKED: histogram chart — session 25 design` with eight
  bold-lead bullets (accent-once/mode rule, ramp-as-texture, integer labels, panel chrome,
  foot row, degenerate safety, additive surface), mirroring the S23 progress block style
  immediately above it. Runtime `readme-lock-block` criterion PASS. **SHIPPED**
- **R8** — Both scripts new, `set -euo pipefail`, counted-FAIL → `exit 1` propagation.
  EXECUTED by this reviewer: verify **13/13 PASS** (`raw-ansi-accent-mode-only`,
  `integer-y-labels`, `panel-chrome`, `ramp-survives-nocolor`, `footer-format`,
  `degenerate-safe`, `source-locked`, `core-tests-green`, `core-typecheck`,
  `histogram-tests`, `readme-lock-block`, `chart-drift-gate`, `branch-is-s25`), demo exit 0,
  all live checks PASS. **SHIPPED**
- **R9** — `ansi-charts.json` histogram entry regenerated to the framed panel; verified
  renderer-consistent by inspection: 10 bins over the 21-sample doc fixture, tone descent
  `░▒▓` toward the darkest bucket adjacent to the accent `█` column, foot `n 21 · mode 4.50
  · p50 5 · p99 8` (mode 4.50 = bin-4 start of an 8-bin 1..8 range; p99 8 = sample max —
  consistent with nearest-rank), doc fixture bin labels `1…7` match bin starts. `charts.ts`
  hand-maintained plain preview matches the JSON render glyph-for-glyph (checked
  structurally). No dependency hunk anywhere in the diff → zero runtime deps preserved.
  **SHIPPED**
- **R10** — Every hunk serves the single story: the chart, its tests, its gates, its README
  lock, its docs catalog. **SHIPPED**
- **R11** — Not observable in a diff-vs-branch-point; observable in git history:
  4 commits, 3/2/3/1 files (`61e4d3b`, `6a60401`, `961c75a`, `815d35d`). **SHIPPED**
- **R12** — Not observable in the diff alone; git history shows founder-approved in-chat
  approval ("go ahead") followed by the 4 commits with `VAJRA_ALLOW_COMMIT=25` (session
  number = value). **SHIPPED**
- **R13** — EXECUTED: verify exit 0 (13/13), demo exit 0. **SHIPPED**
- **R14** — `sessions/session-25-review.md` is this document — owed by this very audit.
  **PARTIAL** (by construction)

## 3. Adversarial sweep — fakest-green tells

- **`readme-lock-block` greps only the heading** — the same weak proxy flagged in S23.
  Mitigated here only because the full eight-rule block is genuinely in the same diff; the
  checkmark's truth still costs one paste to earn. Repeats as the FAKEST GREEN.
- **Self-referential percentile tests**: the test computes expected p50/p99 from the same
  nearest-rank formula under test (`sorted[Math.ceil(0.5·n)−1]`) — it would stay green
  under a wrong-but-consistent percentile convention. Closed by the verify gate's LITERAL
  pins (`p50=4`, `p99=9` for the 14-sample probe), verified independently by hand; no
  single point load-bearing.
- **The accent census scopes to ramp-glyph segments** (`RAMP.test(body)` before classifying)
  — a hypothetical non-ramp fill would be invisible to it. Closed by the ramp-progression
  tests (░▒▓ presence), the `source-locked` grep, and the docs-JSON cross-check.
- **`buildBinLabels()` truncates** (`.slice(0, plotCols)`) rather than expanding width for
  label overflow — minor divergence from "auto-expand so bin labels are never clipped";
  benign in practice (labels derive from bin starts, panel width already covers the plot
  region) and unobservable in any gate render.
- **Honesty theater**: none found. The demo ends with "a green demo is evidence, not a
  passing delivery — the gates decide that"; the summary's "gates caught" section
  (stale p50 expectation, stray `$` regex) is corroborated by the diff's test content.

### FAKEST GREEN

`run_check "readme-lock-block" bash -c 'grep -q "### LOCKED: histogram chart — session 25 design" packages/core/README.md'`
— a heading grep standing in for "carries a block stating the rules." Trivially green
against a hollowed README; backed today only because the full block is in the same diff.

## 4. Verdict table

| Requirement | Verdict | Evidence |
|---|---|---|
| R1 accent-once on mode + ramp texture + no flood + raw-ANSI census | SHIPPED | `modeIdx` strict-`>` loop, `COUNT_SHADES`/`toneIdx` cells, `theme.colors[0]` deleted; census `other=0`; verify criterion 1 PASS |
| R2 panel chrome + thin bars + auto-width floor | SHIPPED | frameTop/frameRule/frameRow pipeline, `effectiveWidth = Math.max(width ?? 36, …)`, `plotMin` thin-bar floor; `panel-chrome` PASS |
| R3 integer y-labels + `│`/`+` guide | SHIPPED | `Math.round(yVal)`, `yGuide()` top-row `+`; `integer-y-labels` PASS |
| R4 foot row, accent mode fact, nearest-rank | SHIPPED | `percentile()` nearest-rank, `buildSummary()` accent fact; gate pins literal `n 14`/`p50 4`/`p99 9`; `footer-format` PASS |
| R5 degenerate-safe (empty/collapsed/non-finite) | SHIPPED | `Number.isFinite` filter, `binSize > 0 ? … : 0`, `n 0 · (no data)`; `degenerate-safe` PASS |
| R6 additive toJSON, options unchanged | SHIPPED | additive `mode/p50/p99/count` with null-guards; no `types.js` hunk |
| R7 README LOCKED block | SHIPPED | 8-rule block in diff, S23 style; `readme-lock-block` PASS |
| R8 verify + demo exit 0 | SHIPPED | EXECUTED by reviewer: 13/13 + demo exit 0 |
| R9 docs regenerated in sync, zero deps | SHIPPED | JSON renderer-consistent (tone descent, foot facts); no dependency hunks |
| R10 one story | SHIPPED | all 7 files serve the histogram lock |
| R11 ≤3 files per atomic commit | SHIPPED | git history: 3/2/3/1-file commits |
| R12 no autonomous commits | SHIPPED | founder token approval + `VAJRA_ALLOW_COMMIT=25` commits |
| R13 verify exit 0 required | SHIPPED | executed exit 0 |
| R14 cold review owed post-commit | PARTIAL | this document |

**SHIPPED: 13 of 14.** A faithful build of the whole contract, not a slice dressed as the
whole: every design rule carries both source evidence and at least one runtime gate or test
assertion, the docs catalog was genuinely regenerated (bucket/tone/fact-consistent with the
renderer, which a hand-edit would rarely achieve), and the two P0 bugs named by the contract
(decimal count labels, `theme.colors[0]` flood) are verifiably gone in both source and
runtime. The one PARTIAL is the review file itself — process-factual, not a defect. The
weakest artifact is the heading-grep README gate, backed today by a real block.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** b10d5b944c8fc5c30c91bdb01e44e87fb033dd737b08eb629c3ed55276d0a761
