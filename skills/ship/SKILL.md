---
name: ship
description: Verification gate before calling a milestone or a feature done — runs the project's own tests, reviews the diff for correctness bugs, reviews it for security issues appropriate to the project type, then updates status and pushes. Use when the user says "ship it", "done", "milestone selesai", "cek dulu sebelum selesai", or before declaring any chunk of work finished.
argument-hint: [optional: which milestone or feature is being shipped]
---

# Ship

A gate, not a ceremony. Work is not done because it looks done — it is done
when the checks pass and you have said so honestly.

Shipping: $ARGUMENTS

## The rule

**Never report a pass you did not observe.** If a step fails, the answer is
"not shipped, here is what broke". A green summary over a red test is the one
failure mode this skill exists to prevent. Do not fix-and-declare in the same
breath either: fix, re-run, then report what the re-run actually said.

## 0. Pick the tier — a gate with uniform cost on non-uniform work gets skipped

Look at the diff since the last ship (`git diff --stat "$(git log --grep='^ship(' -1 --format=%H)"..HEAD` — falls back to `HEAD~5` if there is no marker yet), then pick:

| Tier | When | Run |
|---|---|---|
| **light** | docs, comments, config, or one file with no logic change | tests + push |
| **standard** | the usual milestone | tests + `/code-review` + push |
| **full** | touches auth, data model, a security boundary, or anything in `docs/security.md`'s rules | everything, including `/security-review` |

Say which tier you picked and why, in one line. When unsure, go up a tier.
Skipping `/security-review` on a diff that touches the protected asset is the
one mistake this table must never produce.

## 1. Does it still build and pass?

Read `CLAUDE.md` for the project's real commands. Run the test command, then
the typecheck/build if one exists. If there are no tests yet, say that plainly
— do not treat "no tests" as "tests passed".

If the output is likely to be long, use `/check` — but note it is a
**project-local** skill at `<project>/.claude/skills/check/`, placed there by
`/new-project`. In a project that did not come from that scaffold it does not
exist; run the commands directly instead of reporting that the check is
unavailable.

## 2. Review the diff for bugs

```
/code-review
```

Review only what changed. Fix what is real; for anything you judge a false
positive, say which and why rather than silently dropping it.

## 3. Review the diff for security — scoped to what this project actually is

```
/security-review
```

Then apply the lens that fits. Pick from the table; ignore rows that do not
apply rather than inventing findings to fill them.

| Project type | What actually goes wrong |
|---|---|
| **App with user accounts** | Broken access control: one user reading another's data by changing an id. Data returned that the client should never see. Session/token handling. |
| **Multi-tenant service** | All of the above, plus tenant A reading tenant B. Every query must be scoped, not just the obvious ones. |
| **Game (incl. Roblox)** | Trusting the client. Unvalidated remote events, client-authoritative movement/economy, duping, values changeable from the client. Assume the player is hostile and has full control of their machine. |
| **CLI tool / library** | Arbitrary code or command execution from input, path traversal, secrets printed into logs or error messages, supply chain of what you depend on. |
| **Anything with API keys** | Keys in source, in logs, in the client bundle, or committed by accident. |
| **Anything public** | Dependency CVEs (`npm audit`, `pip-audit`, equivalent), and whether an unauthenticated endpoint exists that should not. |

Two checks worth running on every project regardless of type:

```bash
git ls-files | grep -E '(^|/)\.env$|\.pem$|\.key$|credentials|secret'   # must be empty
git log --format='%B' | grep -ci 'password\|api[_-]key\|token.*=' | head  # sanity check
```

If the project has a `docs/security.md`, re-read it and update it in this same
commit when an assumption has changed. A threat model that is never revisited
is decoration.

## 4. Update status

Mark the milestone done in `CLAUDE.md` (and the README roadmap if there is one)
with the date. Move the next milestone to "next" and state its model and effort.

## 5. Commit and push

**Never add a `Co-Authored-By: Claude` trailer.**

Prefix the subject with `ship(<milestone or feature>):` so the next session can
find this commit mechanically. That marker is the durable baseline — a
`git rev-parse HEAD` captured in a session is lost on `/clear` and wrong after
any hand commit, but the marker survives both.

```bash
git add -A && git commit -q -m "ship(M2): <what shipped, and what verified it>"
git push
```

If there is no remote yet, create one — private:

```bash
gh repo create <name> --private --source=. --remote=origin --push
```

Then confirm CI went green. A push is not a ship until the build is green; if
CI fails, say so and fix it rather than leaving a red badge.

## 6. Report

Short, and factual:

- what shipped
- the actual result of each check — the numbers, not "all good"
- anything you chose not to fix, and why
- what is next, with its model and effort

If something is still broken, lead with that.
