#!/bin/bash

# paths
CONFIG_DIR=~/Documents/dotfiles
WEZTERM_CONFIG=~/.config/wezterm/wezterm.lua
KITTY_CONFIG=~/.config/kitty/kitty.conf
KITTY_THEMES=~/.config/kitty/themes
NVIM_CONFIG=~/.config/nvim

HOSTNAME=$(hostname)
REMOVE=false

# remove files and symbolic links - optional
if [[ "$1" == "--rm" ]]; then
  REMOVE=true
fi

echo "Setting up dotfiles for $HOSTNAME"

if [ "$REMOVE" = true ]; then
  echo "Removing existing symbolic links and dirs"
  rm -f "$WEZTERM_CONFIG"
  rm -f "$KITTY_CONFIG"
  rm -rf "$KITTY_THEMES"
  rm -rf "$NVIM_CONFIG"
fi

# Create symbolic link based on workstation hostname
if [[ "$HOSTNAME" == "pop-os" ]]; then
  [ ! -L "$WEZTERM_CONFIG" ] && ln -s "$CONFIG_DIR/wezterm/configs/desktop.lua" "$WEZTERM_CONFIG"
  [ ! -L "$KITTY_CONFIG" ] && ln -s "$CONFIG_DIR/kitty/configs/desktop.conf" "$KITTY_CONFIG"
elif [[ "$HOSTNAME" == "laptop" ]]; then
  [ ! -L "$WEZTERM_CONFIG" ] && ln -s "$CONFIG_DIR/wezterm/configs/laptop.lua" "$WEZTERM_CONFIG"
  [ ! -L "$KITTY_CONFIG" ] && ln -s "$CONFIG_DIR/kitty/configs/laptop.conf" "$KITTY_CONFIG"
else
  echo "No specific config for this machine, using defaults"
fi

echo "Symbolic links for wezterm & kitty dotfiles created."

# Create symbolic links for shared configurations
[ ! -L "$KITTY_THEMES" ] && ln -s "$CONFIG_DIR/kitty/themes" "$KITTY_THEMES"
echo "Symbolic link for Kitty themes created."
[ ! -L "$NVIM_CONFIG" ] && ln -s "$CONFIG_DIR/nvim" "$NVIM_CONFIG"
echo "Symbolic link for Neovim config created."

# completed
echo "Setup completed successfully. GLHF"
