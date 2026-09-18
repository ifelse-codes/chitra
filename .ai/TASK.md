# Current Task Pointer

## Session 28 extension — chart composability + SRE dashboard — COMMITTED

- **Branch:** `session-28-sparkline` (close on branch; main untouched until PR merges)
- **Contract:** founder's continuation prompt (frame/compact done → fix height,
  toPlain, maxWidth; dashboard as capability demo). All three issues shipped.
- **Delivery (12 atomic commits, all ≤3 files, hooks green):** contract +
  helpers + `truncateAnsi` + 7 conformance tests + height/toContent/maxWidth
  across all 20 charts + `playground/sre-dashboard/` (sim, CLI, 2-col web
  grid server, audit script, field report).
- Verify: `pnpm test` **442/442**, `tsc --noEmit` clean, on the committed tree.
- **To go:** cold review (12 commits) → PR → `main` → closeout sync + gate.

**Next session (S29):** review + PR first; then prior candidates (footer pass,
`lineModelToSvg` parity, `v0.1.0` release, Playwright QA into CI, candle test
hardening). Open in a **new chat**.
