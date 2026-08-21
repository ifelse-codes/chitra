# Session 13 — Docs catalog chrome: Darpan parity

**Branch:** `session-13-docs-toolbar-polish` → `session-13-darpan-parity-chrome` (from `main`)
**Type:** CODE
**Session:** 13

## Goal

Make the docs catalog page chrome (`artifacts/chitra-docs`) match the founder's
Darpan application UI — same look and feel, same design language, "Linear/Vercel
tier" polish. Founder-directed during the session, in three passes:

1. Run/Reset buttons did not match the site theme → restyle to the site's
   primary/secondary button language.
2. Run button too heavy → one compact control metric for the whole toolbar;
   label exactly "Run" with the shortcut written in the button; global
   `⌘↩` / Ctrl+↩ shortcut that works anywhere on the page.
3. Founder supplied the real Darpan codebase (`~/playground/darpan`, read-only)
   + live app → replace screenshot approximations with canon values from
   `apps/web/src/styles/theater-tokens.css` and the shipped component CSS.

## Design

- Toolbar = one control metric: 24px tall, 2px radius, mono type, one motion curve.
- Run = Darpan `.btnPrimary`: accent fill, 1px accent border, warm near-black
  text (`oklch(0.12 0.008 60)`), keycap chip `⌘↩` (Ctrl ↩ off-mac), spinner while running.
- Status pills squared + uppercase; actions are uppercase ghost chips.
- Terminal preview: uppercase titlebar, inspector-style key/value footer,
  dashed awaiting-run empty state, RUN FAILED chip banner on errors.
- Tokens corrected against Darpan source: white-alpha fg tiers
  (`oklch(1 0 0 / 0.92→0.36)`), accent selection/focus, line-tinted scrollbars,
  JetBrains Mono first in the mono stack.

## Acceptance criteria

1. No hardcoded palette drift vs Darpan tokens for fg tiers, selection, focus ring.
2. Global run shortcut fires outside the editor; label shows the shortcut.
3. All 20 catalog examples still execute in-browser (`check:catalog` green).
4. Core untouched: `packages/core` byte-identical to `main`; 163 tests green.
5. Typecheck clean (core + docs).

## Plan

- Restyle toolbar CSS (one metric, primary/ghost/pill/select specs).
- Add platform-aware kbd chip + window-level keydown listener.
- Port Darpan canon tokens over the parity layer.
- Verify with executable checks, not source greps alone.

## Execution

- step 1 — toolbar matches site/Darpan button language: done: 3ee5156 (PR #12)
- step 2 — Darpan-canon tokens + chrome (fg tiers, chips, footer, empty state,
  error banner, shortcut): done: bb1af74 (PR #13)
