# Session 00 — Brownfield Onboarding (study the codebase)

> This project existed before Vajra. Session 00 is a guided study session: learn the
> codebase, then fill the `.ai/` files with reality instead of empty templates. No
> feature work happens here — session 01 (`prompts/01-task-kickoff.md`) starts on facts.

## Goal (one story)
Study the existing repo and seed `.ai/KNOWLEDGE.md` + `.ai/STATE.md` with a real
first-pass understanding.

## Steps
1. **Scan the repo** — layout, languages, entry points, how to build/test/run, CI,
   existing docs. Read the top-level manifests (package.json / Cargo.toml / etc.) first.
2. **Ask the founder** (max 5 framing questions) — what is this project, what state is it
   really in, what is the next milestone, what must never break, any no-go areas?
3. **Fill `.ai/KNOWLEDGE.md`** — permanent facts only: stack, commands, conventions,
   invariants, environment quirks. If you can't verify a fact, don't write it.
4. **Rewrite `.ai/STATE.md`** — What Currently Works / What Is Broken from observed
   reality (run the tests; the results are the evidence).
5. **Seed `.ai/ROADMAP.md`** with the founder's next milestone, then point `.ai/TASK.md`
   at `prompts/01-task-kickoff.md` and set `.ai/SESSION` to 01.

## Guardrails
- **Docs only**: `.ai/` files. No source-code edits, no refactors, no "quick fixes".
- Branch `session-00-onboarding` from `main`. Commits need the founder's approval token.
- Max 2 assumptions; unverifiable claims are questions for the founder, not facts.

## Exit Criteria
- Founder signs off that `KNOWLEDGE.md` + `STATE.md` match reality.
- Session 01 starts in a **new chat** from `prompts/01-task-kickoff.md`.
