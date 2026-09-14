# Session 27 — lock `candlestick` + `boxplot` to the mudra reference/panel design language

> **Type: CODE.** Branch `session-27-candlestick-boxplot`. Two stories by
> founder direction ("candlestick boxplot migrate first") — the 1-story/session
> rule is waived, disclosed here. Neither chart has an audit mockup (the audit
> queue is empty after S26); the S18–S26 family language applies by analogy,
> with the waterfall down-outline precedent for bearish candles. Carry the
> 2026-09-11 shade-texture ruling throughout. Keep it tight.

## Goal

`candlestick` and `boxplot` are NOT locked to chitra's reference design
language and carry the same bug classes the audit queue just retired
elsewhere: (1) a **`theme.colors[i]` rainbow** (`candlestick.ts:57-60` greens
ups / reds downs; `boxplot.ts:52` a per-group rainbow) instead of mudra's
tonal semantics; (2) **decimal y-labels** (`formatNumber` prints `162.55`-style
intermediates on a price axis); (3) no panel, no eyebrow, no rules, no foot —
a bare title line, a solid `└─` baseline, and per-chart label rows; (4) NO
degenerate guards at all — empty data crashes (`Math.max(...[])` →
`-Infinity` width in candlestick; `rawData[0]` undefined in boxplot), a flat
range divides by zero (`toRow` → `NaN` rows), and boxplot's `┼─┼` median bar
`RangeError`s on narrow widths (`" ".repeat(mid - 1)`, negative). Apply the
locked S18–S26 language: dashed panel + eyebrow + rules + foot, one accent
spent exactly once, grey tone ramp with shade texture so kind survives
`stripAnsi` / `noColor`.

## Named references (read ONLY these — do not scan the repo)

- `packages/core/src/charts/waterfall.ts` — the S26 locked playbook (panel
  composition, `width`-is-floor auto-expand, `│`/`+` y-guide, dashed `└╌`
  baseline, accent-once census shape, degenerate-safe pattern) AND the
  down-as-dashed-outline precedent bearish candles follow.
- `packages/core/src/charts/histogram.ts` — the S25 y-label + `toJSON`
  additive-facts pattern.
- `packages/core/README.md` → `### LOCKED: waterfall chart — session 26 design`
  — the written contract style to mirror.
- `design-reference/mudra-audit.md` §3.5 — directional mockup for tone
  semantics only (no per-chart mockup exists for these two; family vocabulary
  wins everywhere it differs).

## Open question for PLAN (not an assumption)

- Price-axis precision: the family rule is integer y-labels, but candlestick
  prices are intrinsically decimal. PLAN proposes the precision rule (e.g.
  ≤2dp, never float sprawl) and waits for approval — do NOT silently round
  prices to integers.

## Acceptance A — candlestick (testable, EARS-style)

1. WHEN `candlestick` renders, THEN kinds are tonal, never rainbow: up candles
   are solid fills on the grey tone ramp, down candles are the dashed outline
   (`┌╌╌┐` / `│  │` / `└╌╌┘`, waterfall language — direction survives
   `stripAnsi`); the peak candle (highest close, ties → first, the family
   peak rule) renders its body as solid `█` in the theme's accent hue, spent
   EXACTLY once. Wicks stay in the candle's own tone. No `theme.colors[i]`
   flood, ever. Verified at raw-ANSI level (accent only on solid `█` body
   segments plus non-block text; zero non-ramp/non-accent bar segments).
2. WHEN `candlestick` renders, THEN it carries the locked panel: dashed frame
   (`┌╌…╌┐` / `└╌…╌┘`), uppercase eyebrow (`OHLC`, or `opts.title`
   uppercased), compact y-labels with the `│`/`+` guide (PLAN's precision
   rule, never float sprawl), a dashed `└╌…╌` baseline, truncated period
   labels under their candles, and two `│ ╌…╌ │` rule separators. Panel
   width auto-expands (explicit `width` is a floor, min candle width keeps
   outlines legible).
3. WHEN the summary renders, THEN the foot row reports
   `N <n> · HI <v> · LO <v> · LAST <v>` with the `LAST` fact in the accent
   hue — facts true for the given data, never fabricated.
4. WHEN the input is degenerate, THEN it renders safely and honestly: empty
   data renders a framed `N 0 · (no data)` panel with null JSON facts (never
   a crash, never `-Infinity` widths); a flat range (all OHLC equal) renders
   visible candles (never `NaN` rows); non-finite OHLC values are excluded,
   never plotted; narrow widths never `RangeError`. No `NaN`/`Infinity`
   anywhere.
5. WHEN `toJSON()` is called, THEN it returns the original keys (`type`,
   `data`, `plain`) plus additive `count`, `high`, `low`, `last` (null when
   there is no data). No existing key is removed; the public
   `CandlestickOptions` shape is unchanged.
6. `packages/core/README.md` carries a `### LOCKED: candlestick chart —
   session 27 design` block stating the rules above (mirroring the S26
   blocks' style).

## Acceptance B — boxplot (testable, EARS-style)

7. WHEN `boxplot` renders, THEN groups are tonal, never rainbow: the peak
   group (highest median, ties → first, the family peak rule) renders box +
   whiskers + median in the accent hue, spent EXACTLY once; every other group
   sits on the grey tone ramp with its matching shade glyph by share of the
   peak median. The median marker stays visually distinct from the box edges.
   No `theme.colors[si % n]` rainbow, ever (raw-ANSI census).
8. WHEN `boxplot` renders, THEN it carries the locked panel: dashed frame, an
   uppercase `SPREAD` eyebrow (or `opts.title` uppercased), compact y-labels
   with the `│`/`+` guide, a dashed `└╌…╌` baseline, truncated group labels,
   and two rule separators. Width is a floor (auto-expand, never clip, never
   `RangeError` on narrow widths).
9. WHEN the summary renders, THEN the foot row reports
   `GROUPS <n> · MED <v> · PEAK <label> <v>` with the `PEAK` fact accented —
   facts true for the given data.
10. WHEN the input is degenerate, THEN empty renders a framed
    `GROUPS 0 · (no data)` panel with null `stats`/`peakGroup` facts (never a
    crash); single-value groups render safely (flat-range guard, never `NaN`);
    non-finite samples are excluded before `quartiles()`, never plotted.
    `toJSON()` keeps `data`/`labels`/`stats` plus additive `peakGroup`;
    `BoxPlotOptions` unchanged.
11. `packages/core/README.md` carries a `### LOCKED: boxplot chart — session
    27 design` block (S26 style).

## Acceptance C — gates

12. `scripts/verify-session-27.sh` exits 0 (candlestick tonal census +
    outline-downs proof, boxplot tonal census + median-marker proof, panel
    chrome on both, label-precision rule, feet formats, degenerate-safe incl.
    empty/flat/non-finite/narrow, source-locked across both, core tests +
    typecheck, both README blocks, docs drift gate, branch check) and
    `scripts/demo-session-27.sh` exits 0 with live renders + falsifiable
    checks.
13. Docs previews regenerate in sync (`gen:charts:check` green); the full core
    suite stays green; the rebuilt `dist/` carries both locks (the docs
    playground executes `dist`, not `src`); zero runtime deps.

## Founder amendment (2026-09-14, post-ACCEPT polish on the open PR branch)

On the docs playground the locked candle showed two defects, fixed by founder
direction ("fit + de-dupe"):

- Req 2's "truncated period labels" is amended: candles auto-fit the longest
  period label in full (4-wide floor kept) — ten distinct dates rendered as
  `Jan`/`Jan1` mush.
- Req 2's eyebrow ("`OHLC`, or `opts.title` uppercased") is amended: the eyebrow
  is always `OHLC`; the frame top alone carries `opts.title` (the title echoed
  on two rows).

## Session constraints (constitution)

- Two stories by founder direction (1-story rule waived, disclosed). Max 3
  files per atomic change (hook-enforced — commits need `VAJRA_ALLOW_COMMIT=27`,
  or gives an in-chat approval token per `CONSTRAINTS.yaml commit.approval_tokens`).
  No `main` commits (hook-enforced — branch `session-27-candlestick-boxplot` first).
  Verify exit 0 required. Independent cold fidelity review owed post-commit
  (`sessions/session-27-review.md`, per `reviewer/SKILL.md`) before ACCEPT.
  Open in a **new chat** (one session per chat).
