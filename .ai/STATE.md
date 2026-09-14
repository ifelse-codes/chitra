# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S27 closing, 2026-09-13.)

## Active Branch
`session-27-candlestick-boxplot` — S27 complete on branch: delivery (7 atomic
commits) + summary + cold ACCEPT review (attested) + closeout sync all
committed; closeout gate green with no waiver; PR to `main` is the last step.

## What Currently Works (observed, not claimed)
- **`candlestick()` (S27)**: locked panel language — dashed frame + `OHLC`
  eyebrow, up candles solid `▓` on mid-grey, down candles as dashed outline
  boxes (`┌╌╌┐`/`│  │`/`└╌╌┘`, waterfall language, 1-row minimum for doji-range
  bodies), peak close (ties → first) solid `█` accent spent exactly once,
  wicks in kind tone (accent touches only `█` bodies + non-block text),
  adaptive price labels (integers when range ≥ 100, else ≤1dp/≤2dp trimmed),
  `│`/`+` guide, dashed `└╌` baseline, truncated period labels,
  `N · HI · LO · LAST` foot (LAST accented). Empty → framed
  `N 0 · (no data)` with null `count`/`high`/`low`/`last`; flat range pads ±1;
  non-finite candles excluded. `toJSON()` additive `count`/`high`/`low`/`last`.
  `CandlestickOptions` unchanged.
- **`boxplot()` (S27)**: peak median group (ties → first) box + whiskers +
  caps + median in accent once; other groups grey ramp + `░▒▓` fill by share
  of peak median; median as horizontal `───`/`═══` vs vertical `│` edges;
  `SPREAD` eyebrow, `GROUPS · MED · PEAK <label> <v>` foot (PEAK accented).
  Empty → `GROUPS 0 · (no data)` with null `stats`/`peakGroup`; single-value
  groups safe via flat-range guard; non-finite excluded pre-`quartiles()`;
  emptied groups dropped with labels. `toJSON()` keeps
  `data`/`labels`/`stats` += `peakGroup {label,index,median}`.
  `BoxPlotOptions` unchanged.
- `scripts/verify-session-27.sh` — **ALL GREEN (20 pass, 0 fail)**;
  `scripts/demo-session-27.sh` — exit 0, **8/8 PASS**.
- `pnpm --filter @chitra/core run test` — **428/428 green** (+37 new S27
  tests); `typecheck` — exit 0; docs drift gate green.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), histogram (S25), waterfall + funnel + sankey +
  radar (S26), **candlestick + boxplot (S27)** — 18 locked.
- **Docs catalog + browser QA (S13–S15, S24)**: Darpan-parity chrome, `/chart/:id`
  routes, boot-scoped editor persistence, grouped sidebar with collapse/persist,
  Playwright QA across all 20 pages. S27 previews regenerated (drift gate
  green); `dist/` rebuilt for the playground.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- The founder-deferred footer pass (A trim / B plain words / B-diet) awaits a
  founder choice.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `artifacts/api-server` exposes only `/healthz`.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN`).
- QA is local-only; not yet wired into CI.
- **S05 ground-truth remediation debt** still open.
- S27 review note (test-strength only, code correct): the candle ties-first test
  asserts accent presence, not second-candle exclusivity — candidate hardening.

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
  precision approved at PLAN — cold ACCEPT 13/13, attested).

## What Is In Progress
- S27 closeout final step: merge PR `session-27-candlestick-boxplot` → `main`.
  **Next (S28 candidates):** the founder-deferred footer pass (A/B/B-diet,
  founder choice); `lineModelToSvg` parity; real `v0.1.0` release; Playwright
  QA into CI; candle ties-first exclusivity test hardening. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S27:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + cold review + closeout). S26 ran five stories in
  one session by explicit founder direction (waiver of the 1-story rule, disclosed);
  S27 ran two stories the same way. Kept tight.
