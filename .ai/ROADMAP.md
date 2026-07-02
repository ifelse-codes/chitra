# chitra — Working Roadmap

**Updated at every closeout.** North-star: *the best terminal chart lib ever created* —
zero-dep, AI-first, delightful. (Seeded S00, 2026-07-02.)

## Milestone (founder-chosen): Docs & examples
Make the library adoptable — a docs site that sells it and examples that teach it.

## Session 01 — Docs & examples kickoff
- [ ] Define concrete S01 deliverables (see `prompts/01-task-kickoff.md`)
- [ ] Audit `artifacts/chitra-docs/` — what renders today vs. what's stub/shadcn boilerplate
- [ ] Audit `examples/basic.ts` — coverage across all 20 chart types
- [ ] Pick the highest-leverage docs/examples slice for one atomic session

## Backlog (not yet scheduled)
- Real publishable build for `@chitra/core` (`dist/` bundle; current `build` is `tsc --noEmit`)
- `git init` + CI (workflows referenced in README don't exist yet) — unblocks Vajra branch/PR
- Flesh out `artifacts/api-server` beyond `/healthz` if the hosted API is pursued

## Guardrails carried forward (see [[knowledge]])
- Zero runtime deps · keep `toPlain()`/`toJSON()` agent output · 116 tests green ·
  public API stability.
