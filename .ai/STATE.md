# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S23 closing, 2026-09-13.)

## Active Branch
`session-23-progress-mudra` — S23 complete on branch: delivery + summary + attested ACCEPT
review + closeout sync all committed; closeout gate green; PR to `main` is the last step.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **309/309 pass** (25 new progress tests:
  accent-once census, chrome, footer, retired glyphs incl. no-brackets/no-subblocks/
  no-ascii under every `style`, ramp-survives-noColor, style-superseded, out-of-range
  honest footer + toJSON, collapsed range, n/a, toJSON surface).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**. Root `typecheck` (libs +
  scripts + artifacts incl. docs) — **exit 0**.
- `scripts/verify-session-23.sh` — **ALL GREEN (13 pass, 0 fail)**;
  `demo-session-23.sh` — exit 0, 7/7 live checks.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — no chart drift (previews
  in sync with the locked progress render).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families now: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20), timeline (S21),
  gauge (S22), **progress (S23)** — the founder-named trio complete.
- **progress (S23)**: grey tone ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75` by level WITH its
  matching plain-text shade glyph (`░ ▒ ▓ █`, one per tone bucket, light → dark — the
  heatmap/gauge texture language per the founder's 2026-09-11 shade-texture ruling, so
  intensity survives noColor); ONE accent hue spent EXACTLY once as the solid `█` on the
  fill's leading edge; the `style` option stays accepted but the locked design supersedes
  it (`▁▂▃` sub-blocks, `=`/`.` ascii, naked `[bar] pct` all retired under every style);
  dashed frame, uppercase `PROGRESS` eyebrow (or `opts.label` uppercased), `+╌…╌+` guide
  + `0..max` scale row, two rule separators; the dim `─` track (axis colour) is the
  shared scale; **the silent clamp is retired as a lie** — the fill clamps to the track
  while the footer AND `toJSON()` report the TRUE value and TRUE percent (the old code
  clamped `value` into `0..max` before computing, so `value: 200, max: 100` reported 100
  and 100%); non-finite → framed `value n/a` panel; collapsed range (`max === 0`) safe;
  `value <v> · 0..<max> · <pct>%` footer (value fact accented); `showPercent: false`
  drops the pct fact; `toJSON()` gains additive `bucket` (0–3, `null` when n/a) and a
  true `percent`. Public API (`ProgressOptions`) unchanged, zero runtime deps. Contract
  block `### LOCKED: progress chart — session 23 design` in `packages/core/README.md`.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
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
  carried) · **S23** progress LOCKED (single-chat, trio complete).

## What Is In Progress
- S23 closeout final step: PR `session-23-progress-mudra` → `main` (review ACCEPT
  attested; gate green). **Founder deferral (from S21):** plain-English footer redesign,
  family-wide (A trim / B plain words / B-diet) — one dedicated session, later; now
  unblocked with the trio locked. **Next session (S24 candidates):** the footer pass →
  plan-review bug-first queue (histogram, waterfall, funnel); `lineModelToSvg` parity;
  real `v0.1.0` release; Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S23:
  single ZCode chats (boot + plan + execute + verify + demo in one conversation each),
  one cold-review subagent dispatched post-commit per session; dispatches kept narrow.
  Kept tight.
