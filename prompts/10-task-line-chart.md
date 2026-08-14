# Session 10 — reference-lock the line chart: thin multi-series lines (founder direction)

## Goal (one story)
The founder's reference `/Users/suman/Downloads/tui-chart (1).html` is a classic
terminal multi-series chart: continuous colored lines, glyph markers (`* o + x`) at
data points, a `─ glyph ─ name` legend, dashed gridlines, and a per-series
MIN/MAX/AVG/LAST summary. Rebuild `line()` so the terminal braille/ascii output
matches that reference, and LOCK it.

## Context
- S09 locked the panel language (dashed frame `┌╌…╌┐`, eyebrow, `│` y-guide, one
  accent spent once, tone ramp, empty cells = spaces, never blank-braille U+2800).
- S10 had already rebuilt `line()` to a **filled diagram** primary (option C) plus
  dash-pattern secondaries; the founder said dashes at braille resolution were not
  legible, and the final decision was made against the `tui-chart (1).html` reference.
- The shared `LineChartModel`/`lineModelToSvg` already draws dashed gridlines,
  continuous polylines, and glyph markers at every 2nd point — the terminal renderer
  lags it.

## Deliverables
- **Every series is a continuous thin braille line** (sub-pixel, interpolated via
  `plotLineOnBrailleCanvas`), each in its own colour — primary on the tone ramp,
  extras from the theme palette. No filled diagram.
- **Every series drops its glyph marker at data points** (`* ○ + × □`, every 2nd
  index, matching the SVG). The primary keeps the LOCKED 3-dot accent peak cap,
  and the cap outranks markers so the single accent stays clean.
- **Dashed (dotted `·`) gridlines** on the y-step rows in the grid colour — series
  cells and markers always outrank them; top/base rows stay clean.
- **Per-series summary rows**: `marker name · min N · max N · avg N · last N` for
  every series (replaces the single footer line); the primary's `max` stays accent.
- **Block/ascii renderer**: draw every series as a thin `/\-` line (ascii) or `●`
  (blocks) + markers every 2nd point + cap + gridlines — drop the thick `●`-only
  primary holdover.
- **LOCKED contract recorded** in `packages/core/README.md` (thin lines + glyph
  markers + gridlines + per-series stats); synced into `.ai/KNOWLEDGE.md`.
- Tests updated (markers on every series, gridlines, per-series stats); docs gallery
  regenerated; verify/demo scripts updated; session 10 summary.

## Exit Criteria
- `scripts/verify-session-10.sh` exits 0 (24 checks, ALL GREEN).
- `scripts/demo-session-10.sh` exits 0.
- `scripts/verify-closeout.sh` exits 0 with a session-10 review.
- Core tests green (142), `pnpm --filter @chitra/core run typecheck` exit 0, `docs-drift` green.

## Guardrails
- Branch `session-10-line-locked` from `main`.
- Commits need approval token (`VAJRA_ALLOW_COMMIT=10`).
- Invariants: zero runtime deps, AI-agent output surface (`toPlain()`/`toJSON()` +
  `noColor`) unbroken, public API stability, generated previews stay source-of-truth.
- Max 2 assumptions; ≤3 files per atomic commit.
