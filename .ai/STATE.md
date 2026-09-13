# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S24 closing, 2026-09-13.)

## Active Branch
`session-24-docs-nav-groups` — S24 complete on branch: delivery + summary + cold
REJECT review (badge half, founder-waived) + closeout sync all committed; closeout
gate green with waiver; PR #26 to `main` is the last step.

## What Currently Works (observed, not claimed)
- Docs catalog sidebar: 20 charts in six generated groups (Trend & time 4 ·
  Comparison 4 · Distribution & density 3 · Part-to-whole 4 · Flow & accumulation 2 ·
  Single value & progress 3), collapsible headers with caret/count/glyphs,
  `localStorage` persistence across reload, auto-expand of the active group,
  expand-all/collapse-all. Zero status badges anywhere (founder direction — lock
  state is internal).
- `pnpm --filter @workspace/chitra-docs run typecheck` — **exit 0**; `gen:charts:check`
  — green (no hand-edits to generated files); `check:catalog` — **103/103**;
  `build` (PORT/BASE_PATH) — green.
- `scripts/verify-session-24.sh` — **ALL GREEN (12 pass, 0 fail)** (incl. S15
  `qa-catalog` suite on the new DOM); `demo-session-24.sh` — exit 0, 4/4 live
  checks; `qa-nav-groups.mjs` — 14/14 browser checks.
- `pnpm --filter @chitra/core run test` — **green** (core untouched by S24);
  `typecheck` — **exit 0**.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), **progress (S23)** — the founder-named trio complete.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- Cold fidelity review for S24 is REJECT (9/15 — the founder-removed badge half of
  the written prompt); closeout proceeds under founder waiver `VAJRA_CLOSEOUT_WAIVER=24`.
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
  plan-review cross-checked) · **S22** gauge LOCKED (single-chat, shade-texture ruling
  carried) · **S23** progress LOCKED (single-chat, trio complete) · **S24** grouped
  chart nav, badges out per founder order (single-chat, live glyph tuning).

## What Is In Progress
- S24 closeout final step: merge PR #26 `session-24-docs-nav-groups` → `main`.
  **Next (S25 candidates):** the footer pass (A/B/B-diet); plan-review bug queue
  (histogram, waterfall, funnel); `lineModelToSvg` parity; real `v0.1.0` release;
  Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S24:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  Kept tight.
