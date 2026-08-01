# Session 08 — release.yml publish workflow (backlog, CI follow-up)

## Goal (one story)
Make `@chitra/core` releasable: a tag-push publish workflow that re-runs the S07 CI
gates, plus the rendering upgrades discovered while prepping the npm package —
line-chart quality, a shared renderer-neutral model with SVG output, and a
terminal-native dashboard look.

## Context (from S06/S07)
- S06 shipped a real publishable `dist/` (ESM + CJS + `.d.ts`, zero runtime deps).
- S07 landed `.github/workflows/ci.yml` (core · docs · chart-drift gates, pinned
  Node 26 / pnpm 9.12.3, frozen install).
- `lib/api-spec/openapi.yaml` `info.title` must stay `Api`; the repo is on
  `github.com/ifelse-codes/chitra`, remote `main` at S07 (PR #4).

## Deliverables
- `.github/workflows/release.yml` — fires on `v*` tag push only; runs the three S07
  CI gates as prerequisites of a `publish` job that builds dist and runs
  `pnpm --filter @chitra/core publish --access public --no-git-checks` with
  `NODE_AUTH_TOKEN`, pinned Node 26 / pnpm 9.12.3, frozen install.
- Line-chart rendering upgrade (SV-grade): ascii connected renderer, clean X-axis
  ticks, stable interpolation / axis baseline / gridlines, no string-injection hacks.
- Shared `LineChartModel` + `toSVG()` web renderer, exported from `@chitra/core`,
  with docs pages rendering real core SVG output.
- Terminal dashboard look for the line chart: dashed panel frame, top-right
  timestamp, legend, min/max/avg/last summary block, status footer
  (`timestamp` / `status` / `summary` options), auto terminal width.
- S08 verify and demo scripts; tests for the new line options stay green.

## Exit Criteria
- `scripts/verify-session-08.sh` exits 0 (15 checks).
- `scripts/verify-closeout.sh` exits 0 with a session-08-review.
- Core tests green (≥116), full-workspace typecheck and build exit 0.

## Guardrails
- Branch `session-08-release-workflow` from `main`.
- Commits need approval token (VAJRA_ALLOW_COMMIT=08).
- Invariants: zero runtime deps, AI-agent output surface (`toPlain()`/`toJSON()` +
  `noColor`) unbroken, public API stability, generated previews stay source-of-truth.
- Max 2 assumptions; <=3 files per atomic commit.

## Execution
1. release.yml workflow + verify/demo scripts — done: 4edbf9e (release.yml), 7551db0 (scripts)
2. Line-chart SV-grade upgrade + ascii renderer — done: 96ff0d7 (SV-grade), 264d3da (ascii renderer)
3. Shared LineChartModel + toSVG() web renderer + docs SVG output — done: 33fec84 (model+toSVG), 2a15e24 (docs SVG)
4. Dashboard panel look (timestamp / status / summary) + tests — done: f37f608 (panel), 07c9a5d (tests)
5. Closeout sync (.ai tracker) + fidelity review — done: 839b1f8 (contract; tracker/review commits follow)
