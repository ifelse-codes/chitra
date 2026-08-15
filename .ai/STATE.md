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
  runs chart code in-browser (the example runs as statements with `.render()` output captured from a mocked `process.stdout`; `process`
  mocked; errors caught). Toolbar: Run/Refresh, Copy ×2, Download ×2, Renderer
  (braille/blocks/ascii), Theme (7), Reset.
- **`line()` carries the S10 reference-locked look** — braille default, smooth
  Catmull-Rom splines, one-hue+grey tone-ramp, glyph markers, `·` grid opt-in,
  per-series `min/max/avg/last` summary rows. S09 LOCKED panel retained.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface; shared `LineChartModel` + `toSVG()`; dashboard panel options.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` wired.

## What Is Broken / Incomplete
- **No DOM/browser test exists.** The two-panel split, the vim chrome and the toolbar
  are still backed only by source greps (9 of 16 verify checks, now labelled
  `-SOURCE-GREP`) plus operator screenshots. This is the gap that let S11 close green
  over a page where 19 of 20 charts were broken.
- **`LINE_H` / `VIM_PAD` in `CatalogPage.tsx` duplicate CSS custom properties** with only
  a comment binding them — a CSS edit silently desyncs the current-line stripe and the
  block cursor. (The block cursor itself now SHIPS: a real 1ch overlay positioned from
  Ln/Col, native caret suppressed.)
- **data.ts tab**: regex-based extraction works for array-data charts but returns `[]`
  for object-array charts (scatter, candlestick). Informational only.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `bar`/`sparkline`/`histogram`/… still predate the reference-locked look.
- `artifacts/api-server` exposes only `/healthz` — no real API surface yet.
- **S05 ground-truth remediation debt** still open.
- First real release (tag `v0.1.0`) not yet exercised.
- The demo script's two ✗ marks were NOT cosmetic and the verify script was NOT
  authoritative — both claims are retired. Root cause: `cmd | grep -q` under
  `set -o pipefail` SIGPIPEs the producer and fails the pipeline. Fixed (capture,
  then grep). The demo can now fail: `fail()` is fatal, the summary rows are derived
  from the executable check, and the rows nothing verifies are labelled `unverified`.

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
