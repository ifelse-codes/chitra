# Session Boot

## Current Session
- **Number:** 02
- **Type:** CODE
- **Branch:** `session-02-expand-examples` (from `main`)
- **Date last updated:** 2026-07-02

## Repo State Snapshot
- `.ai/SESSION` = 02.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00 baseline + S01 (PR #1).
- S01 shipped the docs-from-lib generator: `artifacts/chitra-docs/scripts/chart-specs.ts`
  is the single source of truth for chart previews; `pnpm gen:charts` regenerates
  `src/data/{charts.ts,ansi-charts.json}`; `gen:charts:check` guards drift.
- Milestone **Docs & examples**: S01 done → S02 examples → S03 docs polish → S04 README.

## Next Session
- **Read prompt:** `prompts/02-task-expand-examples.md`
- Open in a **new chat** (one session per chat).
