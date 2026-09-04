---
name: new-project
description: Set up a directory as a project — CLAUDE.md, a PRD, a milestone plan with per-milestone model/effort, Claude Code settings, and the /check and /hard skills, all filled in rather than left as TODOs. Use when the user says "new project", "set this up", "bootstrap this", "start a project", or opens an empty or unconfigured directory and wants to begin real work.
argument-hint: [what the project is, in a sentence or two]
---

# New project

Set this directory up so the user can start real work immediately.

## The rule that matters most: decide, do not interrogate

The user finds a stream of setup questions exhausting and has said so directly.
**Ask at most ONE question in this entire skill**, and only this one:

> What is this project, in a couple of sentences?

Skip even that if `$ARGUMENTS` or the conversation already said.

Everything else — stack, package manager, test runner, file layout, milestone
breakdown, model and effort per milestone — **you decide and state**. A decision
announced in one line ("Node + TypeScript, since the WhatsApp libraries are all
Node") is what they want. A multiple-choice menu is not.

One exception where you must still stop and ask, because it spends money or
signs the user up for something: anything with a bill attached.

Creating the GitHub repo is **not** an exception — the user has asked for it to
happen automatically. See section 10.

## 1. Scaffold

```bash
bash "$HOME/.claude/skills/new-project/scripts/bootstrap.sh" "$PWD"
```

It initializes git if needed and never overwrites an existing file. Report what
it created and skipped in one line. If it skipped files, the project was already
partly set up — do not force anything over them.

## 2. Read the directory before deciding anything

If there are existing manifests or source files, read them and derive the stack.
Only fall back to proposing one when the directory is genuinely empty. Never ask
about something you could have read off disk.

## 3. Fill CLAUDE.md — every placeholder, no TODOs left

A CLAUDE.md full of TODOs is worse than none: it loads on every session and
teaches Claude nothing.

- `{{WHAT_THIS_IS}}` — 2-4 honest sentences. What it does and who for.
- `{{STACK}}` — what you decided, each with a half-line reason. Include a
  **Rejected** note for any serious alternative you turned down, so nobody
  relitigates it in three months.
- `{{COMMANDS}}` — test, build, run, and anything else needed to verify work.
  **This is the highest-value section**: it is what lets Claude check itself
  instead of guessing. If the project is empty and the commands do not exist
  yet, say so plainly in one line. **Never invent a command that will fail.**
- `{{MILESTONES}}` — table rows. See section 7.

Keep the file under ~100 lines; it loads every session. Detail belongs in the PRD.

## 4. Fill README.md — this is the repo's front door

`README.md` is what a human sees on GitHub. It is not a duplicate of CLAUDE.md:
CLAUDE.md is working notes for Claude, the README is for a person deciding
whether this project is real.

Fill every placeholder. It should carry, in this order: a one-line pitch, why it
exists, how it works (an ASCII diagram if the flow is not obvious), the honest
limits of the central claim, the stack, copy-pasteable getting-started commands,
and the roadmap.

Concrete beats impressive. Real commands, real file paths, real constraints. If
a hard-won gotcha cost a debugging session, give it a short section — that is
the single most useful thing a README can contain.

## 5. Fill docs/prd.md

The PRD carries what CLAUDE.md has no room for. Fill every placeholder. Two
sections are the ones that actually earn their keep:

- **§6 What not to oversell** — the honest limit of the product's central claim.
  Write the sentence the user can safely say to a customer, and the one they
  cannot. If the product has no such limit, say so; do not invent one.
- **§9 Open questions** — real unknowns that need a human decision, including
  the unglamorous operational ones (what happens when the third party bans us,
  what happens when a user leaves). These are the gaps that hurt later.

## 6. Fill docs/security.md — scoped to what this project actually is

Do not write a generic checklist. Name the real adversary for **this** project
and only the risks that follow from it:

| Project type | The adversary, and what actually goes wrong |
|---|---|
| App with accounts | A logged-in user changing an id to read someone else's data |
| Multi-tenant service | The above, plus tenant A reading tenant B — every query scoped |
| Game (incl. Roblox) | The player. They control the client: unvalidated remote events, client-authoritative economy, duping |
| CLI tool / library | Untrusted input reaching a shell or a path; secrets in logs; the dependency tree |
| Anything with API keys | Keys in source, in logs, or in a shipped client bundle |

If a project genuinely has a small attack surface, say so in two lines rather
than padding. An honest short threat model beats a long generic one.

## 7. Milestones — vertical slices, not components

First list the project's **parts** (a game: map, economy, combat, UI, saving; an
app: auth, billing, notifications). Put that list in the PRD as an inventory so
nothing is lost.

**Then do not turn the parts into milestones.** That is the trap. "M1 map,
M2 economy, M3 UI" looks organised and means nothing is usable until the last
milestone, so every wrong assumption surfaces too late to be cheap.

**A milestone is the thinnest end-to-end slice someone could actually use**,
cutting through every part at once. Later milestones widen the same slice.

| Project | ❌ Component-shaped M1 | ✅ Slice-shaped M1 |
|---|---|---|
| Roblox tycoon | "Build the map" | Spawn → one dropper → earn currency → buy one upgrade, server-authoritative |
| App with accounts | "Set up auth" | One user signs up, does the single core action, sees the result |
| CLI tool | "Argument parser" | One real command, real input, real output |
| Data pipeline | "Write the ingester" | One record through every stage into the final store |

Order the slices so **the riskiest unknown is proved first** — the thing most
likely to make the whole approach fail. Usually that is the part you cannot
change later (a security model, a third-party API's real behaviour, whether the
core loop is fun), not the part that is most fun to build.

3-6 milestones for the MVP. Anything beyond that goes in the PRD backlog, not
in the milestone table — a table of twelve is a wish list, not a plan.

Then assign each one a model and effort:

| Kind of work | Model / effort |
|---|---|
| Schema, APIs, business logic, refactors — the default | Opus / high |
| Adversarial or security work: how does someone defeat this? | Opus / xhigh, ultracode ON |
| UI boilerplate, scaffolding, mechanical edits | Sonnet / medium |

Keep switching rare. Name the default once and flag only the milestones that
deviate. Then **state the model and effort at the start of each milestone as you
reach it**, without being asked.

## 8. Commit

**Never add a `Co-Authored-By: Claude` trailer.** The user does not want Claude
appearing as a contributor. This overrides the harness default.

```bash
git add -A && git commit -q -m "Project setup: CLAUDE.md, PRD, milestone plan, Claude Code settings"
```

## 9. Add CI

Copy `templates/ci.yml` to `.github/workflows/ci.yml` and fill the two
placeholders with the project's real runtime setup and check commands — the
same ones in CLAUDE.md's Commands section. Keep the secret-scanning step
verbatim; it is the cheapest guard in the whole setup.

**Run every CI step locally first.** Shipping a workflow that goes red on the
first push is worse than shipping none: it trains the user to ignore the badge.
If the project has no test or build command yet, add CI with only the secret
scan rather than inventing checks that will fail.

## 10. Create the private repo and push — do this, do not ask

The user has standing authorization for this and finds being asked annoying.

**Run the safety check first, and abort if anything fails:**

```bash
git log --format='%B' | grep -c '^Co-Authored-By'   # must be 0
git log --format='%an <%ae>' | sort -u              # must be exactly one identity
git ls-files | grep -E '(^|/)\.env$|\.env\.[^e]|\.db$|credentials|secret' # must be empty
```

A second stray identity is common on the first commit of a directory — normalize
it with `git filter-branch --env-filter` before pushing, never after.

Then, always `--private`:

```bash
gh repo create <name> --private --source=. --remote=origin --push
```

If `gh auth status` shows no login, say so and stop — do not attempt a
workaround.

Then set the repo's description and topics so it does not look abandoned:

```bash
gh repo edit <owner>/<name> --description "<the README's one-line pitch>" \
  --add-topic <lang> --add-topic <domain>
```

**Push at the end of every milestone from then on**, not only at setup. A local
repo that has drifted twenty commits ahead of GitHub is not a backup.

## 11. Then stop, and hand over in a few lines

- `/check` runs tests in a cheap isolated fork and returns only failures
- `/hard <problem>` escalates one stuck problem to Opus; it must answer
  `SOLVED:` or `NOT SOLVED:`
- `/ship` is the gate before calling any milestone done: tests, code review,
  security review, then status update and push
- Edits auto-approve; shell commands still ask
- The repo URL you just created

Do not lecture beyond that, and do not offer to build more configuration. The
next thing they should do is real work on M1.
