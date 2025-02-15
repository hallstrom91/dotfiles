#!/bin/bash

set -e

DOTFILES_DIR=~/Documents/dotfiles
BASH_DIR="$DOTFILES_DIR/bash"
SHELL_DIR="$DOTFILES_DIR/shell"
CUSTOM_SCRIPTS="$SHELL_DIR/custom-scripts"
HOSTNAME=$(hostname)

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

if [[ "$HOSTNAME" == "pop-os" ]]; then
  echo "Detected Desktop (pop-os) - Using default scripts"
  ln -sf "$CUSTOM_SCRIPTS/mountwsx.sh" "$HOME_BIN/mountwsx.sh"
  ln -sf "$CUSTOM_SCRIPTS/mountwsx_and_navigate.sh" "$HOME_BIN/mountwsx_and_navigate.sh"
  ln -sf "$CUSTOM_SCRIPTS/dismountwsx.sh" "$HOME_BIN/dismountwsx.sh"
elif [[ "$HOSTNAME" == "laptop" ]]; then
  echo "Detected Laptop (laptop): Using modified scripts"
  ln -sf "$CUSTOM_SCRIPTS/laptop/mountwsx_laptop.sh" "$HOME_BIN/mountwsx.sh"
  ln -sf "$CUSTOM_SCRIPTS/laptop/mountwsx_and_nav_laptop.sh" "$HOME_BIN/mountwsx_and_navigate.sh"
  ln -sf "$CUSTOM_SCRIPTS/laptop/dismountwsx_laptop.sh" "$HOME_BIN/dismountwsx.sh"
else
  echo "Unkown host ($HOSTNAME), self destruct..."
fi

ln -sf "$CUSTOM_SCRIPTS/untar.sh" "$HOME_BIN/untar.sh"

chmod +x "$HOME_BIN"/*.sh

# echo "Moving custom scripts to ~/.bin/ and making them executable..."
# for script in "$CUSTOM_SCRIPTS"/*.sh; do
#   ln -sf "$script" "$HOME_BIN/$(basename "$script")"
#   chmod +x "$HOME_BIN/$(basename "$script")"
# done

echo "Shell and bash configurations successfully set up!"
