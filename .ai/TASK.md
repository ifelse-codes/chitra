# Current Task Pointer

## Session 33 — release readiness — DONE

- **Branch:** `session-33-release-readiness` (close on branch; main untouched until PR merges)
- **Contract:** `prompts/33-task-release-readiness.md` (5 numbered requirements;
  from `jev-readiness-plan.md` items 1–4). Founder-waived multi-story session.
- **Delivery (atomic commits, all ≤3 files):** CI `browser-qa` job; candle
  ties-first exclusivity test; `lineModelToSvg` terminal parity + drift test +
  regenerated `svg-charts.json`; `ai-data` AI-data manual page + README link +
  QA doc list. Verify 17/17 ALL GREEN; demo exit 0; cold ACCEPT 5/5
  (mutation-tested, attested `db2ef16f…32f79`).
- Verify: `scripts/verify-session-33.sh` — 17/17 ALL GREEN.
  Demo exit 0. Summary: `sessions/session-33-summary.md`.
- **Live deploy still frozen by founder order** — NOT redeployed this session.
- **To go:** PR → merge → next session in a new chat.

**Next session (S34 candidates):** real `v0.1.0` release (`NODE_AUTH_TOKEN`,
founder-only); unfreeze + deploy current visuals to live; GTM growth (audience
decision, proof pack, pricing story). Open in a **new chat**.
