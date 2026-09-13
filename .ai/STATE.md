# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S25 closing, 2026-09-13.)

## Active Branch
`session-25-histogram-mudra` — S25 complete on branch: delivery + summary + cold
ACCEPT review (attested) + closeout sync all committed; closeout gate green with the
crew waiver; PR to `main` is the last step.

## What Currently Works (observed, not claimed)
- **`histogram()` (S25)**: locked panel language — dashed frame + `DISTRIBUTION`
  eyebrow, one accent spent exactly once as a solid `█` on the mode bin (ties →
  first), grey tone ramp + `░▒▓` shade texture by share of modal count (survives
  noColor), integer-only y-axis count labels, dashed baseline, bin-start labels,
  `n · mode · p50 · p99` foot (nearest-rank, mode accented). Empty → framed
  `n 0 · (no data)` with null JSON facts; collapsed range → bin 0; non-finite
  samples excluded, never binned. Explicit `width` is a floor. `toJSON()` additive
  `mode`/`p50`/`p99`/`count`.
- Docs previews for the histogram regenerated (drift gate green); docs typecheck
  exit 0; standalone docs-site build verified serving the S25 render in both the
  catalog card and the live `tsx` playground.
- `scripts/verify-session-25.sh` — **ALL GREEN (13 pass, 0 fail)**;
  `scripts/demo-session-25.sh` — exit 0, **7/7 PASS**.
- `pnpm --filter @chitra/core run test` — **332/332 green** (+23 new histogram
  tests); `typecheck` — exit 0.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), **histogram (S25)** — 12 locked.
- **Docs catalog + browser QA (S13–S15, S24)**: Darpan-parity chrome, `/chart/:id`
  routes, boot-scoped editor persistence, grouped sidebar with collapse/persist,
  Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- The plan-review bug queue is still open: **waterfall** row-quantization hides any
  sub-row delta and **funnel** still carries the `▼` arrows + rainbow (`funnel.ts:24`)
  — both are the audit's remaining unlocked charts and the natural S26 target.
- The founder-deferred footer pass (A trim / B plain words / B-diet) awaits a
  founder choice.
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
  chart nav, badges out per founder order (single-chat, live glyph tuning) ·
  **S25** histogram LOCKED (single-chat, resumed from a z-code token stop; commits +
  review + closeout completed in the closer chat).

## What Is In Progress
- S25 closeout final step: merge PR `session-25-histogram-mudra` → `main`.
  **Next (S26 candidates):** the audit queue's remaining unlocked charts (funnel,
  waterfall); the footer pass (A/B/B-diet, founder choice); `lineModelToSvg` parity;
  real `v0.1.0` release; Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S25:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + cold review + closeout). Kept tight.
