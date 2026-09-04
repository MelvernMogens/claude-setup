# claude-setup

My Claude Code setup, versioned so it survives a laptop and follows me to any
machine. Everything here lives in `~/.claude/`, which is otherwise unversioned
and backed up by nothing.

## On a new machine

```bash
git clone git@github.com:MelvernMogens/claude-setup.git ~/Code/claude-setup
~/Code/claude-setup/install.sh
```

Then restart Claude Code — skills load at session start.

## After changing a skill

Edits happen in `~/.claude/` (that is what Claude Code reads). Pull them back
into this repo when you are happy with them:

```bash
~/Code/claude-setup/save.sh
git -C ~/Code/claude-setup diff        # read it before committing
git -C ~/Code/claude-setup add -A && git -C ~/Code/claude-setup commit -m "..."
git -C ~/Code/claude-setup push
```

`save.sh` also warns about skills in `~/.claude` that this repo does not track
yet, so a new one is not silently left out of the backup.

## What is here

| | |
|---|---|
| `CLAUDE.md` | Global preferences: default model and effort, git attribution rules, desktop-app gotchas. Loads in **every** project. |
| `skills/new-project/` | `/new-project` — scaffolds a project with CLAUDE.md, README, PRD, threat model, CI, and a private GitHub repo, all filled in rather than left as TODOs. Asks at most one question. |
| `skills/ship/` | `/ship` — the gate before calling a milestone done: tests, `/code-review`, `/security-review`, status update, push. |

## What is deliberately not here

- `~/.claude/plugins/` — a cache; re-downloads itself.
- `~/.claude/projects/` — session transcripts and per-project memory. Large, and
  specific to one machine's history.
- `~/.claude/settings.json` — machine-local. Per-project settings live in each
  project's own `.claude/settings.json`, which is committed with that project.

## Why copies and not symlinks

`install.sh` copies rather than symlinking. A symlinked skill directory would
keep the two in sync automatically, but if Claude Code ever failed to follow the
link the skills would vanish **silently** — the exact failure mode this setup
exists to avoid. Copying is duller and cannot fail quietly; `save.sh` is the
cost of that.
