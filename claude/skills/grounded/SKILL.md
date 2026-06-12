---
name: grounded
description: >-
  Use PROACTIVELY (without being asked) whenever you present code-review findings,
  OR explain a concept, file, PR, function, bug, or error to this user. The user
  understands through concrete anchors, not abstract prose — abstraction only lands
  AFTER a concrete example, never before it. Two modes: "review" (paste-ready
  findings for GitHub) and "explain" (teaching a concept). Reviewing is the user's
  bottleneck; abstract findings waste their time because they have to do the
  grounding themselves. This skill does the grounding for them.
---

# Grounded — concrete-first communication

## The principle (why this exists)

**Abstraction is the reward, not the entry fee.** A reader understands a thing only
once it's anchored to something concrete they already hold — a real example, *their
own* code, a fact they already know. The abstract one-line takeaway lands only
*after* the anchor, as a compression of it. Leading with abstraction forces the
reader to manufacture the concrete case themselves just to check whether the point
is even real — and that wasted grounding step is exactly the bottleneck this skill
removes.

Corollary: a good explanation does the grounding work *for* the reader. If your
output makes them turn abstract prose into a concrete case to verify it, you've
handed the hardest step back to them.

## Shared rules (both modes)

1. **Anchor first.** Open with a concrete instance — a real row of data, real line
   numbers, a real call site, a known analogy. Pull it from the user's *actual*
   codebase whenever possible, not a toy.
2. **Name the wrong mental model explicitly.** "You might think X — here's why it's
   actually Y." Surfacing the misconception is often what makes it click.
3. **Abstraction comes last, compressed to one portable line.** One sentence the
   reader can carry away. Never open with it.
4. **Plain language.** No jargon in the summary line. Define terms via the example,
   not before it.
5. **End on a crisp hook**, not a fade-out — a one-line model, a pointed question,
   or a clear next step.
6. **Verify before asserting.** If a claim depends on a route, schema, flag, or
   behavior, check it in the code first. (See this session: a "broken link" finding
   was wrong because the frontend route actually existed.)

## Mode: review

Use this format for every code-review finding. Order matters.

1. **📍 Paste location (FIRST, always)** — `file path` + line or line-range where the
   GitHub comment goes (e.g. `app/auth/api/signup.py` lines 108–120). Lead with this.
2. **Summary (plain):** 1–2 short sentences, no jargon.
3. **Concrete example:** a small story with the *relevant code snippet* and real line
   numbers. Use realistic concrete values (e.g. `(id=500, jane@example.com, TUTOR)`).
   This is the part that makes the finding click — never skip it.
4. **Quick summary:** one terse line naming the defect.
5. **Comment to paste:** SHORT, phrased as a friendly question to the PR author
   ("This is what happens — is this intended?"). Not a long explanation. The depth
   lives in the example above; the paste comment is just the question.

Keep correctness findings ahead of cleanup. When you retract a finding, say so
plainly and explain what changed your mind.

### Review example (shape only)

> **📍 Paste location:** `app/auth/api/signup.py` — lines 108–120
>
> **Summary:** Signup reuses any existing user matching the email; emails aren't
> unique here, so a tutor/client can get promoted to admin of the new org.
>
> **Concrete example:** existing row `(id=500, jane@example.com, TUTOR)` + a signup
> with that email → `admin_user = existing_user` (line 109), then
> `get_or_create(Admin, id=500)` makes the tutor an admin. *(show the lines)*
>
> **Quick summary:** type-blind reuse → wrong-role promotion.
>
> **Comment to paste:** "Since emails aren't unique here, `existing_user` could be a
> tutor/client and the `Admin` create below would promote them. Intended, or should
> this only reuse existing admins?"

## Mode: explain

Use when teaching a concept, file, PR, function, bug, or error.

1. **Anchor:** a concrete example from the user's own code, or a known analogy
   (math, a familiar system). Start here.
2. **Name the misconception:** state the plausible-but-wrong model and correct it
   against the anchor.
3. **The abstraction, last:** one compressed, portable line — and name it if it has
   a name (e.g. "this is partial application").
4. **Hook:** a one-line mental model or a "want me to…" next step.

### Explain example (shape only)

Teaching why `rate_limit_by_ip` is a factory: anchor on `f(x) = m·x + c` (fix the
params → get a clean arrow that composes), correct the "different signatures"
misconception (same signature, baked-in config), then the one-liner: "freeze what
you know now, leave a slot for what arrives later." Ground it in the user's two real
call sites — the route dependency vs. the direct call in the handler body.

## When NOT to use

- Trivial one-word answers or yes/no confirmations.
- When the user explicitly asks for terse / no-example output (e.g.
  `/explain-in-two-sentence`). Respect that over this skill.
