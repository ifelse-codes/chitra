# Session 09 — design-language rebuild: braille-dot circular charts (founder direction)

## Goal (one story)
Rebuild the chitra chart look to match the `design-reference/` language (tui-chart ·
mudra-chart · mudra-dashboard) and LOCK it so every future chart carries the same
look and feel. Founder feedback: current charts are "not looking that great."

## Context
- `design-reference/` holds the target language: terminal-native panels, one-hue
  refinement, dashed frames, tone + accent, no rainbow-only series identity.
- S08 landed line/SVG/dashboard upgrades and the dashed-panel terminal look.

## Deliverables
- **Braille-dot circular chart look (pie + donut), LOCKED** — the reference design
  for every future chart:
  - Circle drawn as braille sub-pixels (2×4 dots/cell, 2×2 supersampled per dot) at
    dot-space resolution → genuinely round, smooth, vertically symmetric rim.
  - No fill patterns (`█▓▒░▚▞`), no density stripes, no radial seams, no in-wedge
    labels — clean solid disc, round rim.
  - Slice separation = one accent hue on the largest slice + grey tone ramp
    (`#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`); in plain mode the legend separates.
  - Dashed panel frame (`┌╌…╌┐`, `│ ╌…╌ │`), eyebrow row, right-aligned legend
    beside the ring, optional status row, donut centre total.
- **Area chart carries the same language** — line = the fill's interpolated top edge
  (no separate stroke pass), y-range auto-scales to the data, empty cells are spaces
  (never blank-braille `⠀`), accent only on the peak cap + footer `max` value.
- **Glyph-complete mono font requirement** — braille needs a font with all 256
  glyphs and matching advance width (Cascadia Mono verified); docs font stack must
  lead with one or braille columns misalign in the browser.
- **Design contract recorded** — "LOCKED: circular charts" + "LOCKED: area chart"
  sections in `packages/core/README.md`, synced into `.ai/KNOWLEDGE.md` /
  `.ai/ROADMAP.md`.
- **Handoff for LLM polish** — `scripts/ring-polish-handoff.mjs` (self-contained,
  zero-import, prints pie/donut in plain + color) so another model can iterate the
  look without touching the lib.
- Docs gallery regenerated; tests updated for the braille look; session verify/demo
  scripts; session 09 summary.

## Exit Criteria
- `scripts/verify-session-09.sh` exits 0 (31 checks).
- `scripts/verify-closeout.sh` exits 0 with a session-09 review.
- Core tests green (130), `pnpm --filter @chitra/core run typecheck` exit 0.

## Guardrails
- Branch `session-09-design-reference` from `main`.
- Commits need approval token (VAJRA_ALLOW_COMMIT=09).
- Invariants: zero runtime deps, AI-agent output surface (`toPlain()`/`toJSON()` +
  `noColor`) unbroken, public API stability, generated previews stay source-of-truth.
- Max 2 assumptions; ≤3 files per atomic commit.
- **Braille rendering requires a glyph-complete mono font** — keep Cascadia Mono at
  the head of the docs font stack.
