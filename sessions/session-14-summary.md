# Session 14 — Summary: real URL routes + boot-scoped editor persistence

**Branch:** `session-14-url-routes-persistence` (merged via PR #15, `e31b982`)
**Prompt:** `prompts/14-task-url-routes-persistence.md`

## What shipped

- **Real routes** — `wouter` replaces the `useState("home")` nav. Clicking a chart
  lands on `/chart/line` (etc.); docs pages live at `/install`, `/quickstart`,
  `/fluent-api`, `/ai-output`; refresh and browser back/forward work; unknown
  chart ids fall back home; all paths are `BASE_URL`-aware.
- **Boot-scoped persistence** — editor edits save to `localStorage` keyed
  `chitra-buffer:<boot-id>:<chart-id>`. The boot id is generated once per
  dev-server start and injected as `window.__CHITRA_BOOT_ID__` by a Vite
  `transformIndexHtml` plugin. Edits survive navigation away + refresh and are
  re-run on arrival; **Reset** clears the override; stale boots are pruned.
  Lifetime matches the founder's ask exactly: local until server restart.
- Implementation note: Vite's `define` did not inject in dev for this case — the
  inline HTML plugin approach was verified against the served page instead.

## Evidence

- `scripts/verify-session-14.sh` — **20/20 ALL GREEN** (routing wiring, store
  wiring, boot-id injection, executable behavior, core lock, branch).
- `scripts/demo-session-14.sh` — **exit 0**, cumulative S01–S14.
- `check:catalog` 103/103 · docs typecheck clean · core untouched (163/163).
- Founder-tested live on :5173 ("looks good and works good") before merge.

## Gaps disclosed

- No automated browser test drives the address bar / back-forward / restart
  lifetime interactively — those rest on founder live testing (same no-DOM-test
  gap carried from S11/S13).
- The route smoke (`curl /chart/* → 200`) proves SPA fallback only, not React
  render; render correctness rests on the evaluator checks + founder review.

## Next options

1. Scripted browser QA of all 20 catalog pages (closes the DOM-test gap).
2. Carry the reference-locked language into `sparkline`/`histogram`.
3. Exercise the real `v0.1.0` release (`NODE_AUTH_TOKEN`).
