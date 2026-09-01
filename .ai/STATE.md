# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S18 closing, 2026-09-01.)

## Active Branch
`session-18-heatmap-lock` — S18 work pending PR.

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **192/192 pass** (15 heatmap tests added S18).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-18.sh` — **ALL GREEN (8 pass, 0 fail)**; `demo-session-18.sh` — exit 0.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — no chart drift (previews in sync).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families now: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), **heatmap (S18)**.
- **Heatmap (S18)**: intensity encoded on the documented grey tone ramp
  (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`, light→dark) with a matching `░▒▓█` plain-text shade;
  one accent hue spent exactly once on the max cell (ties → first row-major); dashed
  panel frame, `DENSITY` eyebrow, `│`/`+` guide, two rule separators,
  `rows×cols · min..max · peak (r,c)` footer; empty/degenerate data safe. Contract block
  `### LOCKED: heatmap chart — session 18 design` in `packages/core/README.md`.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- `sparkline`/`histogram` still predate the reference-locked look — the last unlocked
  chart families.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `artifacts/api-server` exposes only `/healthz`.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN`).
- QA is local-only; not yet wired into CI.
- `.ai/` bookkeeping had drifted (SESSION pointer stale at 15 while S16/S17 shipped);
  re-synced to 18 this closeout. S16/S17 have no committed session summary/review.
- **S05 ground-truth remediation debt** still open.

## Milestones done
- **S01–S04** docs generator / examples / polish / README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG ·
  **S09** circular + area LOCKED · **S10** line LOCKED · **S11** catalog two-panel ·
  **S12** bar LOCKED · **S13** Darpan-parity chrome · **S14** URL routes + persistence ·
  **S15** scripted browser QA · **S17** scatter LOCKED · **S18** heatmap LOCKED.

## What Is In Progress
- Nothing mid-flight. **Next session (S19 candidates):** carry the locked language into
  `sparkline`/`histogram`; bring `lineModelToSvg` to terminal parity; exercise a real
  `v0.1.0` release. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S18 in-repo). S18 ran on the founder's $20/mo plan — two subagent
  dispatches (tech-lead + fidelity-reviewer), kept tight.
