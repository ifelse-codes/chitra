# Session 02 — Expand examples (Docs & examples milestone, story 2 of 4)

## Goal (one story)
Deepen `examples/basic.ts` (and/or a new `examples/` file) so adopters see chitra's full
range: multi-series charts, every theme, and first-class AI-agent output. Keep it runnable
via `tsx`.

## Context (from S01)
- `@chitra/core` renders 20 chart types; `ChartResult` gives
  `render/toString/toPlain/toMarkdown/toJSON`.
- 7 themes: `default, nord, dracula, github-dark, tokyo-night, solarized, monochrome`
  (there is NO `neon` theme — S01 fixed a doc that referenced it).
- Single source of truth for docs previews: `artifacts/chitra-docs/scripts/chart-specs.ts`.
  Prefer reusing/extending it over re-authoring option objects.

## Suggested deliverables (refine at kickoff)
- Multi-series `line`/`bar` examples with `seriesLabels` + `legend`.
- A theme-tour example rendering one chart across all 7 themes.
- An AI-agent example: `noColor: true` + `toPlain()` / `toJSON()` shaped as an MCP tool result.
- Ensure examples are covered by (or referenced from) the demo; keep the lib's 116 tests green.

## Exit Criteria
- `scripts/verify-session-02.sh` exits 0 (extend the S01 checks).
- `scripts/demo-session-02.sh` shows the new examples (cumulative — includes S01).
- Session summary with 3 next options.

## Guardrails
- Branch `session-02-expand-examples` from `main`. Commits need approval token.
- Invariants: zero runtime deps · keep `toPlain()`/`toJSON()` · 116 tests green · public API
  stability. Max 2 assumptions; ≤3 files per atomic commit.
