# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S26 closing, 2026-09-13.)

## Active Branch
`session-26-waterfall-mudra` — S26 complete on branch: delivery (6 atomic
commits) + summary + cold ACCEPT review (attested) + closeout sync all
committed; closeout gate green with no waiver; PR to `main` is the last step.

## What Currently Works (observed, not claimed)
- **`waterfall()` (S26)**: locked panel language — dashed frame + `NET`
  eyebrow, down-deltas as dashed outline boxes (`┌╌╌┐`/`│  │`/`└╌╌┘`, sub-row
  keeps 1 row via rounding — the P0 flat-dash bug retired by design), Start
  darkest-grey solid `█`, Total accent solid `█` spent exactly once, ups solid
  `▓` mid-grey, downs outlined light-grey, integer y-labels with `│`/`+`
  guide, dashed `└╌` baseline, `┄` connectors, signed delta row,
  `START · Δ · TOTAL` foot (TOTAL accented). Empty → framed
  `TOTAL 0 · (no data)` with `steps: []`; all-zero → empty columns.
  `toJSON()` additive `steps` (`{label,delta,start,end,kind}`).
  `positiveColor`/`negativeColor`/`totalColor` stay accepted as tone overrides.
- **`funnel()` (S26)**: CENTERED rows in a shared field (top-wide →
  bottom-narrow; audit §3.4 item 2 reversed by founder order, on research
  record), no `▼`, peak stage solid `█` accent (ties → first), descending
  grey ramp + `░▒▓` + `▓` end-cap, integer pcts, `CONVERSION <pct>%` eyebrow,
  `IN · OUT · CONVERSION · DROP` foot (CONVERSION accented). Empty →
  `STAGES 0 · (no data)` with null `conversion`/`biggestDrop`; zero-first →
  `n/a` conversion.
- **`sankey()` (S26)**: no `▶`, peak flow solid `█` accent (ties → first),
  other flows ramp + `░▒▓` proportional widths, toned `■` node ledger ranked
  by flow with `in:`/`out:` facts, `FLOW <total>` eyebrow,
  `NODES · LINKS · PEAK` foot (peak accented). Empty → `NODES 0 · (no data)`
  with null `peakFlow`.
- **`radar()` (S26)**: five braille rings with `+` ticks and dashed spokes,
  `0..<max>` scale in the `AXES · SERIES` eyebrow, accent primary with
  braille rim + dot-wash fill + solid `●` vertices, dashed grey secondaries
  with hollow `○` and no fill, `● ── / ○ ╌╌` legend, `AVG · PEAK` foot (peak
  accented), unclipped labels, negatives/non-finite collapse to center.
  Empty → `AXES 0 · (no data)` with null `max`/`avg`. (Cold review PARTIAL on
  the thin-edge/stipple/dashed-ring glyph grammar — founder-reference
  substitution, disclosed in code + README.)
- `scripts/verify-session-26.sh` — **ALL GREEN (24 pass, 0 fail)**;
  `scripts/demo-session-26.sh` — exit 0, **9/9 PASS**.
- `pnpm --filter @chitra/core run test` — **391/391 green** (+59 new S26
  tests); `typecheck` — exit 0; docs drift gate green.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), progress (S23), histogram (S25), **waterfall + funnel + sankey +
  radar (S26)** — 16 locked; the audit queue is EMPTY.
- **Docs catalog + browser QA (S13–S15, S24)**: Darpan-parity chrome, `/chart/:id`
  routes, boot-scoped editor persistence, grouped sidebar with collapse/persist,
  Playwright QA across all 20 pages. S26 previews regenerated (drift gate
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
  direction; funnel centered by founder order on research record;   radar from a
  founder reference image — cold ACCEPT 18/19, row 15 PARTIAL disclosed).

## What Is In Progress
- S26 closeout final step: merge PR `session-26-waterfall-mudra` → `main`.
  **Next (S27 candidates):** the founder-deferred footer pass (A/B/B-diet,
  founder choice); `lineModelToSvg` parity; real `v0.1.0` release; Playwright
  QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S26:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  S25 additionally needed a closer chat after the build chat hit its token limit
  (state recovery + founder commits + cold review + closeout). S26 ran five stories in
  one session by explicit founder direction (waiver of the 1-story rule, disclosed).
  Kept tight.
