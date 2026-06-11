# TutorCruncher shell setup — instructions for the Mac agent

This folder carries the user's TutorCruncher shell environment: aliases (`rdcd`, `cdtc2`,
`fixredis`, …), git config, and the `git ppr` command. **No secrets are in here** — API
tokens live in `~/.secrets` (see step 5).

## What's in this folder
| File | Goes to | Purpose |
|---|---|---|
| `aliases.zsh` | `~/.zshrc_aliases_tc_imported_by_zshrc` | all the aliases/functions (`rdcd`, `cdtc2`, `rs`, `rw`, `mig`, `fixredis`, …) |
| `zshrc` | `~/.zshrc` | full shell config (sources the aliases + `~/.secrets`) |
| `gitconfig` | `~/.gitconfig` | git aliases incl. **`ppr`**, `pushp`, `log2`, etc. |
| `pull_pull_request.py` | `~/repos/pull_pull_request.py` | the script `git ppr` runs |
| `branch_checkout.py` | `~/repos/branch_checkout.py` | the script `gb` runs (lists branches, pick one to checkout); run via `uv run --script` |
| `env.template` | copy → `~/.secrets` | template for the secret env vars |

## Setup steps (agent: run these; back up anything you overwrite)

```bash
DF=~/dotfiles/tutorcruncher

# 1. Aliases — the zshrc sources this exact path, so symlink it there
ln -sfn "$DF/aliases.zsh" ~/.zshrc_aliases_tc_imported_by_zshrc

# 2. Shell config (back up any existing ~/.zshrc first)
[ -e ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak-$(date +%s)
ln -sfn "$DF/zshrc" ~/.zshrc

# 3. Git config (back up existing first)
[ -e ~/.gitconfig ] && [ ! -L ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.bak-$(date +%s)
ln -sfn "$DF/gitconfig" ~/.gitconfig
touch ~/.gitignore_global   # gitconfig references it; empty is fine

# 4. The git ppr script — the `ppr` alias expects it at ~/repos/
mkdir -p ~/repos
ln -sfn "$DF/pull_pull_request.py" ~/repos/pull_pull_request.py

# 4b. The gb script — the `gb` alias expects it at ~/repos/ (run via uv, no global deps)
ln -sfn "$DF/branch_checkout.py" ~/repos/branch_checkout.py
```

```bash
# 5. Secrets — create ~/.secrets from the template, then fill in real values.
cp "$DF/env.template" ~/.secrets
chmod 600 ~/.secrets
#   Now edit ~/.secrets and paste the real GITHUB_USERNAME_TOKEN and OPENAI_API_KEY
#   from the user's Slack-to-self "keys" message. ASK the user for them — do not guess.
```

## Dependencies to install (Homebrew)
```bash
# Shell framework + plugins the zshrc expects
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
#   (also clone zsh-vi-mode into $ZSH_CUSTOM/plugins if not present)

# For git ppr (Python + requests) and the dev DBs
brew install python uv node jq redis postgresql
python3 -m pip install requests
```

## Verify
```bash
exec zsh                 # reload shell
which rdcd cdtc2 fixredis # should resolve to the aliases
git ppr                  # should print: usage: git ppr <pull request id> <[pull]/push>
git ppr 16195            # real test inside a TC repo (needs GITHUB_USERNAME_TOKEN set)
```

## Notes / caveats
- **`gb` is migrated** (`branch_checkout.py`, symlinked in step 4b). It runs via
  `uv run --script`, which reads the inline PEP 723 metadata and auto-installs `devtools`
  — so no global pip install is needed, just `uv`. It also needs the `git branchmin` alias
  (already in `gitconfig`).
- **Other aliases still need scripts not yet migrated.** `pt`, `lint`/`litn`, and
  `clean-local-branches` point at `~/repos/run_test.py`, `run_linter.py`,
  `clean_branches.sh` — those aren't in this folder yet. They'll error until copied over.
  (Tell the user if they want these too.)
- `fixredis` / `fixsql` / `uuu` auto-switch to Homebrew on macOS; `cdi3` / `calendar`
  (i3/GNOME) are Linux-only and skipped on macOS.
- The `pycharm` and `guisettings` aliases in `zshrc` are Linux-specific — harmless, can be removed.
- Aliases assume repos live under `~/repos/` (e.g. `cdtc2` → `~/repos/TutorCruncher2`).
  Clone TC2 there, or adjust the alias.
