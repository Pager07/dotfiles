---
name: login-as
description: Log in as any TutorCruncher role (client, tutor/contractor, admin, agent, SR) on a local or anon-DB dev environment by overwriting that role's user email + password, then printing working credentials and the agency login URL. Use when the user says things like "log in as client 2804932", "login as SR on 6653", "impersonate tutor 123", or needs usable credentials for a role on the local/anon database.
---

# login-as

Overwrites a TutorCruncher role's user with known credentials so you can log in through
the normal form. On an anon DB the real emails are scrambled, so this is the only way in;
on a normal dev DB it's just convenient. The branch/agency is derived from the role, so
the user only supplies the role type and id.

## Preconditions
- Current working directory is the TutorCruncher repo root (where `manage.py` lives).
- The DB you want is the one Django is currently configured to use (local seed or the
  loaded anon dump). The script refuses to run if it detects production (`DYNO` env var).

## Which database — IMPORTANT

TutorCruncher's local settings pick the DB from an env var. If you don't set it, it
**silently uses the small local dev DB** — so a production-scale id (7+ digits, e.g. from
the anon dump) will look "not found". Always choose the DB explicitly:

| Target DB           | Prefix  | Postgres DB           |
|---------------------|---------|-----------------------|
| Anon dump           | `AN=1`  | `tutorcruncher2_anon` |
| UI 2.0 DB           | `UI=1`  | `tutorcruncher2_ui`   |
| Local dev (default) | (none)  | `tutorcruncher2`      |

If the user says "anon" / "anon db", prefix the command with `AN=1`. The script prints the
connected `database:` line so you can confirm you hit the right one — check it matches.

## How to run

Map the user's words to a role keyword, pick the DB prefix, then run the bundled script
through Django's shell, passing `ROLE` and `ROLE_ID` as env vars:

```bash
# Anon DB → AN=1   |   UI DB → UI=1   |   local dev → omit the DB prefix
AN=1 ROLE=<client|tutor|admin|agent|sr|student> ROLE_ID=<id> \
  uv run ./manage.py shell < "$HOME/.claude/skills/login-as/scripts/login_as.py"
```

Role keyword mapping (accepted aliases in parentheses):

| User says            | ROLE value   | Model            |
|----------------------|--------------|------------------|
| client               | `client`     | Client           |
| tutor / contractor   | `tutor`      | Contractor       |
| admin / administrator| `admin`      | Administrator    |
| agent                | `agent`      | Agent            |
| SR / service recipient / recipient / **student** / pupil | `sr` | ServiceRecipient |

(In TutorCruncher a "student" / "pupil" is a ServiceRecipient.)

Examples:
- "log in as client 2804932 on anon db" → `AN=1 ROLE=client ROLE_ID=2804932 ...`
- "login as SR on 6653"                  → `AN=1 ROLE=sr ROLE_ID=6653 ...`
- "impersonate tutor 123 on local"       → `ROLE=tutor ROLE_ID=123 ...`

Optional env vars:
- `LOGIN_PASSWORD` — override the default password (`testing`).
- `LOCAL_BASE_URL` — override the base for the printed login URL (default `http://localhost:8000`).

After running, relay the printed credentials and login URL to the user.

## Optional: drive the browser and log in for them

If the user wants to end up already logged in (not just handed a URL), after the script
prints the credentials use the Chrome tools (load them via ToolSearch
`select:mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__form_input` etc.) to:
1. navigate to the printed `login url`,
2. fill the email and password fields,
3. submit.
Only do this when the user asks for it.

## Notes & troubleshooting
- The script sets the email + password and does a full `user.save()` (mirrors the manual
  shell flow). It does not touch MFA or `is_active` (the latter is a read-only property).
- "No <Role> with id=… on this database" → wrong role type or the dump doesn't contain
  that id; double-check the id and role keyword.
- Email collision (IntegrityError on save) is rare; it means another user already has
  `<id>@tutorcruncher.com`. Pick a different role id or clear that email manually.
