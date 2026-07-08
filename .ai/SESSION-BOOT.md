# Session Boot

## Current Session
- **Number:** 04
- **Type:** CODE
- **Branch:** `session-04-readme-getting-started` (from `main`)
- **Date last updated:** 2026-07-03

## Repo State Snapshot
- `.ai/SESSION` = 04.
- Remote: `github.com/ifelse-codes/chitra`. `main` has S00 baseline + S01 + S02;
  S03 docs polish is ready in PR form.
- S01 shipped the docs-from-lib generator: `artifacts/chitra-docs/scripts/chart-specs.ts`
  is the single source of truth for chart previews; `pnpm gen:charts` regenerates
  `src/data/{charts.ts,ansi-charts.json}`; `gen:charts:check` guards drift.
- S02 expanded `examples/basic.ts` with multi-series, theme tour, and AI-agent output.
- S03 polished the docs site IA/copy/navigation, fixed stale theme names, and added
  `scripts/verify-session-03.sh` + `scripts/demo-session-03.sh`.
- Milestone **Docs & examples**: S01 done → S02 examples → S03 docs polish → S04 README.

## Next Session
- **Read prompt:** `prompts/04-task-readme-getting-started.md` (to be created at kickoff)
- Open in a **new chat** (one session per chat).
