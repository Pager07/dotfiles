---
name: fix-migrations
description: Reconcile Django migration state after loading an anon/prod DB dump, then apply the current branch's new migrations. Use when the local app errors with "column ... does not exist" or "relation ... does not exist" after loading a dump, when `showmigrations` shows everything unapplied even though the schema clearly exists, or when the user asks to fix/sync migrations on the anon DB.
---

# fix-migrations

An anon/prod dump ships the real **schema** but a wrong or empty `django_migrations`
table, so Django's record of what's applied disagrees with what's actually in the DB.
`showmigrations` then shows everything unapplied, and the branch's new migration (e.g. a
new column) never gets applied — so queries fail with `column X does not exist`.

This skill automates the fix without the checkout-master-fake-come-back dance:

1. find the migrations that exist on this branch but not on `master` (from git)
2. derive each app's rollback target from the new migration's real `dependencies`
3. `migrate --fake` — record the whole graph as applied (schema assumed present)
4. `migrate --fake <app> <target>` — un-record just the new migrations
5. `migrate <app>` — really apply them, adding the missing columns/tables

## Preconditions
- Current working directory is the TutorCruncher repo root.
- `master` exists locally and is reasonably current (it's the comparison base). Use a
  different base via the `BASE_REF` env var if needed.
- Refuses to run if it detects production (`DYNO` env var).

## Which database — IMPORTANT

TutorCruncher's local settings pick the DB from an env var; if unset it **silently uses
the small local dev DB**. You almost always want the anon dump here, so prefix `AN=1`:

| Target DB           | Prefix  | Postgres DB           |
|---------------------|---------|-----------------------|
| Anon dump (usual)   | `AN=1`  | `tutorcruncher2_anon` |
| UI 2.0 DB           | `UI=1`  | `tutorcruncher2_ui`   |
| Local dev (default) | (none)  | `tutorcruncher2`      |

The script prints the connected `database:` line — confirm it's the one you meant to fix.

## How to run

```bash
# The anon dump is the usual target → prefix AN=1 (omit only for the local dev DB)
AN=1 uv run ./manage.py shell < "$HOME/.claude/skills/fix-migrations/scripts/fix_migrations.py"
```

Optional: `BASE_REF=<branch>` to compare against something other than `master`.

The script prints the new migrations it detected and the rollback target per app before
applying, then runs the migrate steps. Relay that summary to the user.

## Staleness fallback (dump older than master)

The git-vs-master step assumes the dump's schema == master's schema. If the dump lags
master by **extra deploys**, `migrate --fake` will wrongly mark those other migrations as
applied, and you'll hit a fresh `column X does not exist` later. When that happens:

1. Find which migration introduces the missing column:
   ```bash
   grep -rn "X" --include=*.py */**/migrations/  # or: git grep "add.*X" -- '*/migrations/*'
   ```
   (search the model field / `AddField` for that column name).
2. Fake-rollback that app to the migration **before** the one that adds the column, then
   real-apply:
   ```bash
   AN=1 uv run ./manage.py migrate --fake <app> <prev_migration>
   AN=1 uv run ./manage.py migrate <app>
   ```

Repeat per missing column until the app boots. If this happens a lot, the dump is much
older than master and a fresh dump (or a full reset) may be less work.

## Notes
- Safe to run on a normal dev DB: with no branch-new migrations it just `--fake`s to sync
  state and applies nothing.
- This mutates `django_migrations` (and applies new migrations). It does **not** drop or
  reset data.
