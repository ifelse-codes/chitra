# Independent Audit Prompt (blind pass)

> Paste this to a **different** model/agent, in this repo, **with no other context**.
> It is deliberately blind: no findings from the first audit are included, so its
> answer can be diffed against `code-cleanup-plan-session-41.md` to catch what one
> reviewer missed. Have it write its answer to `independent-audit-RESULT.md`.

---

You are auditing this repository before it flips from private to **public on GitHub**.
The npm package `@ifelse.codes/chitra@0.3.0` is already published. Goal: produce a
cleanup plan — **what to remove, what to edit, what to add** — so the public repo
looks professional and tells no lies.

Work only from evidence you gather yourself. Every claim must cite a file:line or a
command you actually ran and its output. If something is fine, say it's fine.

## Scope (run all of these)

1. **Inventory** — `git ls-files` by directory (501 files). Classify every top-level
   directory: product code / docs site / build config / tests / history / dead weight.
2. **Secrets & privacy** — scan the working tree AND git history
   (`git log -p --all`) for tokens, keys, credentials, emails, home-directory paths,
   machine-specific absolute paths. Report hit or clean, with method.
3. **Dead code & cruft** — TODO/FIXME/HACK, `debugger`, stray `console.*`, unused
   files, scaffold leftovers, untracked files that would ship on a careless
   `git add -A`, scripts that reference things that don't exist.
4. **Public-facing honesty** — every claim a visitor or consumer sees: README,
   CONTRIBUTING, replit.md, package.json metadata, badges, version constants in
   source vs the manifest, install/run instructions (**try them**), license files.
5. **Dependency hygiene** — for the docs app and workspace: list dependencies that
   are installed but never imported; components that exist but are never used;
   workspace packages nobody consumes; lockfile/config cruft from templates.
6. **Fresh-clone experience** — from a clean checkout, do these work with no env
   vars set: `pnpm install`, `pnpm run build`, `pnpm run lint`,
   `pnpm --filter @ifelse.codes/chitra run test`, the example run command in
   CONTRIBUTING. Record exact pass/fail and why.
7. **CI & tooling** — do the workflows gate what the docs claim they gate? Any
   check that is hollow (greps a string, guards a file that doesn't exist, passes
   vacuously)? Any promised tool that isn't installed?
8. **OSS readiness** — what would a outside contributor hit in the first 10
   minutes? Missing SECURITY.md / CoC / issue templates / PR template / coverage
   claim without a gate, etc.

## Deliverable — write to `independent-audit-RESULT.md`

- **Verdict** in 3 lines: is this repo ready to go public? What is the single
  biggest risk?
- **REMOVE** table: what, file count, evidence it's dead.
- **EDIT** table: file:line, the false/broken thing, the fix.
- **ADD** table: what, why the public launch needs it.
- **Founder decisions** needed (things no agent should decide alone).
- **Verified-clean list** — what you checked and found genuinely good (so the next
  reader doesn't re-audit it).
- **Batched execution order**, where every batch ends with a green gate
  (name the exact commands).

## Rules

- Max 2 assumptions — if you need more, stop and list your questions instead.
- Do not trust any file that describes the repo's state (STATE.md, ROADMAP.md,
  summaries, prior reports). **Verify against the live tree.** If a description
  disagrees with reality, that disagreement is itself a finding — report it.
- Do not modify any file except `independent-audit-RESULT.md`.
- Do not commit anything.
- Be adversarial: a green check that doesn't prove what it claims is a bug.
