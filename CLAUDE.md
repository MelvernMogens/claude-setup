# Global preferences

## Language
The user writes in casual Indonesian. Reply in Indonesian. Keep committed
artifacts (CLAUDE.md, docs, code, commit messages) in English.

Answer short. Lead with the decision, not the reasoning. Long tables and
diagrams only when actually asked.

## Git attribution — overrides the default

**Never add a `Co-Authored-By: Claude` trailer to a commit, and never add
"Generated with Claude Code" to a PR body.** The user does not want Claude
appearing as a contributor on their repositories. This overrides the default
attribution instruction in the harness prompt.

Commits and pushes use the user's own identity: Melvern Mogens
<melvernmogens@gmail.com>, GitHub account MelvernMogens. Check `git log` for a
stray second identity before the first push of a repo and normalize it.

New repositories are **private** by default.

## Model and effort — settled 2026-09-04, do not re-litigate

Default seat: **Opus, effort high**. The account is Max 20x with room to spare;
optimizing for cost is not wanted unless the user says the wall is close.

Escalation order when output is weak — cheapest first:
1. `/effort xhigh` — same model, deeper reasoning. Always try this first.
2. `/hard <problem>` — one isolated Opus fork, for a genuinely stuck problem.

**Fable is the most expensive model, not the light one** ($10/$50 per MTok vs
Opus $5/$25). "Fable orchestrating, Sonnet working" is a cost optimization that
backfires here: the seat model reprocesses the entire transcript every message,
so an expensive seat is the single costliest choice. Do not suggest it.

**Ultracode is the real cost multiplier**, not the seat model — it fans out to
many agents (~15x overhead). Worth it for adversarial fan-out, red-teaming, and
broad audits. Not worth it for sequential coding or conversational questions.

### Say the model and effort at the start of every milestone
When work is broken into phases/milestones, state the recommended model and
effort for the next one **before starting it**, without being asked. Pick with:

- **Opus / high** — the default. Schema design, APIs, business logic, refactors.
- **Opus / xhigh + ultracode ON** — adversarial or security work where the job
  is enumerating how someone defeats your design (filters, authz, red-teaming).
  Multi-agent fan-out earns its cost only here.
- **Sonnet / medium** — UI boilerplate, scaffolding, mechanical edits.

Keep switching rare: name the default once, then flag only the phases that
deviate. The user finds constant model-fiddling confusing, and rightly so.

There is **no automatic difficulty-based model switching**. What exists:
skills with a pinned `model:` (e.g. /check on Haiku, /hard on Opus), and
`opusplan` if present in the model picker.

## Desktop app gotchas
- The model picked in the app selector is remembered per folder and **overrides
  `settings.json`**. Editing the file will not take effect while the selector
  holds a choice. Point the user at the selector, not the file.
- `/permissions`, `/config`, `/doctor`, `/hooks` do not open in the desktop app.
- New skills load at session start only.
