# Session 20 — lock `treemap` to the reference/panel language — SUMMARY (recovered)

Branch `session-20-treemap-lock`. Work recovered from pi (`~/.pi/agent/sessions/...chitra.../2026-09-09T10-19-39...jsonl`, 180 lines) + Command Code (`8b98ceae...`, 176 msgs, Kimi-K3, stopped on usage-limit + Insufficient credits).

## Shipped (in-flight, uncommitted)
- `packages/core/src/charts/treemap.ts` — S18 heatmap language rotated onto hierarchy: accent-once on max leaf (first-flatten tie-break), grey ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75` + shade glyphs `░▒▓█`, dashed frame + `AREA` eyebrow + `+`/`│` guide + 2 rules, `n · min..max · peak <label>` footer (peak accented), honest leaf flatten, SPACE empty grid, empty/all-equal/single safe. No `theme.colors[]` rainbow.
- `packages/core/tests/treemap.test.ts` — 18 falsifiable raw-ANSI tests (accent census, chrome, footer, flatten, degen, noColor, toJSON).
- `packages/core/README.md` — `### LOCKED: treemap chart — session 20 design` block.
- Docs previews regenerated (`chart-specs.ts`, `charts.ts`, `ansi-charts.json`) — drift gate green.
- `scripts/verify-session-20.sh` (12 checks) + `scripts/demo-session-20.sh` (before/after + 5 live checks) — written in recovery.
- `prompts/20-task-treemap-lock.md` + `.ai/handoffs/session-20-tech-lead.md` (tech-lead first, 4 required / 5 deferred-budget).

## Gates (observed 2026-09-10, after Req-6 tightening)
- `verify-session-20.sh` — 12/12 ALL GREEN. `demo-session-20.sh` — exit 0, 5/5 PASS.
- `core test` — 236/236 (11 files, +1 new Req-6 test). `typecheck` — exit 0.

## Fidelity (two independent cold passes, this chat)
- Pass 1: 10/11 SHIPPED, 1 PARTIAL (Req 6: `░`-ban vacuous, no SPACE test) → REJECT.
- Pass 2 (after 1st fix): 6/8 SHIPPED, Req-6 + Req-8 PARTIAL — dead `PHANTOM` regex,
  vacuous `some(includes(" "))`, untracked-gates observation → REJECT.
- Builder tightening since (untracked verify/test only): vacant-canvas-zero-cells +
  residue-membership `^[░▒▓█]*$` assertions. Recorded in `sessions/session-20-review.md`
  (**Verdict:** REJECT on pass-2 inputs + fix delta; 3rd cold pass owed post-commit).
- Per max-2-retries, verification iteration STOPS here — escalated, not silently green.

## Follow-up: sliver labels (founder review of docs render, 2026-09-10)
- Problem: proportional splitter makes thin full-height slivers; every region stamped
  label+value → `R…` truncation noise + colliding labels in 1–2-col regions.
- Fix (chosen: hide labels in slivers): region stamps text only when the whole label/value
  fits inside it (`treemap.ts` + 1 test rewrite + 1 README bullet). Slivers keep clean ramp.
- Gates after fix: 236/236 tests, verify 12/12, demo exit 0, previews regenerated, dist rebuilt.
1. Req-6 fix: DONE as approved (untracked verify/test only; tracked `treemap.ts` untouched).
2. Commits: APPROVED by you, but the S93 hook needs it as launch-env `VAJRA_ALLOW_COMMIT=20`
   — I cannot mint it inline (self-granted = blocked by L3 guard). Run the 4 commands below.
3. Crew gate: WAIVER chosen — closeout also needs `VAJRA_CLOSEOUT_WAIVER=20` in the same
   launch env (covers pi/Command-Code provenance gap + current REJECT-on-record).
4. `.ai/SESSION` still 19 — advanced during closeout (step 3 below), not by hand.

## Exact handoff (paste in a fresh shell on `session-20-treemap-lock`)
- `V=20; git add packages/core/src/charts/treemap.ts packages/core/tests/treemap.test.ts packages/core/README.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S20: lock treemap to reference language"`
- `git add artifacts/chitra-docs/scripts/chart-specs.ts artifacts/chitra-docs/src/data/charts.ts artifacts/chitra-docs/src/data/ansi-charts.json && VAJRA_ALLOW_COMMIT=$V git commit -m "S20: regenerated docs previews"`
- `git add scripts/verify-session-20.sh scripts/demo-session-20.sh prompts/20-task-treemap-lock.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S20: verify + demo + prompt"`
- `git add .ai/handoffs/session-20-tech-lead.md sessions/session-20-summary.md sessions/session-20-review.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S20: summary + independent review"`
- `git add .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S20 closeout: advance session pointer + boot + task to 20"`
- `git add .ai/STATE.md .ai/ROADMAP.md && VAJRA_ALLOW_COMMIT=$V git commit -m "S20 closeout: sync STATE + ROADMAP snapshots"`
- Then: 3rd cold review pass → flip to ACCEPT + attestation (`verify-closeout.sh --inputs-sha 20`) →
  `VAJRA_CLOSEOUT_WAIVER=20 VAJRA_CLOSEOUT_WAIVER_REASON="recovered pi/Command-Code session; REJECT-on-record pending 3rd pass" scripts/verify-closeout.sh` → PR.
  Closeout now evaluates N=20: 11/13 PASS; the 2 FAILs (fidelity-accept, required-crew) are
  exactly what the waiver covers. Never commit `.commandcode/`, `.freebuff/`,
  `design-reference/mudra-*`, `build-audit-html.mjs`, session HTML.
