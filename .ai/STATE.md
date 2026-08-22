# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S15 closing, 2026-08-22.)

## Active Branch
`session-15-browser-qa` — S15 work pending PR.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **163/163 pass**.
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-15.sh` — **ALL GREEN (8 pass, 0 fail)**; `demo-session-15.sh` — exit 0.
- `check:catalog` — **103/103** catalog examples execute in-browser; docs typecheck clean.
- **Docs catalog chrome at Darpan parity**: toolbar on one control metric
  (24px/2px/mono); Run = Darpan `.btnPrimary` accent fill + ⌘↩ / Ctrl ↩ keycap;
  global cmd/ctrl+enter shortcut (window listener); squared uppercase status
  pills; uppercase ghost actions; inspector key/value terminal footer; dashed
  awaiting-run empty state; RUN FAILED chip banner. Parity layer carries the
  shipped white-alpha fg tiers (`oklch(1 0 0 / 0.92→0.36)`) read from Darpan's
  `theater-tokens.css` + live app, accent selection/focus, line-tinted scrollbars,
  JetBrains Mono first.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult`
  output surface; LOCKED families: circular (S09), line (S10), bar (S12).
- **URL-driven docs navigation + boot-scoped persistence (S14)**: `/chart/:id`
  routes for all 20 charts via wouter (refresh/back work, unknown ids fall home);
  editor edits persist across refresh/navigation until the dev server restarts
  (localStorage keyed by an injected per-boot id); Reset restores pristine.
- **Scripted browser QA (S15)**: Playwright drives Chromium through all 20 chart
  pages + 4 doc pages + home; asserts non-empty terminal output, zero console/page
  errors, Run shortcut re-renders, edit→navigate→back persistence smoke;
  screenshots + JSON artifacts under `.ai/verify/session-15/`. Verify/demo scripts
  accept `--headed` flag (default headless).
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` wired.

## What Is Broken / Incomplete
- `LINE_H` / `VIM_PAD` in `CatalogPage.tsx` still duplicate CSS custom properties
  with only a comment binding them.
- data.ts tab returns `[]` for object-array charts (scatter, candlestick). Informational only.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `sparkline`/`histogram` and other families still predate the reference-locked look (bar done S12).
- `artifacts/api-server` exposes only `/healthz`.
- **S05 ground-truth remediation debt** still open.
- First real release (tag `v0.1.0`) not yet exercised.
- Stale demo script: `demo-session-11.sh` still expects "148 passed"; suite is 163.
- QA is local-only; not yet wired into CI.

## Milestones done
- **S01** docs-from-lib generator · **S02** expanded examples · **S03** docs-site
  polish · **S04** README / getting-started · **S05** NO-CODE ground-truth ·
  **S06** real publishable dist · **S07** CI workflows · **S08** release.yml +
  line/SVG dashboard · **S09** circular charts LOCKED · **S10** line chart
  reference-locked · **S11** catalog two-panel page · **S12** bar chart LOCKED ·
  **S13** catalog chrome at Darpan parity (Run ⌘↩, canon tokens, inspector chrome) ·
  **S14** URL routes (`/chart/:id`) + boot-scoped editor persistence ·
  **S15** scripted browser QA of all 20 catalog pages.

## What Is In Progress
- Nothing mid-flight. **Next session (S16 candidates):** wire QA into CI; carry
  the reference-locked language into `sparkline`/`histogram`; exercise a real
  `v0.1.0` release. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood
  runs, billed to Vajra; S09–S15 in-repo).
