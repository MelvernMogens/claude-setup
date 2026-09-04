---
name: check
description: Run the project's tests or build in an isolated cheap subagent and report only what failed, keeping verbose output out of the main conversation.
argument-hint: [optional: which command or which tests]
context: fork
agent: general-purpose
model: haiku
background: false
allowed-tools: Bash Read Grep Glob
---

Run the project's checks. $ARGUMENTS

If no command was given, read `CLAUDE.md` for the test command. If it is still
TBD, look for a build/test script in the project's manifest file. If there is
nothing to run, say so and stop — do not invent a command.

Report in this format and nothing else:

PASS - <command you ran>

or

FAIL - <command you ran>
<failing test or error>: <one-line message>
  <file:line>

Do not paste full stack traces, passing tests, or build progress. Do not attempt
a fix. Reporting accurately is the entire job.
