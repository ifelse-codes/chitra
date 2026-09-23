# Session 34 — GTM README (the GitHub front door)

- **Type:** CODE. Branch `session-34-gtm-readme` from `main@e80cea9` (S33 merged).
- **Contract:** `prompts/34-task-gtm-readme.md` (6 numbered reqs). Founder
  in-chat direction: the repo had **no root README** and `packages/core/README.md`
  is a 785-line API/design reference, not a landing page — design one good root
  README as a GTM asset. One story.
- **Assumptions (max 2):** (1) the target is the **root** README (GitHub front
  door); the npm package README stays the API/design reference. (2) Lead
  audience **AI builders first, terminal devs second** (the `jev-readiness-plan`
  64/29 lean, and the docs hero already says "CLIs and agents").

## What shipped (Req 1–6)

- **Req 1 — root `README.md`** (214 lines): positioning line *"Terminal charts
  for CLIs and agents."*, one-glance hero, badge row (npm · MIT · 0 deps ·
  452 tests · 20 charts), why-chitra table.
- **Req 2 — 10-second proof.** Install (npm + from-source) and a copy-paste
  quickstart, with three **real** library renders embedded (line, horizontalBar,
  sparkline).
- **Req 3 — AI-builder lane first.** `## Built for AI agents` precedes
  `## Built for terminals`: `toContent()/toPlain()/toJSON()`, no-ANSI rationale,
  an MCP `server.tool` handler, and the AI-data-manual link. Terminal features
  (3 renderers, 7 themes, fluent API) follow.
- **Req 4 — gallery + navigation.** A 20-chart gallery in six semantic
  categories; links to the live docs, the API reference, and the AI-data manual.
- **Req 5 — honest + verifiable facts.** 20 charts · 3 renderers · 7 themes ·
  0 runtime deps · 452 tests, each cross-checked against the source by the verify
  script; stale-claim guards (`134`, `v0.1.0 — stable`) fail the gate.
- **Req 6 — MIT `LICENSE`.** Added at repo root **and** at `packages/core/LICENSE`
  (the package's `files: [..., "LICENSE"]` publish path was previously
  unresolved).
- **Gates.** `verify-session-34.sh` **39/39 ALL GREEN**; demo exit 0 (computed
  summary, non-zero on any fail).

## The drift guard (the honest part)

The embedded chart output is not hand-drawn: `check_render` regenerates each
chart from `packages/core/src/index.ts` and **byte-compares the whole contiguous
block** against the README. If a renderer changes, the README fails the gate.
(A first pass compared only the footer caption; the cold review named it the
"fakest green", so it was hardened to a full-block diff.)

## The cold review caught real gaps (and was right)

Three cold passes on the committed diff (fed only contract + diff):

1. **ACCEPT** — flagged the footer-only drift check → hardened to whole-block.
2. **ACCEPT** — flagged the missing npm badge named in Req 1 → added; badge gate
   tightened to assert each named badge.
3. **REJECT** — root LICENSE only; the published tarball still shipped no MIT
   text → added `packages/core/LICENSE` + a `package-license-ships` gate.
4. **ACCEPT 6/6** — final pass after the fixes. Attested
   `60627a87…d231067`.

## Commits (all ≤3 files; approval-token gated)

- `f09f6a6` GTM root README + MIT LICENSE + contract.
- `19cf6a6` verify + demo gates.
- `a3ca360` harden the render drift guard (address cold review).
- `49251d7` add the npm badge + tighten the badge gate.
- `5e1e9bf` ship the LICENSE inside the published package (address REJECT).

## Open / deferred

- **Live docs-hero pills are stale** (`v0.1.0 — stable`, `134 Tests passing`) —
  a GTM-consistency fix, out of this session's scope (disclosed in the contract).
- **`@chitra/core` is not on npm** (404). The README Install section carries a
  visible *"not on npm yet — publishing"* status line; remove it on release day.
- PR #40 → `main`.

## Review

- Cold independent review: `sessions/session-34-review.md` (ACCEPT 6/6, attested).

## Next session (S35 is a NO-CODE ground-truth session)

- S35 (`N % 5 == 0`) is **ground truth** — no code, no commits, no PRs; audit
  vision + roadmap + rules + constitution + state + cost.
- Then: real `v0.1.0` release (`NODE_AUTH_TOKEN`, founder-only); unfreeze +
  deploy current visuals to live; the docs-hero stale-stat fix; GTM proof pack.
