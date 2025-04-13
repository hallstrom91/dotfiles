# dotfiles

## Description

Personal dotfiles repository.

## Table of Contents

- [Description](#description)
- [Motherscript](#motherscript)
- [Installation](#installation)
- [Usage](#usage)
- [Behavior](#behavior)

## Motherscript

`motherscript.sh` is the core logic layer for all setup scripts in this repo. It provides:

- Safe symlinking (`safe_link_file`)
- Directory creation with confirmation (`safe_ensure_dir`)
- Safe deletion with confirmation (`safe_remove_dir`)
- Smart logging with icons and color (`log_info`, `log_warn`, `log_success`, etc.)
- Support for flags like:

### Available Flags

| Flag        | Description                                    |
| ----------- | ---------------------------------------------- |
| `--dry-run` | Simulate actions without actually doing them   |
| `--debug`   | Show extra debug output                        |
| `--yes`     | Auto-confirm prompts (useful in scripts or CI) |

You can pass these flags to any install script that uses `motherscript.sh`:

```bash
./install-terminal-dotfiles.sh --dry-run
./install-shared-dotfiles.sh --yes --debug
```

## Installation

1. **Make the script executable** (only needed once):

```bash
chmod +x ./install-*.sh
```

_You can optionally make motherscript.sh executable, but it's not required since it’s sourced._

2. **Run an install script:**

```bash
./install-shared-dotfiles.sh
```

## Usage

This repository is built for personal workflows, where symbolic links maintain consistency across environments.

**Some benefits:**

- Easily sync dotfiles between machines

- Avoid duplicate configs

- Quickly bootstrap a new machine

  ⚠️ Always verify scripts and back up any important config files before running.

## Behavior

Here’s how the symlink logic handles different scenarios:

    ✅ Existing symlink (correct target): Nothing is done.

    🔁 Existing symlink (wrong target): It will be replaced.

    🧹 Broken symlink: It will be removed and replaced.

    🚫 Real file or folder exists: You'll be prompted to delete it (unless using --yes).

    🛑 Dangerous paths (like /, $HOME, /etc) are protected and cannot be removed.

    🪄 Non-existent folders will be created with confirmation.

```bash
  Overwriting: ~/.bashrc
✔️ Linked: ~/.bashrc → ~/dotfiles/bash/bashrc
```

## Future Improvements

- Add --force flag to skip all prompts but still warn
- Compatibility checks for different shells (zsh, fish)
