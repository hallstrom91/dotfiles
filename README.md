# dotfiles

## Description

Personal dotfiles repository. The setup script creates symbolic links for all configurations based on the hostname of the current workstation.

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)

## Installation

1. **Make the script executable** (only needed once):

```bash
chmod +x ./setup-configs.sh
```

2. **Run the script – This will create symbolic links without removing existing files:**

```bash
./setup-configs.sh
```

3. `(Optional)` **Run the script with the --rm flag – This will remove existing symbolic links and directories in the destination before creating new ones:**

```bash
./setup.configs.sh --rm
```

## Usage

This repository is designed for personal use.
It creates symbolic links for configuration files, making maintenance and switching between machines (desktop/laptop) seamless.

Machine-specific configurations (Wezterm & Kitty) are optimized based on the workstation's performance (desktop/laptop).
Universal configurations (Kitty themes & Neovim) are always linked, as they do not require machine-specific adjustments.

- Always verify Bash scripts before running them.
- If you plan to use this, create backups of your original dotfiles before executing the script.
