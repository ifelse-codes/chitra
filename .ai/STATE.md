# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S20 closing, 2026-09-10.)

## Active Branch
`session-20-treemap-lock` — S20 work complete on branch (main untouched; commits pending founder env marker, see below).

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **236/236 pass** (19 treemap tests: accent census, chrome, footer, flatten, degen, sliver-label, Req-6 SPACE, noColor, toJSON).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-20.sh` — **ALL GREEN (12 pass, 0 fail)**; `demo-session-20.sh` — exit 0, 5/5 live checks.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — no chart drift (previews in sync).
- `packages/core/dist/` rebuilt from S20 source (docs catalog executes examples against `dist/`); docs app verified live on `:5174`.
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families now: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), horizontalBar (S19), **treemap (S20)** — first hierarchical
  chart in the locked language.
- **treemap (S20)**: accent-once on max leaf (first-flatten tie-break), grey ramp + `░▒▓█`
  by magnitude (no rainbow); dashed frame, `AREA` eyebrow, `+`/`│` guide, two rule
  separators; `n · min..max · peak <label>` footer; honest leaf flatten; SPACE empty grid;
  slivers stay clean blocks (whole-text-only labels); empty/all-equal/single safe. Contract
  block `### LOCKED: treemap chart — session 20 design` in `packages/core/README.md`.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- **S20 review on record is REJECT** (2 cold passes; Req-6 proof gap, behavior faithful).
  Builder tightened verify/test twice since (vacant-zero-cells, residue-membership, sliver
  rule). A 3rd cold pass is owed post-commit — closeout needs the waiver until ACCEPT lands.
- **Crew provenance gap**: pi/Command-Code dispatches unverifiable by the S139 gate
  (Claude-Code transcripts only) → `VAJRA_CLOSEOUT_WAIVER=20` required.
- **Uncommitted**: 5 modified + 10 session files on branch; commits need launch-env
  `VAJRA_ALLOW_COMMIT=20` (cannot be self-minted; exact commands in summary).
- `.ai/SESSION` advanced to 20 in this sync; closeout gate runs against N=20.
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
  **S19** horizontalBar LOCKED (Vajra S144 full-loop dogfood) ·
  **S20** treemap LOCKED (recovered: pi + Command Code + closer chat).

## What Is In Progress
- S20 closeout pending founder env steps: atomic commits (`VAJRA_ALLOW_COMMIT=20`), 3rd cold
  review pass + attestation, waived closeout (`VAJRA_CLOSEOUT_WAIVER=20`), PR to `main`.
  **Next session (S21 candidates):** `timeline` → `gauge` → `progress` mudra migration;
  `lineModelToSvg` parity; real `v0.1.0` release; Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S19 ran on the founder's $20/mo plan (4-role required
  crew, 5 deferred-budget, narrow named-files-only briefs). S20: recovered session — pi
  session + Command Code run (Kimi-K3, stopped on credits) + closer chat (2 cold
  subagent passes, Req-6 tightening, sliver-label fix); dispatches kept narrow. Kept tight.
