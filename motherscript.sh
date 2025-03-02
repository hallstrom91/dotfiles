#!/usr/bin/env bash

# -e === exit if any command returns error
# -u === exit if any undefined variabelname is used
# -o pipefail === exit if any part of pipe fails
set -euo pipefail

# ----------------------------------
# Colors & Symbols
# ----------------------------------

RESET="\e[0m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
GRAY="\e[90m"

# ----------------------------------
# Defaults
# ----------------------------------

LOG_LEVEL="${LOG_LEVEL:-info}"
DRY_RUN=false
FORCE_YES=false

# ----------------------------------
# Flag parsing
# ----------------------------------
# Run with flags
# ./script.sh --yes --debug
# ./script.sh --dry-run
# ./script.sh --quiet

parse_flags() {
  for arg in "$@"; do
    case "$arg" in
    --debug)
      LOG_LEVEL="debug"
      ;;
    --quiet)
      LOG_LEVEL="warn"
      ;;
    --yes | -y)
      FORCE_YES=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    *) ;;
    esac
  done
}

# ----------------------------------
# Logging
# ----------------------------------

log_info() {
  [[ "$LOG_LEVEL" =~ ^(info|debug)$ ]] &&
    echo -e "${GREEN} Info:${RESET} $*"
}

log_warn() {
  [[ "$LOG_LEVEL" =~ ^(warn|info|debug)$ ]] &&
    echo -e "${YELLOW} Warning:${RESET} $*" >&2
}

log_error() {
  echo -e "${RED} Error:${RESET} $*" >&2
}

log_debug() {
  [[ "$LOG_LEVEL" == debug ]] &&
    echo -e "${GRAY} Debug:${RESET} $*"
}

log_success() {
  echo -e "${GREEN}󰸞 Success:${RESET} $*"
}

log_section() {
  echo -e "${CYAN} $*${RESET}"
}

log_info_overwrite() {
  echo -e "${GREEN} Overwriting:${RESET} $1 → $2"
}

log_info_linked() {
  echo -e "${GREEN}󰸞 Linked:${RESET} $1 → $2"
}

# ----------------------------------
# Prompt
# ----------------------------------
prompt_confirm() {
  local PROMPT="$1"

  if [[ "$FORCE_YES" == true ]]; then
    return 0
  fi

  read -rp "$PROMPT [y/N]: " response
  case "$response" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

# ----------------------------------
# Forbidden paths (safety net!)
# ----------------------------------

FORBIDDEN_PATHS=(
  "$HOME"
  "$HOME/"
  "$HOME/.config"
  "$HOME/.local"
  "$HOME/Documents"
  "$HOME/Desktop"
  "/"
  "/etc"
  "/usr"
  "/bin"
  "/opt"
)

is_forbidden_path() {
  local CHECK_PATH
  CHECK_PATH="$(realpath "$1")"
  for FORBIDDEN in "${FORBIDDEN_PATHS[@]}"; do
    if [[ "$CHECK_PATH" == "$(realpath "$FORBIDDEN")" ]]; then
      return 0 # Forbidden
    fi
  done
  return 1 # Allowed
}

# ----------------------------------
# Ensure directory exists
# ----------------------------------

safe_ensure_dir() {
  local DIR="$1"
  if [[ -d "$DIR" ]]; then
    return 0
  fi
  if prompt_confirm "Directory '$DIR' does not exist. Create it?"; then
    if [[ "$DRY_RUN" == true ]]; then
      log_info "Would create directory: $DIR"
    else
      mkdir -p "$DIR"
      log_info "Created directory: $DIR"
    fi
  else
    log_warn "Skipped creating directory: $DIR"
    return 1
  fi
}

# ----------------------------------
# Safe remove directory
# ----------------------------------

safe_remove_dir() {
  local DIR="$1"
  if is_forbidden_path "$DIR"; then
    log_error "Refusing to remove forbidden directory: $DIR"
    return 1
  fi
  if prompt_confirm "Do you really want to REMOVE directory '$DIR'?"; then
    if [[ "$DRY_RUN" == true ]]; then
      log_info "Would remove: $DIR"
    else
      rm -rf "$DIR"
      log_warn "Directory removed: $DIR"
    fi
  else
    log_info "Aborted removal of directory: $DIR"
    return 1
  fi
}

# ----------------------------------
# Safe symlink creation
# ----------------------------------

safe_link_file() {
  local SRC="$1"
  local DEST="$2"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would link: $DEST → $SRC"
    return 0
  fi

  # Remove broken symlink
  if [[ -L "$DEST" && ! -e "$DEST" ]]; then
    log_warn "Removing broken symlink: $DEST"
    rm "$DEST"
  fi

  # If destination exists
  if [[ -L "$DEST" || -e "$DEST" ]]; then
    if [[ -d "$DEST" && ! -L "$DEST" ]]; then
      log_warn "Destination '$DEST' is an existing directory."
      if ! safe_remove_dir "$DEST"; then
        log_error "Cannot continue without removing directory: $DEST"
        return 1
      fi
    else
      log_info_overwrite "$DEST" "$SRC"
      rm -f "$DEST"
    fi
  fi

  ln -s "$SRC" "$DEST"
  log_info_linked "$DEST" "$SRC"
}
