#!/usr/bin/env bash
set -euo pipefail

MOTHERSCRIPT="$(dirname "${BASH_SOURCE[0]}")/../motherscript.sh"

# Load helper functions
if [[ -f "$MOTHERSCRIPT" ]]; then
  # shellcheck source=../motherscript.sh
  source "$MOTHERSCRIPT"
  parse_flags "$@"
else
  echo -e "  motherscript.sh not found in $MOTHERSCRIPT"
  exit 1
fi

log_section "Installing terminal configs..."

HOSTNAME=$(hostname)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source paths
KITTY_SRC="$SCRIPT_DIR/kitty/configs"
KITTY_THEMES_SRC="$SCRIPT_DIR/kitty/themes"
WEZTERM_SRC="$SCRIPT_DIR/wezterm/configs"
STARSHIP_FILE="$SCRIPT_DIR/starship/starship.toml"

# Target paths
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTY_THEME_DIR="$KITTY_CONFIG_DIR/themes"
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
STARSHIP_TARGET="$HOME/.config/starship.toml"

# Detect machine
if [[ "$HOSTNAME" == "laptop" ]]; then
  KITTY_CONF="$KITTY_SRC/laptop.conf"
  WEZTERM_CONF="$WEZTERM_SRC/laptop.lua"
  log_info "Detected laptop configuration"
elif [[ "$HOSTNAME" == "pop-os" ]]; then
  KITTY_CONF="$KITTY_SRC/desktop.conf"
  WEZTERM_CONF="$WEZTERM_SRC/desktop.lua"
  log_info "Detected desktop configuration"
else
  log_error "Unknown host: $HOSTNAME"
  exit 1
fi

# Create target directories
safe_ensure_dir "$KITTY_CONFIG_DIR"
safe_ensure_dir "$KITTY_THEME_DIR"
safe_ensure_dir "$WEZTERM_CONFIG_DIR"

# Link Kitty config
log_section "Linking Kitty config"
safe_link_file "$KITTY_CONF" "$KITTY_CONFIG_DIR/kitty.conf"

# Link Kitty themes
log_section "Linking Kitty themes"
for theme in "$KITTY_THEMES_SRC"/*.conf; do
  DEST="$KITTY_THEME_DIR/$(basename "$theme")"
  safe_link_file "$theme" "$DEST"
done



link_wezterm_shared_modules() {
  local source_dir="$1"
  local target_dir="$2"
  local exclude="$3"

  for file in "$source_dir"/*.lua; do
    [[ ! -f "$file" ]] && continue
    local basename
    basename=$(basename "$file")

    # hoppa över main wezterm-config
    if [[ "$basename" == "$exclude" ]]; then
      continue
    fi

    local target="$target_dir/$basename"
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
  done
}


# Link WezTerm config & shared WezTerm modules
log_section "Linking WezTerm main config & modules"
safe_link_file "$WEZTERM_CONF" "$WEZTERM_CONFIG_DIR/wezterm.lua"
link_wezterm_shared_modules "$SCRIPT_DIR/wezterm" "$WEZTERM_CONFIG_DIR" "$(basename "$WEZTERM_CONF")"

# Link Starship config
log_section "Linking Starship config"
safe_link_file "$STARSHIP_FILE" "$STARSHIP_TARGET"

log_success "Terminal configs installed successfully!"
