# Repository settings — recorded facts

These are the values `SECURITY.md` and `CODE_OF_CONDUCT.md` promise routes depend on. They are
**remote** state, so they cannot be read by an offline gate; they are recorded here, with the
command that re-derives each one, and the S44 gate checks the public docs against this file.
A stale row here is a public doc pointing at a closed door, so re-derive before trusting it.

Recorded 2026-10-04 on `session-44-oss-polish`. **Re-derived 2026-10-04 on
`session-46-public-flip`, immediately after the visibility flip** — the flip invalidated every row
here, which is exactly what F4 exists to prevent. Before/after pairs, with the commands that
reproduce both readings, are in `sessions/session-46-flip.md`.

| setting | value (post-flip) | re-derive with |
| --- | --- | --- |
| `private` | `false` — pre-flip reading `true` | `gh api repos/ifelse-codes/chitra --jq .private` |
| `visibility` | `public` — pre-flip reading `private` | `gh api repos/ifelse-codes/chitra --jq .visibility` |
| `has_issues` | `true` | `gh api repos/ifelse-codes/chitra --jq .has_issues` |
| `blank_issues_enabled` | `false` | `.github/ISSUE_TEMPLATE/config.yml` (tracked, so a gate can read it) |
| `has_discussions` | **`false`** | `gh api repos/ifelse-codes/chitra --jq .has_discussions` |
| private vulnerability reporting | **`enabled`** — `{"enabled":true}` | `gh api repos/ifelse-codes/chitra/private-vulnerability-reporting --jq .enabled` |

**Why the reporting row could not be settled before the flip.** Pre-flip that same `GET` returned
**404**, and so did the `PUT` that enables it, from an account with `admin: true` — GitHub serves
this endpoint for **public** repositories only. A public-repo control (`octocat/Hello-World`) read
`{"enabled":false}` while ours read 404, which is what proves the 404 meant "private repo", not
"off" and not "no permission". The precondition was therefore reordered to F1 → P2 rather than
waived; the decision is recorded as `D-REORDER` in `sessions/session-46-flip.md`.

## What this means for a reader's route

- **The repository is public.** An anonymous client can clone it (`git clone
  https://github.com/ifelse-codes/chitra.git` resolves, and `private` reads `false`); before the
  flip both readings were `404` / `true`.
- **Issues are on, blank issues are off.** GitHub's behaviour with `blank_issues_enabled:
  false` is that the *new issue* page offers only the configured templates — so a visitor can
  still open a **bug** or **feature** report, and cannot open an untemplated issue. Saying
  "open a blank issue" would be wrong; saying "open a bug report" is right.
- **Discussions are off.** Routing anyone to a discussion is routing them nowhere. That is why
  `CODE_OF_CONDUCT.md` uses the report forms.
- **Private reporting is established.** The row reads `enabled`, so `SECURITY.md`'s first route
  (Security tab → *Report a vulnerability*) now exists rather than being conditional on an unset
  switch. The fallback route those files describe is a **fallback** now, not the only channel —
  and it stays written, because the hedge costs nothing and the row can be turned off again.

## What the gate actually checks — and what it does not

`oss-surface-present` enforces three offline clauses, and nothing else about these settings:

1. the `has_discussions` row above — if it reads `false`, no reader-facing file may mention
   Discussions;
2. `blank_issues_enabled` from `.github/ISSUE_TEMPLATE/config.yml` — if `false`, a reader-facing
   file that sends someone to an issue must name a form;
3. any reader-facing file offering `security/advisories/new` must hedge it in the same file.

Clause 3 is **not** keyed to this table's reporting row: no offline gate can read remote state, so
the hedge is required whether the row reads `enabled` or not, and it stays correct if the switch
is ever turned off. It does **not** read the `private` row or the `has_issues` row either, and it
does not check whether the docs and npm links resolve — that is a network fact, checked by hand
and recorded in `sessions/session-46-flip.md`, not by this gate. Anyone extending these clauses
must widen this paragraph in the same commit, or this file will advertise an invariant the gate
does not keep; pass 5 caught exactly that.
