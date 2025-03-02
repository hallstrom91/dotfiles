#!/usr/bin/env bash
set -euo pipefail

# Resolve project root and motherscript path
HOSTNAME=$(hostname)
HOME_BIN="$HOME/.bin"
TEMPLATES_DIR="$HOME/Templates"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MOTHERSCRIPT="$DOTFILES_DIR/motherscript.sh"

# Load helper functions
if [[ -f "$MOTHERSCRIPT" ]]; then
  # shellcheck source=../motherscript.sh
  source "$MOTHERSCRIPT"
  parse_flags "$@"
else
  echo -e "  motherscript.sh not found in $MOTHERSCRIPT"
  exit 1
fi

log_section "Installing shared dotfiles..."


# Ensure essential directories
safe_ensure_dir "$HOME_BIN"
safe_ensure_dir "$HOME/.config"
safe_ensure_dir "$HOME/.config/autostart"
safe_ensure_dir "$TEMPLATES_DIR"
safe_ensure_dir "$HOME/.gnupg"

# Link shared dotfiles
log_section "Linking shared dotfiles"
safe_link_file "$SCRIPT_DIR/formatter/editorconfig" "$HOME/.editorconfig"
safe_link_file "$SCRIPT_DIR/formatter/editorconfig" "/media/veracrypt1/.editorconfig"
safe_link_file "$SCRIPT_DIR/formatter/editorconfig" "/media/veracrypt2/.editorconfig"
safe_link_file "$SCRIPT_DIR/git/gitignore_global" "$HOME/.gitignore_global"
safe_link_file "$SCRIPT_DIR/git/commit_template" "$TEMPLATES_DIR/.commit_template"
safe_link_file "$SCRIPT_DIR/gpg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
safe_link_file "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"

# Link device-specific shell scripts
log_section "Linking machine-specific scripts based on hostname"
if [[ "$HOSTNAME" == "pop-os" ]]; then
  log_info "Detected desktop (pop-os), using desktop versions"
  safe_link_file "$SCRIPT_DIR/shell-scripts/desktop/mountwsx.sh" "$HOME_BIN/mountwsx.sh"
  safe_link_file "$SCRIPT_DIR/shell-scripts/desktop/mountwsx_and_navigate.sh" "$HOME_BIN/mountwsx_and_navigate.sh"
  safe_link_file "$SCRIPT_DIR/shell-scripts/desktop/dismountwsx.sh" "$HOME_BIN/dismountwsx.sh"
elif [[ "$HOSTNAME" == "laptop" ]]; then
  log_info "Detected laptop, using laptop versions"
  safe_link_file "$SCRIPT_DIR/shell-scripts/laptop/mountwsx_laptop.sh" "$HOME_BIN/mountwsx.sh"
  safe_link_file "$SCRIPT_DIR/shell-scripts/laptop/mountwsx_and_nav_laptop.sh" "$HOME_BIN/mountwsx_and_navigate.sh"
  safe_link_file "$SCRIPT_DIR/shell-scripts/laptop/dismountwsx_laptop.sh" "$HOME_BIN/dismountwsx.sh"
else
  log_warn "Unknown hostname: $HOSTNAME — no machine-specific scripts linked."
fi

# Link shared shell scripts
log_section "Linking shared shell scripts"
for script in "$SCRIPT_DIR"/shell-scripts/shared/*; do
  [[ -f "$script" ]] || continue
  DEST="$HOME_BIN/$(basename "$script")"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would link: $DEST → $script"
    continue
  fi

  safe_link_file "$script" "$DEST"
  chmod +x "$script"
done

# Link xmodmap files (make Caps Lock → F13)
log_section "Linking xmodmap configuration (Caps Lock → F13)"
safe_link_file "$SCRIPT_DIR/xmodmap" "$HOME/.config/xmodmap"
safe_link_file "$SCRIPT_DIR/autostart/xmodmap.desktop" "$HOME/.config/autostart/xmodmap.desktop"

log_success "Shared dotfiles installed successfully!"
