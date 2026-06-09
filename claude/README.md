# Claude Code config (portable)

My Claude Code setup — skills, subagents, and settings — so it travels between machines.
**No secrets live here.** Auth tokens and MCP API keys are intentionally excluded (see below).

## What's in here
| Path | What it is |
|---|---|
| `settings.json` | Global settings: statusline, vim mode, effort `xhigh`, voice, enabled plugins (codex, warp) |
| `settings.local.json` | Permission allow-list (note: the current rules are **Linux-specific**) |
| `skills/` | 13 custom skills (login-as, fix-migrations, fixworkers, review-pr, sentry-cli, …) |
| `agents/` | Custom subagents (pr-template-writer) |
| `mcp-servers.md` | Commands to re-add MCP servers — **tokens are placeholders** |
| `install.sh` | Idempotent installer — symlinks the above into `~/.claude/` |

## What is deliberately NOT here (and why)
- `~/.claude/.credentials.json` — login/OAuth token → **re-login** instead (`claude`).
- `~/.claude.json` — bloated project history **and** held all the MCP API keys.
  The keys were extracted into `mcp-servers.md` as placeholders; re-add them by hand.
- Runtime state (`projects/`, `sessions/`, `history.jsonl`, caches) — not portable, not wanted.

---

## SETUP (instructions for the Claude agent on a fresh machine)

If the user asks you to set up their Claude Code config from this repo, do this:

1. **Run the installer** (symlinks skills/agents/settings into `~/.claude/`, backing up any
   existing files):
   ```bash
   bash ~/dotfiles/claude/install.sh
   ```

2. **Install dependencies** the config relies on:
   ```bash
   brew install jq node uv
   ```
   (`jq` powers the statusline; `node`/`npx` and `uv`/`uvx` run the MCP servers.)

3. **Re-add the MCP servers.** Read `mcp-servers.md` and run each `claude mcp add` command,
   substituting the real tokens. **Ask the user for the tokens** — they will paste a block
   mapping each `<PLACEHOLDER>` to its real value (sent to themselves via Slack). Do not
   invent or guess tokens. After adding, verify with `claude mcp list`.

4. **Tell the user to log in**: they should run `claude` and complete the login flow
   (credentials are not in this repo by design).

5. **Heads-up to surface to the user:** `settings.local.json`'s permission allow-rules are
   Linux-only (`pactl`, `amixer`, `apt`, `xrandr`, `modprobe`). They're harmless on macOS but
   do nothing — offer to trim them.

That's the whole Claude setup. (Codex migration is handled separately / not yet in this repo.)
