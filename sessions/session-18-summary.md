# Session 18 — heatmap chart LOCKED to the reference/panel language

**Type:** CODE · **Branch:** `session-18-heatmap-lock` · **Date:** 2026-09-01

## What shipped
The `heatmap` chart now carries the same locked design language as the circular (S09),
area (S09), line (S10), bar (S12), and scatter (S17) families:

- **Grey-ramp intensity.** The 10-colour blue→orange→red rainbow (`HEAT_COLORS_DARK`) is
  gone. Cell magnitude is encoded on the documented grey tone ramp
  `#ECECEF → #C6C6CE → #A4A4AE → #6A6A75` (light→dark), with a matching plain-text shade
  glyph (`░ ▒ ▓ █`) so the ordering survives `stripAnsi` / `noColor`.
- **One accent, spent exactly once,** on the maximum-value cell (ties → first in
  row-major order, deterministic).
- **Full panel chrome:** dashed frame, uppercase `DENSITY` eyebrow, `│`/`+` y-guide, two
  `│ ╌…╌ │` rule separators, and a `rows×cols · min..max · peak (r,c)` footer with the
  peak coords in the accent hue.
- **Degenerate data is safe:** empty grid → framed `n 0`, no Infinity/NaN; all-equal grid
  → collapsed range, accent still spent once.

## Files changed
- `packages/core/src/charts/heatmap.ts` — the locked renderer.
- `packages/core/tests/heatmap.test.ts` — 15 falsifiability tests (raw-ANSI accent-once
  census, ramp pinned to literal spec hexes, row-anchored guide, empty/all-equal/ragged).
- `artifacts/chitra-docs/scripts/chart-specs.ts` + regenerated `charts.ts` /
  `ansi-charts.json` (derived, via `pnpm gen:charts`).
- `packages/core/README.md` — `### LOCKED: heatmap chart — session 18 design` block.

## Verify + demo
- `scripts/verify-session-18.sh` — **8/8 ALL GREEN** (core tests 192/192, core typecheck,
  heatmap tests, no-rainbow-in-source, README lock block, docs typecheck, chart-drift
  gate, branch).
- `scripts/demo-session-18.sh` — exit 0; renders the locked panel (before/after + empty +
  all-equal) through the real source.
- `sessions/session-18-review.md` — independent cold pass, **Verdict: ACCEPT** (attested,
  7/7 SHIPPED).

## Advisors dispatched
- **tech-lead** (mandatory first dispatch) — marked implementation/qa/demo/fidelity
  required; front-of-pipeline roles budget-deferred ($20/mo plan).
- **fidelity-reviewer** — cold pass, ACCEPT; flagged two "fakest-green" gaps + a ragged-row
  hole, all closed in commit `e2b6bb9`.

## Next session — 3 options
1. **Carry the locked language into `sparkline` / `histogram`** — the last unlocked chart
   families (roadmap backlog; prompt `16-task-sparkline-histogram-lock.md` already drafted).
2. **Bring `lineModelToSvg` to terminal parity** — the SVG renderer still does not mirror
   the terminal 1:1.
3. **Exercise a real `v0.1.0` release** — tag + `NODE_AUTH_TOKEN`, the still-unexercised
   publish path.
