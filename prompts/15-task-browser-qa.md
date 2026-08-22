# Session 15 — Scripted browser QA of all 20 catalog pages

**Branch:** `session-15-browser-qa` (from `main`)
**Type:** CODE
**Session:** 15

## Goal

Close the no-DOM-test gap disclosed since S11: prove in a real browser that every
catalog page actually renders and works — the class of failure that let S11 close
green while 19 of 20 charts were broken.

## Design

- A Playwright-driven QA script (`scripts/qa-catalog.mjs`, Playwright already a
  known dev tooling choice) that:
  1. Boots the docs dev server (or reuses `vite build` + preview).
  2. Visits `/chart/<id>` for all 20 chart ids and the 4 doc pages + `/`.
  3. On each catalog page: waits for the terminal panel to produce output,
     asserts non-empty rendered output, presses the global Run shortcut
     (`Meta+Enter` / `Control+Enter`) and asserts a re-run, captures console
     errors and page errors.
  4. Persists per-page artifacts: screenshot + a JSON record
     (url · output-length · console-error count · ms) under
     `.ai/verify/session-15/<ts>/`.
- A runner script `scripts/verify-session-15.sh` executes the QA suite plus the
  standing gates (typecheck, `check:catalog`, core tests, core unchanged) and
  exits non-zero on any page failure — fail-closed like every verify script.
- Route/persistence regressions from S14 are in scope: `/chart/:id` must render
  (not just SPA-fallback 200), and an edit → navigate → return cycle must restore
  the edited buffer.

## Acceptance criteria

1. All 20 chart pages render visible terminal output with zero console/page errors.
2. Doc pages (`/`, `/install`, `/quickstart`, `/fluent-api`, `/ai-output`) load clean.
3. Global run shortcut re-renders on at least one page (representative sample OK
   for the interaction check; rendering checks cover all 20).
4. Persistence smoke passes on one chart (edit → navigate away → back → buffer kept).
5. Artifacts (screenshots + JSON records) are written and committed or gitignored
   deliberately.
6. Standing gates stay green; `packages/core` untouched.

## Plan

- Add Playwright as a docs dev dependency (or root), install chromium.
- Write the QA script + wire into verify-session-15.sh + demo-session-15.sh.
- Run, fix anything it catches, closeout as usual.

## Execution

- step 1 — pending
