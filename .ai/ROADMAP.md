# chitra — Working Roadmap

**Updated at every closeout.** North-star: *the best terminal chart lib ever created* —
zero-dep, AI-first, delightful. (Seeded S00; sequenced S01, 2026-07-02.)

## Milestone: Docs & examples
- **S01** ✅ — Docs-from-lib generator (PR #1, squash `d4242d8`).
- **S02** ✅ — Expand examples (PR #3).
- **S03** ✅ — Polish docs site.
- **S04** ✅ — README / getting-started.

## Backlog (not yet scheduled)
- 🔜 **Next (Session 19 candidates):** carry the reference-locked language into the
  last unlocked families `sparkline`/`histogram`; bring `lineModelToSvg` fully in line
  with the terminal; exercise a real `v0.1.0` release (`NODE_AUTH_TOKEN`).
- ✅ **Session 18 (S18) — heatmap chart LOCKED:** `heatmap()` re-rendered in the
  reference/panel language — grey tone ramp (`#ECECEF→#6A6A75`, light→dark) as the
  intensity encoding replacing the old 10-colour rainbow (`HEAT_COLORS_DARK`); the
  single accent hue spent exactly once on the max-value cell (ties → first row-major);
  dashed frame, `DENSITY` eyebrow, `│`/`+` guide, two rule separators,
  `rows×cols · min..max · peak (r,c)` footer; empty/degenerate safe.
  `verify-session-18.sh` 8/8 ALL GREEN (core 192/192), demo exit 0, review ACCEPT
  (attested). See "LOCKED: heatmap chart" in `packages/core/README.md`. The locked
  family now spans circular, area, line, bar, scatter, and heatmap.
- ✅ **Session 17 (S17) — scatter chart reference-locked** (single-series peak accent,
  multi-series primary-group accent; dashed panel, eyebrow, `+`/`│` guide, `n·x·y·peak`
  footer). See "LOCKED: scatter chart" in `packages/core/README.md`.
- ✅ **Session 15 (S15) — scripted browser QA of all 20 catalog pages:** Playwright
  drives every `/chart/:id` + doc pages; non-empty terminal output, zero console/page
  errors, Run-shortcut re-render, persistence smoke. `verify-session-15.sh` 8/8 GREEN.
- ✅ **Session 14 (S14) — real URL routes + boot-scoped editor persistence:**
  wouter drives navigation (`/chart/:id` for all 20 charts, `/install`
  `/quickstart` `/fluent-api` `/ai-output`; refresh/back work; unknown ids fall
  home). Editor edits persist across refresh/navigation until the dev server
  restarts (localStorage keyed by an injected per-boot id); Reset restores
  pristine. PR #15. `verify-session-14.sh` 20/20 ALL GREEN, demo exit 0, review
  ACCEPT (attested).
- ✅ **Session 13 (S13) — docs catalog chrome at Darpan parity:** toolbar on one
  control metric; Run = Darpan `.btnPrimary` accent fill + ⌘↩ / Ctrl ↩ keycap;
  global cmd/ctrl+enter shortcut; white-alpha fg tiers ported from Darpan's
  `theater-tokens.css` after reading the real codebase + live app; uppercase
  chips, ghost actions, inspector kv footer, dashed empty state, RUN FAILED
  banner. PRs #12/#13. `verify-session-13.sh` 27/27 ALL GREEN, demo exit 0,
  review ACCEPT (attested).
- ✅ **Session 10 (S10) — line chart reference-locked (thin multi-series lines):**
  `line()` now matches the founder's `tui-chart (1).html` reference — every series a
  continuous thin braille line in its own colour, glyph markers on every series
  (`* ○ + × □`, every 2nd index), dotted `·` gridlines on y-step rows, per-series
  `min/max/avg/last` summary rows, primary keeps the LOCKED accent peak cap.
  `verify-session-10.sh` 24/24 ALL GREEN, 142 tests, demo exit 0. See "LOCKED: line
  chart" in `packages/core/README.md`.
- ✅ **Session 09 (S09) — circular charts LOCKED (pie/donut braille-dot look):** see the
  "LOCKED: circular charts" contract in `packages/core/README.md`. The braille
  sub-pixel circle + dashed panel + tone-ramp/one-accent + right legend is the
  official look — **every future chart rebuild should carry this exact look and
  feel**. Area chart locked to the same language too (line = fill top edge,
  accent only on the peak). Docs site updated (Cascadia Mono font stack for
  braille), handoff file at `scripts/ring-polish-handoff.mjs`, live preview at
  `/tmp/ring-lab/index.html`.
- ✅ **S06** — Real publishable `dist/` build for `@chitra/core` (ESM + CJS + `.d.ts`, zero deps).
- ✅ **S07** — CI workflows (`.github/workflows/ci.yml`: core · docs · chart-drift gates, pinned toolchain).
- ✅ **Session 08 (S08)** — release.yml publish workflow. v* tag push → re-runs S07
  gates → `pnpm publish --access public` with `NODE_AUTH_TOKEN`. Plus line-chart
  SV-grade upgrade, shared `LineChartModel` + `toSVG()` web renderer, docs SVG
  output, and the terminal dashboard panel (`timestamp`/`status`/`summary`).
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued.
- Exercise a real release: tag `v0.1.0` (needs `NODE_AUTH_TOKEN` secret in repo settings).
- S05 ground-truth remediation still open: S04 verify/demo/summary backfill + a closeout-integrity gate.

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · 142 tests green ·
  public API stability.
