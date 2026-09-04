# chitra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout. (S19 closing, 2026-09-04.)

## Active Branch
`session-19-horizontalbar-lock` — S19 work complete on branch (main untouched; no PR this run).

## What Currently Works (observed, not claimed)
- `pnpm --filter @chitra/core run test` — **217/217 pass** (25 horizontalBar tests added S19).
- `pnpm --filter @chitra/core run typecheck` — **exit 0**.
- `scripts/verify-session-19.sh` — **ALL GREEN (11 pass, 0 fail)**; `demo-session-19.sh` — exit 0.
- `pnpm --filter @workspace/chitra-docs run gen:charts:check` — no chart drift (previews in sync).
- `vajra next --check-crew 19` — **READY** (tech-lead + all 4 required-role handoffs recorded).
- **`@chitra/core` library**: 20 charts, 3 renderers, 7 themes, `ChartResult` output
  surface. LOCKED families now: circular (S09), area (S09), line (S10), bar (S12),
  scatter (S17), heatmap (S18), **horizontalBar (S19)** — the core-set reference-language
  migration is complete.
- **horizontalBar (S19)**: the S12 `bar` locked language rotated to horizontal — ONE accent
  hue spent once on the global-max bar (first-max tie-break), grey tone ramp
  (`#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`) for every other bar (no `theme.colors` rainbow);
  dashed frame, uppercase eyebrow (`VALUES`/`xLabel`), rotated `+` value-axis guide +
  `min..max` scale row, two rule separators; per-item value labels with the peak value in
  accent; SPACE empty cells (never `░`); auto-scale (`min(0,dataMin)` baseline) +
  auto-expanding width; empty/all-equal/single safe. Contract block
  `### LOCKED: horizontalBar chart — session 19 design` in `packages/core/README.md`.
- **Governance dogfood (S144)**: chitra's OWN fleet + hooks drove this session — tech-lead
  first, binding crew verdict, provenance-verified handoffs for every required role, and the
  S139 required-crew gate live in `scripts/verify-closeout.sh`.
- **Docs catalog + browser QA (S13–S15)**: Darpan-parity chrome, `/chart/:id` routes,
  boot-scoped editor persistence, Playwright QA across all 20 pages.
- Enforcement belt: `.githooks/pre-commit` + `.githooks/pre-push` and the `.ai/hooks/*`
  PreToolUse guards (commit / publish / session) wired.

## What Is Broken / Incomplete
- `sparkline`/`histogram` predate the reference-locked look — but they are NOT chart
  *families* in the mudra-locked sense; the locked-family migration for the core charts is
  complete with horizontalBar. Revisit whether sparkline/histogram need the full panel.
- The SVG `lineModelToSvg` does not yet mirror the terminal 1:1.
- `artifacts/api-server` exposes only `/healthz`.
- First real release (tag `v0.1.0`) not yet exercised (`NODE_AUTH_TOKEN`).
- QA is local-only; not yet wired into CI.
- Cold-review follow-ups (non-blocking): add an auto-width test asserting the summary-row
  edge fits (only the label edge is asserted today); reconcile "letter-spaced eyebrow" prose
  vs code (only uppercases, inherited from the S12 reference).
- **S05 ground-truth remediation debt** still open.

## Milestones done
- **S01–S04** docs generator / examples / polish / README · **S05** NO-CODE ground-truth ·
  **S06** publishable dist · **S07** CI workflows · **S08** release.yml + line/SVG ·
  **S09** circular + area LOCKED · **S10** line LOCKED · **S11** catalog two-panel ·
  **S12** bar LOCKED · **S13** Darpan-parity chrome · **S14** URL routes + persistence ·
  **S15** scripted browser QA · **S17** scatter LOCKED · **S18** heatmap LOCKED ·
  **S19** horizontalBar LOCKED (Vajra S144 full-loop dogfood).

## What Is In Progress
- Nothing mid-flight. **Next session (S20 candidates):** bring `lineModelToSvg` to terminal
  parity; exercise a real `v0.1.0` release; wire local Playwright QA into CI. See [[roadmap]].

## Cost Tracking
- Cumulative: chitra sessions ~$0 (S06 dist + S07 CI + S08 built via Vajra dogfood runs,
  billed to Vajra; S09–S19 in-repo). S19 ran on the founder's $20/mo plan — the tech-lead
  bound a 4-role required crew (implementation-advisor, qa-specialist, demo-producer,
  fidelity-reviewer) and deferred the other 5 on money arithmetic; every dispatch was a
  narrow named-files-only brief. Kept tight.
