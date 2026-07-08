# Session 03 — Polish docs site (Docs & examples milestone, story 3 of 4)

## Goal (one story)
Improve copy, information architecture, and navigation on the docs site in
`artifacts/chitra-docs`, now that chart previews are generated from the real
`@chitra/core` library.

## Context (from S01/S02)
- S01 made docs previews generated from `artifacts/chitra-docs/scripts/chart-specs.ts`.
- S02 expanded `examples/basic.ts` with multi-series charts, every theme, and AI-agent output.
- Valid themes are `default, nord, dracula, github-dark, tokyo-night, solarized, monochrome`.
  There is no `neon` theme.

## Deliverables
- Sharpen docs-site IA so the first screen points clearly to install, first chart, gallery, and AI output.
- Fix docs copy that references invalid themes or stale API examples.
- Improve navigation labels and chart detail pages so users can scan use cases, preview, code, and options.
- Keep all chart previews generated; do not hand-edit generated chart data.
- Add S03 verify and demo scripts.

## Exit Criteria
- `scripts/verify-session-03.sh` exits 0.
- `scripts/demo-session-03.sh` shows the polished docs flow.
- Docs app typechecks/builds and generated chart data has no drift.

## Guardrails
- Branch `session-03-polish-docs` from `main`.
- Commits need approval token.
- Invariants: zero runtime deps, generated previews stay source-of-truth, public API stability.
- Max 2 assumptions; <=3 files per atomic commit.
