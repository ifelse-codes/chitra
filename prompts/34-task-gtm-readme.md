# Session 34 — task: GTM README (the GitHub front door)

Founder direction (in-chat, S34): the repo has no root README and
`packages/core/README.md` is a 785-line API/design reference, not a landing
page. Design **one good root `README.md` as a go-to-market asset** — the first
thing a stranger (AI builder first, terminal dev second) reads. One story.

## Numbered requirements

1. **New root `README.md`.** The repo currently has no root README. Create one
   that leads with the positioning line ("Terminal charts for CLIs and agents."),
   a one-glance hero (what it is + why it matters), and a badge row (npm, MIT,
   zero-deps, tests).
2. **10-second proof.** Install line + a copy-paste quickstart that renders a
   real chart, plus real rendered chart output embedded from the library (not
   hand-drawn mock-ups).
3. **AI-builder lane first.** A dedicated AI-agent section (the lead audience):
   `toContent()` / `toPlain()` / `toJSON()`, no ANSI noise, MCP hand-off, with a
   link to the AI-data manual. Terminal-dev features (renderers, themes, fluent
   API) follow as the second audience.
4. **Chart gallery + navigation.** A compact "20 chart types" gallery and links
   to the live docs (`chitra.iifelse.com`), the API reference
   (`packages/core/README.md`), and the AI-data manual.
5. **Honest + verifiable facts.** Every number in the README must be true of
   `main` today (chart count, renderer count, theme count, dependency count,
   test count) — no stale claims. Embedded chart output must be real renderer
   output, drift-checked by the verify script. `scripts/verify-session-34.sh`
   exits 0 and `scripts/demo-session-34.sh` exits 0.
6. **MIT LICENSE file.** No LICENSE is tracked today, yet the README claims MIT
   and `packages/core/package.json` already ships `files: [..., "LICENSE"]`.
   Add the standard MIT text so the claim is verifiable and the publish is
   correct.

## Out of scope (discovered, deferred)

- The docs-site hero pills still read `v0.1.0 — stable` and `134 Tests passing`
  (stale — no tag yet, 452 tests). GTM-consistency fix, **not** this session's
  story; logged as a follow-up candidate.

## Guardrails

- `packages/core/README.md` is the API/design reference and stays intact
  (link to it, do not rewrite it).
- Zero runtime deps and the public API are untouched (docs-only session).
