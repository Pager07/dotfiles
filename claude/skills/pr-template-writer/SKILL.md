---
name: pr-template-writer
description: Generate PR descriptions following the project template. Use when creating pull requests after completing code changes.
---

# PR Template Writer

Generate pull request descriptions for TutorCruncher following the project's PR template format.

## Output Format

**IMPORTANT: Always output the final PR template inside a markdown code block (triple backticks) so it can be easily copied.**

Example output format:
~~~
```markdown
**Issue number: Close #XXXX**

## Title

### Technical description of changes
...

### Description for the non-dev team to understand
...

## Manual testing required
...

## Check
* [ ] Issue number added
* [ ] Tests
* [ ] Help docs written and links added
* [ ] Coverage
* [ ] Correct labels applied
```
~~~

## PR Template Structure

1. **Issue number** - Link to the GitHub issue being closed
2. **Title** - Brief summary of the changes
3. **Technical description** - Detailed technical explanation for developers
4. **Non-dev description** - Plain language explanation for non-technical team members
5. **Manual testing required** - Steps for QA testing
6. **Check** - Checklist of PR requirements

## Instructions

1. Review the git diff and commit history to understand all changes
2. Identify the issue number from branch name or commits
3. Write clear technical description covering:
   - What was changed
   - Why it was changed
   - How it was implemented
4. Write non-technical description that:
   - Explains the user-facing impact
   - Avoids jargon
   - Describes the before/after behavior
5. Output the complete PR template in a markdown code block

## Frontend Migration PRs (Tailwind/UI 2.0)

For any frontend migration PRs (Bootstrap to Tailwind, UI redesign, etc.), use this specific format:

### Title format
```
Tailwind migration | <what was converted>
```
Example: `Tailwind migration | Contractor Detail Activity Task form tailwind migration`

### Body format
Keep it dead simple. No file lists, no over-explanation.

~~~
```markdown
**Issue number: #15681**

### Technical description of changes
<1-3 sentences. What forms/templates were converted and the approach taken.>

### Screenshots
**Before**
<screenshot>

**After**
<screenshot>

### Description for the non-dev team to understand
<Plain English. Where in the app to find the change and what looks different. 1-2 sentences.>

## Manual testing required
- <Step-by-step navigation to the changed UI>
- <What to test>

## Check
* [x] Issue number added
* [x] Tests
* [x] Help docs written and links added <-- To be done with the support team.
* [x] Coverage
* [x] Correct labels applied
```
~~~

**Key points for migration PRs:**
- **Issue number is always `#15681`** for frontend migration PRs.
- **Base branch must be `ui2.0`** - all frontend migration PRs target `ui2.0`, NOT `master`. When creating the PR with `gh pr create`, always use `--base ui2.0`.
- Technical description should mention what was converted (e.g., "form X from Bootstrap to Tailwind") and the approach if non-obvious
- Non-dev description should say where in the app the change is visible (e.g., "In the Contractor details page, the Notes modal now uses the new styling")
- Screenshots are essential - always include before/after (the user will paste these)
- Manual testing should give exact navigation steps to reach the changed UI

## Style Notes

- **Never use em dashes (`—`)** in the output. Use regular dashes (`-`) or rewrite the sentence instead. Em dashes give an AI-written vibe.
- **Focus on the problem and solution, not on which files changed.** Do not list filenames or describe changes file-by-file. Both the technical and non-technical descriptions should explain what the problem was and how it was solved at a conceptual level. Developers can see the changed files in the diff.
