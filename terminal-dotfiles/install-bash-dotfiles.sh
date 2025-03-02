#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MOTHERSCRIPT="$DOTFILES_DIR/motherscript.sh"

TARGET_DIR="$HOME/.bash"
BASHRC_TARGET="$HOME/.bashrc"

# Load helper functions
if [[ -f "$MOTHERSCRIPT" ]]; then
  # shellcheck source=../motherscript.sh
  source "$MOTHERSCRIPT"
  parse_flags "$@"
else
  echo -e "  motherscript.sh not found in $MOTHERSCRIPT"
  exit 1
fi

# OS-type flag or selection.
OS_TYPE="${FLAGS_OS:-}"
if [[ -z "$OS_TYPE" ]]; then
  echo -e "\n󱐁  Choose which OS-specific Bash config to install:\n"
  select opt in "Ubuntu" "Fedora" "Quit"; do
    case $opt in
      "Ubuntu") OS_TYPE="ubuntu"; break ;;
      "Fedora") OS_TYPE="fedora"; break ;;
      "Quit") echo "  Aborted by user."; exit 0 ;;
      *) echo " Invalid option. Please choose 1, 2 or 3." ;;
    esac
  done
fi

BASH_SHARED_DIR="$SCRIPT_DIR/bash/shared"
BASH_OS_DIR="$SCRIPT_DIR/bash/$OS_TYPE"

log_section "Installing Bash config for: $OS_TYPE"
safe_ensure_dir "$TARGET_DIR"

# ===> Function to link bash files, shared or os-specific files.
link_bash_files() {
  local source_dir="$1"

  for file in "$source_dir"/*; do
    [[ ! -f "$file" ]] && continue
    local filename
    filename=$(basename "$file")

    # handle bashrc
    if [[ "$filename" == "bashrc" ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        log_info "Would link: $BASHRC_TARGET → $file"
      else
        [[ -L "$BASHRC_TARGET" || -f "$BASHRC_TARGET" ]] && {
          log_info_overwrite "$BASHRC_TARGET" "$file"
          rm -f "$BASHRC_TARGET"
        }
        ln -s "$file" "$BASHRC_TARGET"
        log_info_linked "$BASHRC_TARGET" "$file"
      fi
    else
      local target="$TARGET_DIR/$filename"
      if [[ "$DRY_RUN" == true ]]; then
        log_info "Would link: $target → $file"
      else
        [[ -L "$target" || -f "$target" ]] && {
          log_info_overwrite "$target" "$file"
          rm -f "$target"
        }
        ln -s "$file" "$target"
        log_info_linked "$target" "$file"
      fi
    fi
  done
}

# Link files
link_bash_files "$BASH_SHARED_DIR"
link_bash_files "$BASH_OS_DIR"

log_success "All Bash config files linked for $OS_TYPE!"

