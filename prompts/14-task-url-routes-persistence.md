# Session 14 — Real URL routes + boot-scoped editor persistence

**Branch:** `session-14-url-routes-persistence` (from `main`)
**Type:** CODE
**Session:** 14

## Goal

Founder direction, two requirements:

1. **Real routes** — clicking a chart must land on a URL that carries the page
   (`host:port/chart/line`), not stay on bare `host:port`. Refresh and browser
   back/forward must work.
2. **Local persistence** — any edit to the code/data in the catalog editor stays
   local across refreshes and navigation **until the dev server restarts**.

## Design

- Routing: `wouter` (already a dependency) replaces the `useState("home")` nav.
  Paths: `/chart/:id` for all 20 charts; `/install`, `/quickstart`, `/fluent-api`,
  `/ai-output`; `/` home. Unknown chart ids fall back home. All paths are
  `BASE_URL`-aware so non-root deploys keep working.
- Persistence: editor buffer overrides in `localStorage`, keyed
  `chitra-buffer:<boot-id>:<chart-id>`. The boot id is generated once per dev-server
  start and injected as `window.__CHITRA_BOOT_ID__` via a Vite
  `transformIndexHtml` plugin — so overrides live exactly until server restart,
  then are pruned. Reset clears a chart's override.

## Acceptance criteria

1. Clicking *line* shows `/chart/line` in the address bar; refresh/back work.
2. An edited buffer survives navigation away + refresh; Reset restores pristine.
3. Overrides do not survive a dev-server restart.
4. Catalog evaluator untouched: all examples still execute (`check:catalog` green).
5. Core untouched; typecheck clean.

## Plan

- Swap App nav to wouter location; add path→page resolver + href builder.
- Add `src/lib/bufferStore.ts`; wire load/save/clear into CatalogPage mount,
  onChange, Reset; boot-id plugin in `vite.config.ts`.

## Execution

- step 1 — real URL routes via wouter: done: ab8006a (PR #15)
- step 2 — boot-scoped editor persistence: done: c6d60d8 (PR #15)
