# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S10 closing, 2026-08-05.)

## Active Branch
`session-10-line-locked` (from `main`) — ready to PR. Remote: `github.com/ifelse-codes/chitra`.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **148/148 pass** (7 files, incl. 24 line tests).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-10.sh` — **ALL GREEN (28 pass, 0 fail)**; `demo-session-10.sh` — exit 0.
- **`line()` carries the S10 reference-locked look** (founder's `tui-chart (1).html`),
  refined so it reads as one family with the LOCKED pie/donut/area charts:
  **braille is the default renderer**; every series is a **smooth continuous curve**
  (Catmull-Rom spline resampled one point per dot-column, `smooth: false` to disable);
  colour follows the **one-hue + grey tone-ramp** language — a lone line keeps the grey
  body with the accent spent once on its peak, and with several series the primary is the
  accent hero while extras recede onto the grey ramp, identity carried by the glyph markers
  (`* ○ + × □`). The dotted `·` grid backdrop is **off by default** (`grid: true` to opt in).
  Per-series `min/max/avg/last` summary rows (primary `max` in accent), `+` x-ticks, and the
  LOCKED S09 panel (dashed frame, eyebrow, `│` y-guide, empty cells = spaces) all retained.
  Block/ascii remain plain-terminal fallbacks.
- The three verify smoke checks genuinely run tsx (heredoc bug fixed) and self-clean.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface; shared `LineChartModel` + `toSVG()`; dashboard panel options.
- **Docs** (`artifacts/chitra-docs`): chart pages render real core SVG output;
  `gen:charts:check` drift gate green.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` wired; `.ai/hooks/*` committed.

## What Is Broken / Incomplete
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1 (series colours are
  parsed from ANSI, no `+` x-tick marks, no per-series stat boxes).
- `bar`/`sparkline`/`histogram`/… still predate the reference-locked look.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- **S05 ground-truth remediation debt (still open):** S04 verify/demo/summary backfill
  and a closeout-integrity gate remain.
- First real release (tag `v0.1.0`) not yet exercised — needs `NODE_AUTH_TOKEN`
  secret in repo settings.

## Milestones done
- **S01** docs-from-lib generator · **S02** expanded examples · **S03** docs-site
  polish · **S04** README / getting-started · **S05** NO-CODE ground-truth · **S06**
  real publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG
  dashboard · **S09** braille-dot circular charts LOCKED (pie/donut/area) · **S10**
  line chart reference-locked (thin multi-series lines + glyphs + gridlines +
  per-series stats).

## What Is In Progress
- PR for `session-10-line-locked` → `main` (S10 closeout). **Next session (founder
  direction):** carry the reference-locked look into the remaining chart families and
  align the SVG web renderer. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood
  runs, billed to Vajra; S09/S10 in-repo).
