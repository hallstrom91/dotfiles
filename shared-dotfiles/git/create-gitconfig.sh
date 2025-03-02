#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────
# Prompt user for name and email
# ────────────────────────────────────────────────────────────
read -rp "  Enter your full name for Git config: " GIT_NAME
read -rp "  Enter your email for Git config: " GIT_EMAIL

# ────────────────────────────────────────────────────────────
# Set target file path
# ────────────────────────────────────────────────────────────
GITCONFIG_PATH="$HOME/.gitconfig"

# Backup old config if it exists
if [[ -f "$GITCONFIG_PATH" ]]; then
  cp "$GITCONFIG_PATH" "${GITCONFIG_PATH}.bak"
  echo "  Existing .gitconfig backed up to .gitconfig.bak"
fi

# ────────────────────────────────────────────────────────────
# Write new config
# ────────────────────────────────────────────────────────────
cat > "$GITCONFIG_PATH" <<EOF
[init]
    defaultBranch = main
[credential "https://github.com"]
    helper = !/usr/bin/gh auth git-credential
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
[core]
    excludesfile = ~/.gitignore_global
    editor = vim
    autocrlf = input
[credential]
    credentialStore = gpg
    helper = /usr/local/bin/git-credential-manager
[credential "https://dev.azure.com"]
    useHttpPath = true
[commit]
    template = ~/Templates/.commit_template
[pull]
    rebase = true
[alias]
    # basic
    st = status -sb
    co = checkout
    cob = checkout -b
    br = branch
    brd = branch -d
    brD = branch -D
    ci = commit
    cm = commit -m
    ca = commit --amend
    hist = log --oneline --graph --decorate --all
    last = log -1 HEAD

    # push
    pu = !git push -u origin \$(git branch --show-current)
    pff = push --force-with-lease

    # Rebase
    rb = rebase
    rbi = rebase -i
    rbc = rebase --continue
    rba = rebase --abort
    rbs = rebase --skip

    # Diff
    d = diff
    ds = diff --staged

    # Loggar
    lg = log --pretty=format:'%C(yellow)%h%Creset %ad | %Cgreen%s%Creset %C(blue)[%an]%Creset' --date=short
    lol = log --oneline --graph --decorate --all

    # alias
    la = !git config -l | grep alias | cut -c 7-
EOF

echo "󰸞 New .gitconfig created at $GITCONFIG_PATH"
