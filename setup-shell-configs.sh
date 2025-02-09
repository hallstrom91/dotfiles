#!/bin/bash

set -e

DOTFILES_DIR=~/Documents/dotfiles
BASH_DIR="$DOTFILES_DIR/bash"
SHELL_DIR="$DOTFILES_DIR/shell"
CUSTOM_SCRIPTS="$SHELL_DIR/custom-scripts"

HOME_BIN=~/.bin
GPG_DIR=~/.gnupg

echo "Setting up shell and bash configs..."

mkdir -p "$HOME_BIN"

echo "Creating symbolic links for Bash configurations..."
ln -sf "$BASH_DIR/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$BASH_DIR/.bash_exports" "$HOME/.bash_exports"
ln -sf "$BASH_DIR/.bash_functions" "$HOME/.bash_functions"
ln -sf "$BASH_DIR/.bashrc" "$HOME/.bashrc"

echo "Creating symbolic links for editor and Git configuration files..."
ln -sf "$SHELL_DIR/.editorconfig" "$HOME/.editorconfig"
ln -sf "$SHELL_DIR/.gitignore_global" "$HOME/.gitignore_global"

echo "Copying GPG agent configuration to ~/.gnupg/"
mkdir -p "$GPG_DIR"
cp -v "$SHELL_DIR/gpg-agent.conf" "$GPG_DIR/"

echo "Moving custom scripts to ~/.bin/ and making them executable..."
for script in "$CUSTOM_SCRIPTS"/*.sh; do
  ln -sf "$script" "$HOME_BIN/$(basename "$script")"
  chmod +x "$HOME_BIN/$(basename "$script")"
done

echo "Shell and bash configurations successfully set up!"
