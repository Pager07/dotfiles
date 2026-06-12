---
name: pr-explain
description: Explain and triage a pull request by collapsing its diff into a handful of risk-tagged logical changes, each narrated as before→after *behavior* (not syntax), with Before/After code shown only on the changes that matter. Use when the user wants to understand what a PR does and where to focus their review — bridging the gap where a raw GitHub diff shows *what* changed but not *why* or which parts carry risk. Not a line-by-line bug hunt (use /code-review for that), not a 1-2 paragraph summary (use /explain). The user may supply a PR number as an argument.
argument-hint: [PR number]
---

# PR Explain — triage a PR's diff into logical changes

A raw GitHub diff shows you *what* lines changed but not *why*, what *behavior* changed, or *where to focus* — so reviewing forces you to already have deep knowledge of that area of the code. This skill closes that gap: it collapses a whole PR into a few **logical changes**, narrates each as before→after **behavior**, tags each by **risk**, and shows Before/After code only on the parts that actually matter.

## How to invoke

`/pr-explain [PR number]`

Examples:
- `/pr-explain` — explain the PR for the current branch (infer it from the branch).
- `/pr-explain 16493` — explain that PR number.
- `/pr-explain https://github.com/org/repo/pull/123` — explain that PR.

If `$ARGUMENTS` is empty, infer the PR from the current branch (`gh pr view`).

## What to do

1. **Identify the PR.** Use the number/URL in `$ARGUMENTS` if given; otherwise `gh pr view --json number,title,body,baseRefName,headRefName` for the current branch.
2. **Read the intent.** The PR description is the stated goal — it becomes your one-line top and the anchor for every "why". If the description is thin, say so; don't invent intent.
3. **Diff against the PR's *actual* base — not assumed `master`.** Get `baseRefName`, find the merge-base (`git merge-base HEAD <base>`), and diff against it (`git diff <merge-base>...HEAD`). Bases are often release branches (e.g. `ui2.0`), and diffing the wrong base produces a garbage file list.
4. **Read for real — this is mandatory, not optional.** For any file with substantial changes (>20 lines) `Read` the complete file, and read the definitions/callers of key symbols the diff references. Intent narration is only trustworthy when it's grounded in the surrounding code. Guessing intent from diff lines alone is the exact failure mode this skill exists to fix — do not reproduce it.
5. **Collapse files → logical changes.** A PR of N files is usually a handful of *ideas*. Group hunks by idea, not by file: one idea can span several files; one file can hold several ideas. This collapse (e.g. "18 files → 3 changes") is the core move.
6. **Triage each logical change by risk** (tags below) and **narrate it as was → now → why, in behavioral terms.**

## Risk tags

- 🔴 **needs the reviewer's brain** — behavior, permissions, security posture, auth, money, data/migrations, public API. Anything where being wrong has consequences. This is where review attention belongs.
- ⚪ **mechanical** — one pattern repeated across many sites; a rename; a move. The review here is *completeness + no leftover/old references*, NOT reading each near-identical hunk.
- 🟢 **trivial** — tests, config, comments, generated files, formatting. Confirm they match the change; don't dwell.

## Output rules — strict

- **Open with the PR goal in ONE line**, drawn from the description.
- **Organize by logical change, never by file.** Number them and tag each 🔴/⚪/🟢, with a file count.
- **Describe behavior and intent, not syntax.** "X used to happen, now Y happens, because Z" — not "line 40 changed."
- **Surface the distinctions the raw diff hides.** A large hunk can be a behavioral no-op; a one-line change can flip who-can-do-what. Watch for things diffs flatten: reading a value once-at-load vs. per-request, a live source vs. a frozen/rendered one, a broadened/narrowed condition or permission. Never conflate "lines changed" with "behavior changed". If you're unsure whether a change is behavioral, read the code until you know — don't hand-wave, and don't mislabel.
- **Show file name + Before/After code only where it matters:**
  - 🔴 → show `file path` + a **Before** / **After** pair, minimal: the few lines that carry the meaning plus a couple of anchor lines.
  - ⚪ → show ONE representative Before/After, then just *list* the other file paths. Don't repeat near-identical blocks.
  - 🟢 / tests / trivial → **no Before/After code.** Name them in a line and move on.
- **For each 🔴, add one line: `⚠ Worth your brain:`** — the single judgment call the reviewer must make (e.g. "is making this cookie JS-readable safe?").
- **Close with two things:**
  1. **Where the raw diff misleads you** — one line on the visual-weight trap (mechanical churn usually dwarfs the one risky line, so GitHub makes them look equally important).
  2. **An offer to zoom** into any logical change with its full Before/After.

## Shape of a good output (schematic)

```
<PR goal in one line>

### ① <title> — N files · 🔴 this is the review
**path/to/file.py**
Before: <minimal, behavioral>
After:  <minimal, behavioral>
Why: <intent, grounded in the code>
⚠ Worth your brain: <the one decision>

### ② <title> — N files · ⚪ mechanical, scan don't read
One representative Before/After, then the file list.
What to actually check: completeness + no leftover refs.

### ③ <title> — N files · 🟢 trivial
Named in a line, no code.

Where the raw diff misleads you: <visual-weight trap, one line>
Want me to zoom into any of these with full Before/After?
```

## What this is NOT

- **Not `/code-review` or `/review-pr`** — those hunt for bugs and regressions. `pr-explain` is comprehension + triage: it points at *where* bugs would hide and which changes deserve scrutiny; it does not enumerate findings. They pair well — triage first to see the shape and the risky spots, then run the deep bug-finder on those.
- **Not `/explain`** — that's a 1-2 paragraph plain-prose zoom-out. `pr-explain` is the structured triage of a whole diff with Before/After code.
