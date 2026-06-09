---
name: review-pr
description: Review a pull request on the current branch by fetching the PR description, reading the diff against master, and carefully reviewing changed files for bugs and regressions. The user supplies the PR number as an argument.
---

# PR Review

The user will supply a PR number as an argument to this skill (e.g. `/review-pr 16352`). Use that number wherever `#<PR_NUMBER>` appears below.

Please review the current branch by doing the following:

1. Please grab the PR desc #<PR_NUMBER>
2. Please read diff with master and grab the changes
3. Read the diff changes
4. For files with substantial changes (>20 lines) read the complete file using `ReadTool`
5. Review very carefully for possible bugs and regressions

### Highly important instruction
Please ensure you don't violate the step 4 in any form. `ReadTool` helps you understand the grabbed changes holistically.

### Deliverable
Produce a review.
