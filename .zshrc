# Local binaries (e.g. claude) on PATH
export PATH="$HOME/.local/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git zsh-vi-mode history-substring-search zsh-autosuggestions copypath dirhistory zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Git shortcuts
alias gl="git log2"
alias gs="git status"
alias gp="git pull"

# Script shortcuts
alias gb="python3 ~/repos/branch_checkout.py"
alias pt="python3 ~/repos/run_test.py"
alias lint="python3 ~/repos/run_linter.py"
alias clean-local-branches="~/repos/clean_branches.sh"
