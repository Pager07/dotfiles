---
name: explain
description: Give a high-level, 1-2 paragraph plain-prose explanation of whatever the user is pointing at — a PR, file, function, bug, error trace, config, or whatever is currently in conversation context. Use when the user wants to "zoom out" and understand what's going on, not a deep dive or line-by-line tour.
---

# Explain

The user wants the elevator pitch for whatever they're looking at. Step back, figure out what's actually going on, and explain it like you would to a colleague who just walked into the room.

## How to invoke

`/explain [optional target]`

Examples:
- `/explain` — explain whatever is currently in context (the PR we just pulled up, the file I'm editing, the bug we've been chasing). Infer from recent conversation.
- `/explain https://github.com/org/repo/pull/123` — explain that PR
- `/explain TutorCruncher/accounting/generate/_charges.py` — explain that file
- `/explain this function` / `/explain the bug` — explain whatever the user is pointing at in context

## What to do

1. **Identify the target.** If an argument is given, that's the target. If not, infer from recent conversation — usually the most recently discussed PR, file, function, error, or task.
2. **Gather just enough context.** Read the file, fetch the PR diff, look at the error — whatever's needed to understand the *what* and *why*. Don't go deeper than necessary.
3. **Write 1-2 paragraphs of plain prose.** That's it.

## Output rules — strict

- **1-2 paragraphs maximum.** Not three. Not "1-2 paragraphs plus a quick note."
- **Plain prose only.** No headers, no bullet lists, no code blocks (unless quoting a single short identifier inline), no tables, no file walkthroughs, no test plans, no "verdict" sections.
- **High-level, conceptual.** Answer "what problem and what approach" or "what is this thing and why does it exist." Do not narrate the code line-by-line. Do not list every file changed.
- **Conversational tone.** Like explaining to a colleague over coffee, not writing a doc.
- **No preamble.** Don't say "Here's a high-level explanation of..." Just start explaining.
- **No trailing offers.** Don't end with "want me to dig deeper?" or "let me know if..." — the user knows they can ask.

## Shape of a good explanation

For a **bug fix PR**: paragraph 1 = what was broken and why (the mechanism); paragraph 2 = how the fix addresses it.

For a **feature**: paragraph 1 = what need it serves and where it fits; paragraph 2 = how it works at a conceptual level.

For a **file/module**: paragraph 1 = what role it plays in the system; paragraph 2 = the key idea or pattern that makes it tick.

For a **bug being debugged**: paragraph 1 = the symptom and the suspected mechanism; paragraph 2 = what we know so far and what's still unclear.

For an **error trace**: paragraph 1 = what was being attempted and what went wrong; paragraph 2 = the likely root cause.

If the target is genuinely ambiguous (multiple recent things it could be), ask one short clarifying question instead of guessing.
