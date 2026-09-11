# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S21 closing, 2026-09-10.)

## Active Branch
`session-21-timeline-mudra` — S21 work complete on branch (main untouched; commits pending
founder env steps, exact commands in `sessions/session-21-summary.md`).

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **259/259 pass** (23 new timeline tests: accent
  census, chrome, footer, tie-break, user-color override, shade-ramp encoding,
  no-phantom-texture, point-event, collapsed range, backwards end, scale overrides,
  noColor, toJSON).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-21.sh` — **ALL GREEN (12 pass, 0 fail)**; `demo-session-21.sh` —
  exit 0, 5/5 live checks.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — no chart drift (previews in
  sync with the locked timeline render).
- `packages/core/dist/` rebuilt from S21 source (docs catalog executes examples against
  `dist/`).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families now: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), **timeline (S21)**.
- **timeline (S21)**: accent-once on the longest span (ties → first in event order), grey
  ramp + `░▒▓` shade texture by span bucket — the heatmap language, so the ordering
  survives noColor (no rainbow); dashed frame, `SPAN` eyebrow, `+╌…╌+` guide +
  `min..max` scale row, two rule separators; `─` track as the shared time scale; point
  events = one `░`; `▶`/`◀` retired; `n · min..max · span <label>` footer; collapsed-range
  guard; empty/degenerate safe. Contract block `### LOCKED: timeline chart — session 21
  design` in `packages/core/README.md`.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- **S21 review not yet on record** — the independent cold pass is owed post-commit (the
  ACCEPT attestation hashes the committed diff + prompt). Closeout runs after it lands.
- **No crew dispatch this session** (single-chat build): if the S139 required-crew gate
  flags it, the founder waiver covers it (disclosed in the summary, not hidden).
- `.ai/SESSION` advanced to 21 in this sync; closeout gate runs against N=21.
- The plan-review bug queue is still open: histogram decimal count labels + `theme.colors[0]`
  accent flood (`histogram.ts:55`), waterfall row-quantization hiding any sub-row delta
  (positive or negative), funnel `▼` arrows + rainbow (`funnel.ts:24`).
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `artifacts/api-server` exposes only `/healthz`.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN`).
- QA is local-only; not yet wired into CI.
- **S05 ground-truth remediation debt** still open.

## Milestones done
- **S01–S04** docs generator / examples / polish / README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG ·
  **S09** circular + area LOCKED · **S10** line LOCKED · **S11** catalog two-panel ·
  **S12** bar LOCKED · **S13** Darpan-parity chrome · **S14** URL routes + persistence ·
  **S15** scripted browser QA · **S17** scatter LOCKED · **S18** heatmap LOCKED ·
  **S19** horizontalBar LOCKED (Vajra S144 full-loop dogfood) · **S20** treemap LOCKED
  (recovered: pi + Command Code + closer chat) · **S21** timeline LOCKED (single-chat,
  plan-review cross-checked).

## What Is In Progress
- S21 closeout pending founder env steps: atomic commits (`VAJRA_ALLOW_COMMIT=21`, exact
  commands in the summary), post-commit cold review + attestation, closeout gate, PR to
  `main`. **Founder deferral:** plain-English footer redesign, family-wide (A trim /
  B plain words / B-diet) — one dedicated session, later. **Next session (S22 candidates):**
  `gauge` → `progress` mudra migration; the deferred footer pass; plan-review bug-first
  queue (histogram, waterfall, funnel); `lineModelToSvg` parity; real `v0.1.0` release;
  Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21: single
  ZCode chat (boot + plan + execute + verify + demo in one conversation), one cold-review
  subagent dispatched post-commit; dispatches kept narrow. Kept tight.
