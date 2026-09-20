# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S29 done, 2026-09-20.)

## Active Branch
`session-29-footer` — S29 delivery complete on branch: B-diet+ footers +
1 rule on all 20 charts (18 atomic commits) + verify 12/12 + demo 4/4 +
cold ACCEPT 8/8 (attested). PR to `main` to go.

## What Currently Works (observed, not claimed)
- **B-diet+ footers (S29)**: plain-words takeaway feet on all 20 charts
  (`N events · longest L`, `N items · peak L (max)`,
  `N readings · peak P`, `V of A..B · P%`, `N samples · peak M`,
  `R×C grid · peak (r,c)`, `N points · peak (x,y)`,
  `N leaves · peak L`, bar `name · avg C · peak B`, line/area
  `lowest/highest`, radar `average A · peak L (V)`,
  `N candles · high H · low L · last X`,
  `G groups · median M · peak L (V)`; pie/donut/waterfall/funnel/sankey
  already plain). One `│ ╌…╌ │` rule per panel (donut was already
  single-rule, no footer — exempt by design, test-locked). Accent still
  once on the takeaway; ties-first unchanged; plain-noun empties with
  null facts; `toJSON()`/`toContent()`/compact untouched.
- `scripts/verify-session-29.sh` — **ALL GREEN (12 pass, 0 fail)**;
  `scripts/demo-session-29.sh` — exit 0, **4/4 PASS**.
- `pnpm --filter @chitra/core run test` — **444/444 green**;
  `typecheck` — exit 0; docs drift gate green; `dist/` rebuilt (gitignored).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), histogram (S25), waterfall + funnel + sankey +
  radar (S26), candlestick + boxplot (S27), sparkline (S28) — all wearing the
  S29 B-diet+ footer/chrome.
- **Docs catalog + browser QA (S13–S15, S24)**: Darpan-parity chrome, `/chart/:id`
  routes, boot-scoped editor persistence, grouped sidebar with collapse/persist,
  Playwright QA across all 20 pages. S29 previews regenerated (drift gate
  green; footer-only diff). Docs app serves at `PORT=5174 BASE_PATH=/`
  (`pnpm --filter @workspace/chitra-docs run dev`).
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- S29 PR + merge still to go (this session).
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
  review + closeout completed in the closer chat) ·
  **S26** waterfall + funnel + sankey + radar LOCKED (five stories by founder
  direction; funnel centered by founder order on research record; radar from a
  founder reference image — cold ACCEPT 18/19, row 15 PARTIAL disclosed) ·
  **S27** candlestick + boxplot LOCKED (two stories by founder direction; no audit
  mockups — family language by analogy, waterfall outline precedent; adaptive price
  precision approved at PLAN — cold ACCEPT 13/13, attested) ·
  **S28** sparkline LOCKED (v8 shape+shade prototype approved in-chat; no audit
  mockup — family language by analogy, heatmap-strip + histogram-peak playbooks;
  cold ACCEPT 9/9, attested) ·
  **S29** family-wide footer pass B-diet+ (founder ballot pick on real renders;
  closes the S21 deferral; cold REJECT 4/8 → fixed → cold ACCEPT 8/8, attested).

## What Is In Progress
- S29: PR `session-29-footer` → `main` → next session in a new chat.
  **Next (S30 candidates):** `lineModelToSvg` parity; real `v0.1.0`
  release; Playwright QA into CI; candle ties-first exclusivity test
  hardening. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S28:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + closeout). S26 ran five stories in
  one session by explicit founder direction (waiver of the 1-story rule, disclosed);
  S27 ran two stories the same way. S28 was preceded by a fossil throwaway
  exploration (mudra gallery + pie/sparkline prototypes in tmp, lib untouched
  until the founder said "lock"). S29 ran 3 build subagents (batches A/B/C) +
  2 cold-review passes (REJECT→fixes→ACCEPT) in one chat; commits by founder
  approval token. Kept tight.
