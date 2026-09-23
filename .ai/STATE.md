# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S33 done, 2026-09-23.)

## Active Branch
`session-33-release-readiness` — S33 delivery complete on branch: CI browser QA
+ candle exclusivity + SVG parity + AI-data manual; verify 17/17 + demo exit 0
+ cold ACCEPT 5/5 (mutation-tested, attested `db2ef16f…32f79`). PR to `main` to
go. **Live deploy still frozen (S31 order).**

## What Currently Works (observed, not claimed)
- **CI browser QA (S33):** `.github/workflows/ci.yml` `browser-qa` job builds
  lib decls + core dist, installs Playwright Chromium, runs
  `scripts/qa-catalog.mjs` over all 20 chart pages + doc pages (incl. `ai-data`)
  + home, failing on any console/page error.
- **SVG parity (S33):** `createLineChartModel` owns canonical colours
  (`seriesColors`/`strokeSteps`/`style`/`noColor`/`grid`/`eyebrow`); the
  terminal renderer and `lineModelToSvg` read the same values. SVG is
  theme-aware (truecolor + xterm named → CSS), draws markers every 2nd point,
  dash textures, `grid`-gated gridlines, legend/eyebrow/summary captions, and
  spends accent once on the peak. `tests/line-svg.test.ts` (7) is the drift
  guard. Terminal line output byte-identical (21 option sets diffed empty).
- **AI-data manual (S33):** `ai-data` route (`AiDataPage`) documents feed
  choice, per-chart `toJSON()` shapes, null-on-empty + clamp-true-value, and
  the MCP untrusted-input guardrail; linked from AI Agents + `packages/core/README.md`.
- `scripts/verify-session-33.sh` — **ALL GREEN (17 pass, 0 fail)**;
  `scripts/demo-session-33.sh` — exit 0.
- `pnpm --filter @chitra/core run test` — **452/452 green**; core + docs
  typecheck exit 0; docs build green; chart drift gate green.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult`
  output surface. LOCKED families: circular (S09), area (S09), line (S10), bar
  (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
  timeline (S21), gauge (S22), progress (S23), histogram (S25), waterfall +
  funnel + sankey + radar (S26), candlestick + boxplot (S27), sparkline (S28)
  — all wearing the S29 B-diet+ footer/chrome.
- **Docs catalog + browser QA (S13–S15, S24, S31):** Darpan-parity chrome,
  `/chart/:id` routes, boot-scoped editor persistence, grouped sidebar,
  antra atoms + hero rotation. Docs app serves at `PORT=5174 BASE_PATH=/`
  (`pnpm --filter @workspace/chitra-docs run dev`).
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the
  `.ai/hooks/*` PreToolUse guards wired.

## What Is Broken / Incomplete
- S33 PR + merge still to go (this session). Live deploy frozen.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN` —
  founder-only secret).
- `artifacts/api-server` exposes only `/healthz`.
- GTM proof pack (benchmarks / token-savings) and pricing story still to build.
- **S05 ground-truth remediation debt** still open.

## Milestones done
- **S01–S04** docs generator / examples / polish / README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG ·
  **S09** circular + area LOCKED · **S10** line LOCKED · **S11** catalog two-panel ·
  **S12** bar LOCKED · **S13** Darpan-parity chrome · **S14** URL routes + persistence ·
  **S15** scripted browser QA · **S17** scatter LOCKED · **S18** heatmap LOCKED ·
  **S19** horizontalBar LOCKED · **S20** treemap LOCKED · **S21** timeline LOCKED ·
  **S22** gauge LOCKED · **S23** progress LOCKED · **S24** grouped chart nav ·
  **S25** histogram LOCKED · **S26** waterfall + funnel + sankey + radar LOCKED ·
  **S27** candlestick + boxplot LOCKED · **S28** sparkline LOCKED ·
  **S29** family-wide footer pass B-diet+ · **S30** docs site live on
  chitra.iifelse.com · **S31** antra design atoms + hero rotation + wall fix ·
  **S32** bank wall-stagger playbook (KNOWLEDGE) ·
  **S33** release readiness (CI browser QA + candle exclusivity + SVG parity +
  AI-data manual).

## What Is In Progress
- S33: PR `session-33-release-readiness` → `main` → next session in a new chat.
  **Next (S34 candidates):** real `v0.1.0` release (`NODE_AUTH_TOKEN`); unfreeze
  + deploy current visuals to live; GTM growth (audience, proof, pricing).
  See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S28:
  single ZCode chats, one cold-review subagent dispatched post-commit per session.
  S25 needed a closer chat after a token stop; S26 ran five stories and S27 two by
  explicit founder direction (waiver of the 1-story rule, disclosed). S28 preceded by
  a throwaway prototype. S29 ran 3 build subagents + 2 cold reviews. S30 zero build
  subagents (ops deploy) + 2 cold reviews. S31 one recon subagent + 2 cold reviews.
  S32 knowledge-only. S33 ran one opencode session: four stories, one cold-review
  subagent (mutation-tested) dispatched post-commit; commits approval-token gated.
