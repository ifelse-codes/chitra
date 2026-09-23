# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S34 done, 2026-09-23.)

## Active Branch
`session-34-gtm-readme` — S34 delivery complete on branch: root GTM README +
MIT LICENSE (root + package); verify 39/39 + demo exit 0 + cold ACCEPT 6/6
(attested `60627a87…d231067`). PR **#40** to `main` to go. **Live deploy still
frozen (S31 order).**

## What Currently Works (observed, not claimed)
- **Root GTM README (S34):** `README.md` (214 lines) — positioning line
  *"Terminal charts for CLIs and agents."*, badge row (npm · MIT · 0 deps ·
  452 tests · 20 charts), install (npm + from-source), quickstart, AI-builder
  lane first (`toContent()/toPlain()/toJSON()`, MCP handler, AI-data link),
  terminal lane second (renderers, themes, fluent API), 20-chart gallery, docs
  links. Three real library renders embedded.
- **README drift guard (S34):** `scripts/verify-session-34.sh` regenerates each
  embedded chart from `packages/core/src/index.ts` and byte-compares the whole
  block — a renderer change fails the gate. Facts (20/3/7/0/452) are
  cross-checked against source; stale-claim guards (`134`, `v0.1.0 — stable`).
- **LICENSE (S34):** MIT at repo root **and** `packages/core/LICENSE` (the
  package's `files: ["LICENSE"]` publish path is now resolved).
- `scripts/verify-session-34.sh` — **ALL GREEN (39 pass, 0 fail)**;
  `scripts/demo-session-34.sh` — exit 0 (computed summary).
- `pnpm --filter @chitra/core run test` — **452/452 green**; core typecheck
  exit 0. Docs build + chart drift gate green (S33 baseline).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult`
  output surface. LOCKED families: circular (S09), area (S09), line (S10), bar
  (S12), scatter (S17), heatmap (S18), horizontalBar (S19), treemap (S20),
  timeline (S21), gauge (S22), progress (S23), histogram (S25), waterfall +
  funnel + sankey + radar (S26), candlestick + boxplot (S27), sparkline (S28)
  — all wearing the S29 B-diet+ footer/chrome.
- **Docs catalog + browser QA (S13–S15, S24, S31, S33):** Darpan-parity chrome,
  `/chart/:id` routes, boot-scoped editor persistence, grouped sidebar, antra
  atoms + hero rotation, CI `browser-qa` job. Docs app serves at
  `PORT=5174 BASE_PATH=/` (`pnpm --filter @workspace/chitra-docs run dev`).
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the
  `.ai/hooks/*` PreToolUse guards wired.

## What Is Broken / Incomplete
- S34 PR #40 + merge still to go (this session). Live deploy frozen.
- **`@chitra/core` is not on npm** (404) — README Install discloses this.
- **Live docs-hero pills are stale** (`v0.1.0 — stable`, `134 Tests passing`) —
  deferred GTM-consistency fix (disclosed in the S34 contract).
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
  **S32** bank wall-stagger playbook (KNOWLEDGE) · **S33** release readiness
  (CI browser QA + candle exclusivity + SVG parity + AI-data manual) ·
  **S34** GTM root README + MIT LICENSE (root + package) + render drift guard.

## What Is In Progress
- S34: PR #40 `session-34-gtm-readme` → `main` → next session in a new chat.
  **Next (S35):** **NO-CODE ground-truth** (`N % 5 == 0`) — audit vision +
  roadmap + rules + constitution + state + cost. Then: real `v0.1.0` release;
  unfreeze + deploy current visuals to live; docs-hero stale-stat fix; GTM proof
  pack. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S20 ran on the founder's $20/mo plan. S21–S28:
  single ZCode chats, one cold-review subagent dispatched post-commit per session.
  S25 needed a closer chat after a token stop; S26 ran five stories and S27 two by
  explicit founder direction (waiver of the 1-story rule, disclosed). S28 preceded by
  a throwaway prototype. S29 ran 3 build subagents + 2 cold reviews. S30 zero build
  subagents (ops deploy) + 2 cold reviews. S31 one recon subagent + 2 cold reviews.
  S32 knowledge-only. S33 ran one opencode session: four stories, one cold-review
  subagent (mutation-tested) dispatched post-commit. S34 ran one opencode session:
  one story, **four** cold-review subagent passes (each fix re-reviewed against the
  frozen diff; the third pass REJECTed the root-only LICENSE and forced
  `packages/core/LICENSE`), commits approval-token gated.
