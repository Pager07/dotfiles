#!/usr/bin/env bash
# Installs the Claude Code config from this dotfiles repo into ~/.claude.
# Idempotent: safe to re-run. Existing non-symlink files are backed up to *.bak-<timestamp>.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../dotfiles/claude
CLAUDE_DIR="${HOME}/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {  # link <source-in-repo> <target-in-~/.claude>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  backing up existing $dst -> ${dst}.bak-${STAMP}"
    mv "$dst" "${dst}.bak-${STAMP}"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst -> $src"
}

echo "==> Installing Claude config from $REPO_DIR"
mkdir -p "$CLAUDE_DIR/skills"

echo "-- settings"
link "$REPO_DIR/settings.json"       "$CLAUDE_DIR/settings.json"
link "$REPO_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json"

echo "-- skills (symlinked individually so other local skills are left alone)"
for d in "$REPO_DIR"/skills/*/; do
  name="$(basename "$d")"
  link "${d%/}" "$CLAUDE_DIR/skills/$name"
done

echo "-- agents"
mkdir -p "$CLAUDE_DIR/agents"
for f in "$REPO_DIR"/agents/*; do
  name="$(basename "$f")"
  link "$f" "$CLAUDE_DIR/agents/$name"
done

cat <<'EOF'

==> Symlinks done. Remaining manual steps:

  1. Log in (no credentials are stored in this repo):
       claude    # then complete the login flow

  2. Re-add MCP servers with your real tokens:
       see claude/mcp-servers.md  (tokens come from your Slack-to-self message)

  3. Install tools the config depends on:
       brew install jq node uv     # jq=statusline, node=npx MCPs, uv=logfire MCPs

  4. settings.local.json holds Linux-only permission allow-rules (pactl/amixer/apt/xrandr).
     Harmless on macOS, but you can trim them in ~/.claude/settings.local.json.

Done.
EOF
