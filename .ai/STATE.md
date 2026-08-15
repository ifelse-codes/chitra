# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S11 closing, 2026-08-15.)

## Active Branch
`session-11-catalog-two-panel` (from `main`) — complete, ready for founder browser review.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **148/148 pass** (7 files, incl. 24 line tests).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-11.sh` — **ALL GREEN (14 pass, 0 fail)**; `demo-session-11.sh` — exit 0.
- **Docs catalog page** (`artifacts/chitra-docs`): all 20 chart pages now render a
  two-panel interactive layout — vim-styled editable editor (left) + terminal preview
  (right). `@chitra/core` is bundled into the Vite build; `new Function` evaluator
  runs chart code in-browser (`.render()` transformed to `.toString()`; `process`
  mocked; errors caught). Toolbar: Run/Refresh, Copy ×2, Download ×2, Renderer
  (braille/blocks/ascii), Theme (7), Reset.
- **`line()` carries the S10 reference-locked look** — braille default, smooth
  Catmull-Rom splines, one-hue+grey tone-ramp, glyph markers, `·` grid opt-in,
  per-series `min/max/avg/last` summary rows. S09 LOCKED panel retained.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface; shared `LineChartModel` + `toSVG()`; dashboard panel options.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` wired.

## What Is Broken / Incomplete
- **Catalog block cursor**: the brief specifies a pixel-exact block cursor; shipped is
  amber `caret-color` (I-beam) with modeline mode badge. Close enough for MVP; exact
  block cursor requires JS-based position overlay.
- **data.ts tab**: regex-based extraction works for array-data charts but returns `[]`
  for object-array charts (scatter, candlestick). Informational only.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `bar`/`sparkline`/`histogram`/… still predate the reference-locked look.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- **S05 ground-truth remediation debt** still open.
- First real release (tag `v0.1.0`) not yet exercised.
- Demo script has two cosmetic greedy-string-match false-fails in non-TTY mode;
  verify script is authoritative and all green.

## Milestones done
- **S01** docs-from-lib generator · **S02** expanded examples · **S03** docs-site
  polish · **S04** README / getting-started · **S05** NO-CODE ground-truth · **S06**
  real publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG
  dashboard · **S09** braille-dot circular charts LOCKED (pie/donut/area) · **S10**
  line chart reference-locked (thin multi-series lines + glyphs + gridlines +
  per-series stats) · **S11** catalog two-panel page (vim editor + terminal preview +
  live in-browser evaluator).

## What Is In Progress
- Branch `session-11-catalog-two-panel` awaiting founder browser review. **Next session
  (S12 candidates):** browser QA + polish; carry reference-locked look into
  `bar`/`sparkline`/`histogram`; SVG renderer alignment. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood
  runs, billed to Vajra; S09/S10/S11 in-repo).
