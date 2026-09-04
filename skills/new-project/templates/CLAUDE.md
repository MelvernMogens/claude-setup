# {{PROJECT_NAME}}

## What this is
{{WHAT_THIS_IS}}

## Stack
{{STACK}}

## Commands
{{COMMANDS}}

## Milestones — status and which model to use
Product scope, non-goals, and open questions live in `docs/prd.md`.

| # | Scope | Status | Model / effort |
|---|---|---|---|
{{MILESTONES}}

Default is Opus + high. Raise to xhigh + ultracode only for adversarial or
security work; drop to Sonnet + medium for UI boilerplate.

**State the model and effort at the start of every milestone, before working.**

## Conventions
- Ask before adding a dependency.
- Never commit secrets. Credentials go in `.env`, which is gitignored and denied to Claude.

## House rules for Claude
- Show a plan before multi-file changes.
- After editing, run the test command and report the real result, not the expected one.
- If you are unsure, say so instead of guessing.

<!--
Keep this file under ~100 lines. Add a line only after correcting the same
thing twice. This file is the project's source of truth and is committed to git.
-->
