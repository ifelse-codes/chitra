# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S28 in progress, 2026-09-14.)

## Active Branch
`session-28-sparkline` — S28 delivery complete on branch: `sparkline()`
locked to the panel language (5 atomic commits) + verify 17/17 + demo 4/4.
Review, PR to `main`, and closeout sync still to go.

## What Currently Works (observed, not claimed)
- **`sparkline()` (S28)**: locked panel language — dashed frame + `SPARKLINE`
  eyebrow, label on the frame top, shape+shade columns (2-wide, ≤4 rows by
  share of range), peak reading (ties → first) solid `█` accent spent exactly
  once, grey tone ramp + `░▒▓` shade texture elsewhere (founder's 2026-09-11
  ruling), `n · min · max · last · peak` foot (peak accented;
  `showValue: false` drops `last`). `width` = plotted columns with
  deterministic even-index downsample; panel auto-expands (floor, never cap).
  Empty / all-non-finite → framed `n 0 · (no data)` with null JSON facts;
  flat range renders full columns; non-finite excluded from plot, facts, and
  count; narrow-safe. `toJSON()` keeps `type`/`data`/`label`/`plain` +=
  `count`/`min`/`max`/`last`/`peak {index,value}`. `renderer` accepted,
  design superseded (progress precedent). `SparklineOptions` unchanged.
- `scripts/verify-session-28.sh` — **ALL GREEN (17 pass, 0 fail)**;
  `scripts/demo-session-28.sh` — exit 0, **4/4 PASS** (accent ×4 on peak ·
  grey ×67 · 0 leaks).
- `pnpm --filter @chitra/core run test` — **435/435 green** (baseline 430:
  S27's 428 + 2 polish tests; −10 old sparkline + 15 new S28 tests);
  `typecheck` — exit 0; docs drift gate green; `dist/` rebuilt (gitignored).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), histogram (S25), waterfall + funnel + sankey +
  radar (S26), candlestick + boxplot (S27), **sparkline (S28)** — 19 locked.
- **Docs catalog + browser QA (S13–S15, S24)**: Darpan-parity chrome, `/chart/:id`
  routes, boot-scoped editor persistence, grouped sidebar with collapse/persist,
  Playwright QA across all 20 pages. S28 previews regenerated (drift gate
  green; sparkline-only diff).
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- S28 review + PR + closeout still to go (this session).
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
  review + closeout completed in the closer chat) ·
  **S26** waterfall + funnel + sankey + radar LOCKED (five stories by founder
  direction; funnel centered by founder order on research record; radar from a
  founder reference image — cold ACCEPT 18/19, row 15 PARTIAL disclosed) ·
  **S27** candlestick + boxplot LOCKED (two stories by founder direction; no audit
  mockups — family language by analogy, waterfall outline precedent; adaptive price
  precision approved at PLAN — cold ACCEPT 13/13, attested) ·
  **S28** sparkline LOCKED (in progress — v8 shape+shade prototype approved in-chat;
  no audit mockup — family language by analogy, heatmap-strip + histogram-peak playbooks).

## What Is In Progress
- S28: review → PR `session-28-sparkline` → `main` → closeout.
  **Next (S29 candidates):** the founder-deferred footer pass (A/B/B-diet,
  founder choice); `lineModelToSvg` parity; real `v0.1.0` release; Playwright
  QA into CI; candle ties-first exclusivity test hardening. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S28:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + cold review + closeout). S26 ran five stories in
  one session by explicit founder direction (waiver of the 1-story rule, disclosed);
  S27 ran two stories the same way. S28 was preceded by a fossil throwaway
  exploration (mudra gallery + pie/sparkline prototypes in tmp, lib untouched
  until the founder said "lock"). Kept tight.
