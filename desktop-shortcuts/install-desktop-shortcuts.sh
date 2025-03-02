#!/usr/bin/env bash
set -euo pipefail

# Resolve project root and motherscript path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MOTHERSCRIPT="$DOTFILES_DIR/motherscript.sh"
SHORTCUTS_DIR="$SCRIPT_DIR"
TARGET_DIR="$HOME/.local/share/applications"

# Load helper functions
if [[ -f "$MOTHERSCRIPT" ]]; then
  # shellcheck source=../motherscript.sh
  source "$MOTHERSCRIPT"
  parse_flags "$@"
else
  echo -e "  motherscript.sh not found in $MOTHERSCRIPT"
  exit 1
fi

log_section "Installing desktop shortcuts"
safe_ensure_dir "$TARGET_DIR"

for desktop_file in "$SHORTCUTS_DIR"/*.desktop; do
  filename=$(basename "$desktop_file")
  target_path="$TARGET_DIR/$filename"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would link: $target_path → $desktop_file"
    continue
  fi

  # Remove existing shortcut
  if [[ -e "$target_path" || -L "$target_path" ]]; then
    log_info_overwrite "$target_path" "$desktop_file"
    rm -f "$target_path"
  fi

  ln -s "$desktop_file" "$target_path"
  log_info_linked "$target_path" "$desktop_file"
done

log_success "All desktop shortcuts installed!"
