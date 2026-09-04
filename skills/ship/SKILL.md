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

## 1. Does it still build and pass?

Read `CLAUDE.md` for the project's real commands. Run the test command, then
the typecheck/build if one exists. If there are no tests yet, say that plainly
— do not treat "no tests" as "tests passed".

Use `/check` if the output is likely to be long; it runs in a cheap fork and
returns only failures.

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

```bash
git add -A && git commit -q -m "<what shipped, and what verified it>"
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
