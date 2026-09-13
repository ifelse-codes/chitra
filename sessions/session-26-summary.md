# Session 26 Summary — waterfall + funnel + sankey + radar LOCKED to the mudra panel language

**Status:** SHIPPED (2026-09-13) — delivery + gates green on branch
`session-26-waterfall-mudra`; commits + cold review + closeout owed (constitution:
no autonomous commits).
Verify: `scripts/verify-session-26.sh` — **24/24 ALL GREEN**. Demo:
`scripts/demo-session-26.sh` — **exit 0, 9/9 PASS**. Core suite 391/391
(+19 waterfall, +14 funnel, +12 sankey, +14 radar tests), typecheck exit 0,
docs drift gate green, docs typecheck exit 0, `dist/` rebuilt (docs playground
executes `dist`, not `src`) and the docs dev server restarted on :5173.

## What was asked

Founder choice for S26 (in-chat): **waterfall** — then a mid-session scope
expansion (in-chat): **"do funnel and sankey now in this session, don't wait
for next session."** The 1-story/session rule is waived by explicit founder
direction (disclosed here). Funnel follows the audit queue (§3.4); sankey has
no audit mockup — the family language applied by analogy. Fidelity map
(waterfall rows 1–9 as before, plus):

| # | Requirement | Evidence |
|---|---|---|
| 1–9 | Waterfall lock (P0 outlines, tonal kinds, panel, foot, degen, steps, README, gates, docs) | 14/14 green at landing; still green, SHIPPED |
| 10 | Funnel: no ▼, CENTERED silhouette, peak accent once, ramp + ▓ caps, no rainbow | Census accent ×1, 0 leaks, SHIPPED (audit §3.4 item 2 REVERSED — see below) |
| 11 | Funnel panel: frame, CONVERSION eyebrow, integer pcts, IN/OUT/DROP foot | SHIPPED |
| 12 | Funnel degen + additive conversion/biggestDrop, API unchanged | SHIPPED |
| 13 | Sankey: no ▶, peak-flow accent once, toned ledger, no rainbow | Census accent ×1, 0 leaks, SHIPPED |
| 14 | Sankey panel: frame, FLOW eyebrow, PEAK foot, empty-safe + peakFlow | SHIPPED |
| 15 | Radar: primary-series accent once, toned secondaries + own glyphs, no rainbow | Census accent ×N, 0 leaks, SHIPPED |
| 16 | Radar panel: frame, AXES eyebrow, legend, AVG/PEAK foot, unclipped labels, degen-safe + max/avg | SHIPPED |
| 17–19 | README ×4 blocks, verify 24/24, demo 9/9, docs + dist + zero deps | SHIPPED |

## What changed (7 modified + 9 new, all uncommitted)

- `packages/core/src/charts/waterfall.ts` — full re-render (see contract for the
  rules). Row rounding (not truncation) gives every non-zero bar ≥1 row.
  `positiveColor`/`negativeColor`/`totalColor` stay accepted as user overrides
  of the locked tones (gauge-threshold precedent); glyphs never change.
- `packages/core/src/charts/funnel.ts` — full re-render: dashed frame,
  `CONVERSION <pct>%` eyebrow, no `▼`, CENTERED rows (audit §3.4 item 2
  reversed — see reversal section), peak stage solid `█`
  accent (ties → first), descending grey ramp + `░▒▓` + `▓` end-cap per other
  stage, integer pcts, `IN · OUT · CONVERSION · DROP` foot (conversion
  accented). Empty → `STAGES 0 · (no data)`; zero-first → `n/a` conversion.
  `toJSON()` additive `conversion`/`biggestDrop`.
- `packages/core/src/charts/sankey.ts` — full re-render: dashed frame,
  `FLOW <total>` eyebrow, no `▶`, peak flow solid `█` accent, other flows ramp
  + `░▒▓` proportional widths, toned `■` node ledger (ranked by flow) with
  `in:`/`out:` facts, `NODES · LINKS · PEAK` foot (peak accented). Empty →
  `NODES 0 · (no data)`. `toJSON()` additive `peakFlow`.
- `packages/core/src/charts/radar.ts` — full re-render from a founder-supplied
  reference image (first cut's dotted circles rendered as scattered noise —
  rejected live): five dashed HEX rings (20–100%) with `+` ticks and dashed
  spokes, `0..<max>` scale in the eyebrow, primary series with slope-aware
  thin edges (`─ │ ╲ ╱`), checkerboard `·` stipple fill and solid `●`
  vertices in accent, secondaries dashed/dotted in grey tones with hollow `○`
  and no fill, `● ── / ○ ╌╌` legend, `AVG · PEAK` foot (peak accented), label
  margin beside the web. Empty → `AXES 0 · (no data)`; negatives/non-finite
  collapse to center. `toJSON()` additive `max`/`avg`.
- `packages/core/tests/{waterfall,funnel,sankey,radar}.test.ts` — NEW, 19 + 14
  + 12 + 14 tests.
- `packages/core/README.md` — four `LOCKED — session 26 design` blocks.
- `scripts/verify-session-26.sh` (24 checks), `scripts/demo-session-26.sh`
  (9 live checks) — NEW, extended past each landing.
- `artifacts/chitra-docs/src/data/{charts.ts,ansi-charts.json}` — regenerated
  previews (drift gate green); `packages/core/dist/` rebuilt (playground runs
  dist).

## Assumptions (3, disclosed — max 2 per story, listed per lock)

1. Waterfall: family vocabulary wins where the mockup differs (per S25 + plan
   approval); scope was waterfall-only at plan time.
2. Funnel: peak-stage accent (family peak rule, ties → first); Start/Total
   share nothing here — funnel's accent is the max stage wherever it sits.
3. Sankey (no audit mockup — analogy disclosed): `▶` deleted as decoration
   (same ruling as funnel's `▼`); direction reads left-to-right; ledger `■`
   marks toned by flow rank.

## Founder-ordered funnel reversal (audit §3.4 item 2, disclosed)

- Shipped centered first per the audit (left-anchored rows); founder rejected
  it live ("looks like a horizontal bar chart — make it look like a funnel").
- Research (ECharts, PowerBI, Highcharts, Evidence, Atlassian, Wikipedia,
  data-storytelling literature) is unanimous: the centered symmetric
  top-wide → bottom-narrow silhouette IS the funnel identity; centered boxes
  (not tapered slopes) are the recommended honest balance. Left-aligned is a
  vendor option everywhere, the default nowhere.
- Reversed: bars center in a shared field; labels stay in a fixed left column
  (keeps the audit's row-scanning concern). README + prompt + verify carry the
  reversal note. Verify 21/21 + demo 8/8 re-greened after the change.

## Gates caught during verification (fixed, never hand-waved)

1. Waterfall landing: the first tonal census counted axis-coloured frame chrome
   (`│`/`└╌` ride `theme.axis`) as "other" bars — 52 false leaks. Scoped the
   census past axis segments (axis colour is never bar mass).
2. Radar rebuild (design, founder-driven): the first locked cut (dotted
   rings + `*` edges) rendered as scattered dots at playground size — rejected
   live. Founder supplied a reference image; rebuilt on its grammar (dashed
   hex rings, + ticks, solid filled primary, dashed hollow secondary, scale
   in eyebrow after in-web numbers collided). Two census scopings followed
   the wider glyph set (foot `·` separators, then alphanumeric text runs —
   drawing cells never carry letters). The RENDER was right after the
   rebuild; the censuses were over-broad.
3. Funnel tests (2, test-side — pre-reversal): the left-anchor probe matched
   the foot's `DROP Enterprise` line (no bar glyphs) — filtered to bar rows; the foot-accent
    probe matched the eyebrow's `CONVERSION` line first — scoped to the `IN `
    foot line. The RENDER was never wrong in any of the three.

## Owed (process facts a diff cannot carry)

- Founder commit (constitution: no autonomous commits) → then the independent
  cold review (`reviewer/SKILL.md`, `sessions/session-26-review.md` + attested
  `Review-Inputs-SHA`) — same sequence as S25.
- Closeout (STATE/TASK/SESSION-BOOT/ROADMAP sync + `verify-closeout.sh`) after
  review, per the session loop. Then PR to `main`.
- After this, every audit-queued chart is locked; remaining backlog: the
  founder-deferred footer pass, `lineModelToSvg` parity, `v0.1.0` release,
  Playwright QA into CI.

## Founder commit commands (paste, or give an in-chat approval token)

Contract: `prompts/26-task-waterfall-mudra.md` (one of the two cold-review
inputs, extended for funnel + sankey). Atomic, ≤3 files each:

```bash
V=26; cd /Users/suman/playground/chitra && git checkout session-26-waterfall-mudra
git add packages/core/src/charts/waterfall.ts packages/core/tests/waterfall.test.ts packages/core/src/charts/funnel.ts && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: lock waterfall + funnel renders"
git add packages/core/src/charts/sankey.ts packages/core/tests/funnel.test.ts packages/core/tests/sankey.test.ts && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: lock sankey render + funnel/sankey tests"
git add packages/core/src/charts/radar.ts packages/core/tests/radar.test.ts && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: lock radar render + tests"
git add packages/core/README.md artifacts/chitra-docs/src/data/charts.ts artifacts/chitra-docs/src/data/ansi-charts.json && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: README locks + regenerated docs previews"
git add scripts/verify-session-26.sh scripts/demo-session-26.sh prompts/26-task-waterfall-mudra.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: verify + demo + prompt"
git add sessions/session-26-summary.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S26: summary"
```

Then (agent runs these once the commits land): independent cold review
(`sessions/session-26-review.md`) → closeout commits (`.ai/SESSION` → 26,
SESSION-BOOT, TASK, STATE, ROADMAP) → `scripts/verify-closeout.sh` → PR to
`main`. Never commit `.commandcode/`, `.freebuff/`,
`command-code-session-*.html`, `design-reference/` (untracked scratch).
`packages/core/dist/` is git-ignored (rebuilt locally for the playground only).
