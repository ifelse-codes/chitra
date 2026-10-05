# Session 47 — P1 residual support ticket (R8, owed from S46)

**State:** ticket text prepared + read-only proof recorded; filing itself needs a
human in GitHub Support (no API for PR-ref deletion). If you hold the repo, file
this and record the ticket ID in `.ai/STATE.md`.

## Evidence (re-derive)

```
$ gh api repos/ifelse-codes/chitra --jq '{private, visibility}'
{"private":false,"visibility":"public"}

$ git ls-remote origin 'refs/pull/*/head' | wc -l
70   # 68 at S46 audit time; PR refs accumulate, none GC'd

$ gh api -X DELETE repos/ifelse-codes/chitra/git/refs/pull/67/head
422 {"message":"refs/pull/* is read-only.", ...}
```

P1's done-condition (nothing matching `(/|-)Users[-/][a-z]+` in any commit
reachable from `HEAD`) holds — re-derived by `p1-history-and-tree-clean` in
`scripts/verify-session-46.sh`. The residual is ONLY in unreachable
`refs/pull/*` heads (pre-rewrite blobs, PRs #9–#64 at S46 time), which no push,
fetch refspec or API DELETE we own can remove.

## Request to file (GitHub Support → Repositories → Deleted refs / GC)

> Repository `ifelse-codes/chitra` completed an authorized history rewrite
> (`git filter-repo`, 1001 → 0 commit-file pairs) to remove a personal home path,
> then went public. `refs/pull/*` heads still serve the pre-rewrite objects and
> the ref namespace is read-only (DELETE → 422, quoted above). Please delete all
> `refs/pull/*/head` + `refs/pull/*/merge` refs created before 2026-10-04 and run
> garbage collection so the unreachable pre-rewrite objects are pruned. Confirm
> when `git ls-remote origin 'refs/pull/*/head'` no longer serves them.

## Done-condition (R8)

- [ ] Ticket filed with the text above → record ID + date in `.ai/STATE.md`.
- [ ] Support confirms deletion + GC → re-run the three commands; PR-head count
      drops and a deliberate fetch of an old head 404s.
- Until then: residual stays DISCLOSED, not closed — same status S46 left it in.
