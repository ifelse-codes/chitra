# Session 33 — release readiness (CI browser QA · candle exclusivity · SVG parity · AI-data manual)

- **Type:** CODE. Branch `session-33-release-readiness` from `main@b66e8e9`.
- **Contract:** `prompts/33-task-release-readiness.md` (5 numbered reqs), from
  `jev-readiness-plan.md` items 1–4. Founder-waived multi-story session (four
  stories in one chat), disclosed like S26/S27.
- **Assumptions (max 2):** (1) SVG "parity" means reproducing terminal
  *semantics* (tones, markers, dash textures, grid, captions, accent-once) —
  not braille dot-for-dot, which SVG cannot draw; (2) the manual ships as a new
  `ai-data` docs route linked from the AI Agents page + core README.

## What shipped (Req 1–5)

- **Req 1 — CI browser QA.** New `browser-qa` job in `.github/workflows/ci.yml`:
  builds lib declarations + core dist, installs Playwright Chromium, runs
  `scripts/qa-catalog.mjs` (all 20 chart pages + docs + home, zero console/page
  errors). Wiring only — the suite already passed locally.
- **Req 2 — candle ties-first exclusivity.** New test in
  `tests/candlestick.test.ts` walks the raw ANSI by visible column and proves
  every accent `█` sits inside the FIRST tied candle's body span and none in the
  second tied candle's span.
- **Req 3 — SVG parity.** `createLineChartModel` now owns the canonical colour
  logic (`seriesColors`, `strokeSteps`, `style`, `noColor`, `grid`, `eyebrow`);
  the terminal renderer reads the same array. `lineModelToSvg` rewritten to
  mirror the terminal: theme tones (truecolor + xterm named → CSS), glyph
  markers every 2nd point, monochrome dash textures, `grid`-gated dotted
  gridlines, legend/eyebrow/footer captions, sparkline, and the accent spent
  once on the primary peak. `svg-charts.json` regenerated (terminal output
  byte-identical — drift check confirms). New drift test
  `tests/line-svg.test.ts` (7 tests) locks terminal↔SVG parity.
- **Req 4 — AI-data manual.** New `AiDataPage` (`ai-data` route) documents which
  feed to use, per-chart `toJSON()` shapes, null-on-empty + clamp-true-value
  behaviour, and the MCP untrusted-input guardrail. Linked from the AI Agents
  page and `packages/core/README.md`; added to the browser-QA doc-page list.
- **Req 5 — Gates.** `verify-session-33.sh` 17/17 ALL GREEN; demo exit 0. Core
  445→452 tests green; core + docs typecheck green; docs build green; chart
  drift gate green.

## Commits (all ≤3 files; approval-token gated)

## Review
- Cold independent review in `sessions/session-33-review.md`.
