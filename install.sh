#!/usr/bin/env bash
# install.sh - idempotent, fail-safe dotfiles linker script
#
# Features
# - Strict mode (pipefail, nounset, errexit), traps and err messages
# - Safe, repeatable runs: backup pre-existing files, only touch managed paths
# - DRY-RUN preview, per-group install (home/ xdg_config/ xdg_data/ bin/), verbose logs
# - Manifest of created links - for clean uninstall
# - Colorized + emoji(nerdfont icons) logging (toggleable)
# - Minimal dependencies: bash, coreutils, find, ln, mkdir, date, readlink.
#
# Usage
#     ./install.sh [--dry-run] [--force] [--group home,xdg_config,xdg_data,bin]
#                  [--backup-dir ~/.local/share/dotfiles-backups]
#                  [--no-color] [--no-emoji] [--verbose]
#                  [--uninstall] [--only PATH[,PATH...]]
#
#
#
# Expected repo layout
# dotfiles/
# |- bin/           -> link to ~/.local/bin (or ~/.bin)
# |- home/          -> link to $HOME
# |- xdg_config/    -> link subdirs/files into ~/.config/
# |- xdg_data/      -> link into ~/.local/ | special-case mapping to ~/.local/share/


set -Eeuo pipefail
IFS=$'\n\t'

# -------------- Config -------------- #

REPO_ROOT="$(cd -- "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd -P)"
BACKUP_DIR_DEFAULT="$HOME/.local/share/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
MANIFEST_DIR="$HOME/.local/share/dotfiles/dotfiles-installer" # ?
MANIFEST_FILE="$HOME/.local/share/dotfiles/manifest.txt" # ?
TARGET_BIN="$HOME/.local/bin"
TARGET_CONFIG="$HOME/.config"
TARGET_LOCAL="$HOME/.local"
TARGET_SHARE="$HOME/.local/share"

EMOJI=${EMOJI:-1}
COLOR=${COLOR:-1}
VERBOSE=${VERBOSE:-0}
DRY_RUN=${DRY_RUN:-0}
FORCE=${FORCE:-0}
UNINSTALL=${UNINSTALL:-0}
BACKUP_DIR=""
GROUPS=(home xdg_config xdg_data bin)
ONLY_PATHS=()

# Map xdg_data special subpaths -> ~/.local/*/*
# here: xdg_data/applications -> ~/.local/share/applications
map_xdg_data_dest() {
  local rel="$1"
  case "$rel" in
    applications/*|applications) printf '%s\n' "$TARGET_SHARE/${rel#applications/}" ;;
    icons/*|icons)               printf '%s\n' "$TARGET_SHARE/${rel#icons/}" ;;
    fonts/*|fonts)               printf '%s\n' "$TARGET_SHARE/${rel#fonts/}" ;;
    *)                           printf '%s\n' "$TARGET_SHARE/$rel" ;;
  esac
}


# -------------- Logging -------------- #

if [[ "$COLOR" -eq 1 ]]; then
  _R="\033[31m"; _G="\033[32m"; _Y="\033[33m"; _B="\033[34m"; _C="\033[36m"; _N="\033[0m"
else
  _R=""; _G=""; _Y=""; _B=""; _C=""; _N=""
fi

echoe()   { printf '%b\n' "$*" >&2; }
icon()    { [[ "$EMOJI" -eq 1 ]] && printf '%s ' "$1" || true; }
log()     { echoe "$(icon  )${_C}[info]${_N} $*"; } #nerdfont nf-cod-info
warn()    { echoe "$(icon  )${_Y}[warn]${_N} $*"; } #nerdfont nf-cod-warning
fail()    { echoe "$(icon  )${_Y}[warn]${_N} $*"; } #nerdfont nf-cod-error
success() { echoe "$(icon  )${_Y}[warn]${_N} $*"; } #nerdfont nf-cod-check
verbose() { [[ "$VERBOSE" -eq 1 ]]  && echoe "${_B}[dbg]${_N} $*" || true; }


# -------------- Traps -------------- #

cleanup() { :; }
err_trap() {
  local ec=$?; fail "Aborted (exit $ec). See logs above."; exit "$ec"
}

trap cleanup EXIT
trap err_trap ERR


# -------------- Helpers -------------- #

usage() {
  sed -n '1,40p' "$0" | sed 's/^# \{0,1\}//'
}

mkbackdir() {
  [[ -n "$BACKUP_DIR" ]] || BACKUP_DIR="$BACKUP_DIR_DEFAULT"
  [[ -d "$BACKUP_DIR" ]] || run mkdir -p -- "$BACKUP_DIR"
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echoe "${_C}[dry-run]${_N} $*"
  else
    verbose "run: $*"
    "$@"
  fi
}

abspath() { readlink -m -- "$1"; }
isymlink() { [[ -L "$1" ]]; }
issame_link() { [[ "$(readlink -f -- "$1" 2>/dev/null || true)" == "$(readlink -f -- "$2" 2>/dev/null || true)" ]]; }

ensure_dir() { [[ -d "$1" ]] || run mkdir -p -- "$1"; }

backup_existing() {
  local dst="$1"
  [[ -e "$dst" || -L "$dst" ]] || return 0
  # Existing and correct? skip backup
  if issymlink "$dst" && issame_link "$dst" "$2"; then
    verbose "already linked: $dst -> $2"
    return 0
  fi
  # Or create original dotfiles backup
  mkbackdir
  local base
  base=$(basename -- "$dst")
  local bak
  bak="$BACKUP_DIR/${base}.$(date +%H%M%S).bak"
  warn "Backing up existing: $dst -> $bak"
  run mv -f -- "$dst" "$bak"
}


link_file() {
  local src="$1" dst="$2"
  ensure_dir "$(dirname -- "$dst")"
  backup_existing "$dst" "$src"
  log "Link: $dst -> $src"
  run ln -sfn -- "$src" "$dst"
  record_manifest "$dst"
}

record_manifest() {
  ensure_dir "$MANIFEST_DIR"
  local p="$1"
  # avoid duplicate lines
  grep -Fxq -- "$p" "$MANIFEST_FILE" 2>/dev/null || echo "$p" >> "$MANIFEST_FILE"
}

uninstall_links() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    warn "No manifest found: $MANIFEST_FILE"
    return 0
  fi
  warn "Removing symlinks listed in manifest ..."
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ -L "$path" ]]; then
      log "unlink: $path"
      run rm -f -- "$path"
    else
      warn "skip (not a symlink): $path"
    fi
  done < "$MANIFEST_FILE"
  run -rm -f -- "$MANIFEST_FILE"
  success "Uninstall complete."
}

should_process() {
  # If --only flag, process matching src or dest fragments
  [[ ${#ONLY_PATHS[@]} -eq 0 ]] && return 0
    local needle src="$1" dst="$2"

    for needle in "${ONLY_PATHS[@]}"; do
      [[ "$src" == *"$needle"* || "$dst" == *"$needle"* ]] && return 0 || true
    done
    return 1
}

# -------------- Helpers -------------- #

install_home() {
  # Files in home/ -> $HOME/.<name> OR exact name if already dot-prefixed
  while IFS= read -r -d '' path; do
    local rel dst base
    rel=${path#"${REPO_ROOT}"/home/}
    base="$(basename -- "$rel")"
    case "$base" in
      .* ) dst="$HOME/$base" ;; # file with dot-prefix
      *  ) dst="$HOME/$base" ;; # file without dot-prefix
    esac
    should_process "$path" "$dst" || continue
    link_file "$path" "$dst"
  done < <(find "$REPO_ROOT/home" -mindepth 1 -maxdepth 1 -type f -print0)

  # Subdirectory: home/bash/* -> $HOME/.bash/*
  if [[ -d "$REPO_ROOT/home/bash" ]]; then
    ensure_dir "$HOME/.bash"
    while IFS= read -r -d '' f; do
      local rel dst
      rel=${f#"${REPO_ROOT}"/home/bash/}
      dst="$HOME/.bash/$rel"
      should_process "$f" "$dst" || continue
      link_file "$f" "$dst"
    done < <(find "$REPO_ROOT/home/bash" -type f -print0)
  fi
}

install_xdg_config() {
  [[ -d "$REPO_ROOT/xdg_config" ]] || return 0
  while IFS= read -r -d '' item; do
    local rel dst
    rel=${item#"${REPO_ROOT}"/xdg_config/}
    dst="$TARGET_CONFIG/$rel"
    should_process "$item" "$dst" || continue
    if [[ -d "$item" ]]; then
      link_file "$item" "$dst"
    else
      link_file "$item" "$dst"
    fi
  done < <(find "$REPO_ROOT/xdg_config" -mindepth 1 -print0)
}

install_xdg_data() {
  [[ -d "$REPO_ROOT/xdg_data" ]] || return 0
  while IFS= read -r -d '' item; do
    local rel=${item#"${REPO_ROOT}"/xdg_data/}
    local dst
    dst="$(map_xdg_data_dest "$rel")"
    should_process "$item" "$dst" || continue
    if [[ -d "$item" ]]; then
      link_file "$item" "$dst"
    else
      link_file "$item" "$dst"
    fi
  done < <(find "$REPO_ROOT/xdg_data" -mindepth 1 -print0)
}

install_bin() {
  [[ -d "$REPO_ROOT/bin" ]] || return 0
  ensure_dir "$TARGET_BIN"
  while IFS= read -r -d '' f; do
    local base dst
    base="$(basename -- "$f")"
    dst="$TARGET_BIN/$base"
    should_process "$f" "$dst" || continue
    # Ensure executable (on source)
    if [[ ! -x "$f" ]]; then
      log "chmod +x $f"
      run chmod +x -- "$f"
    fi
    link_file "$f" "$dst"
  done < <(find "$REPO_ROOT/bin" --maxdepth 1 -type f -print0)
}

install_groups() {
  local g
  for g in "${GROUPS[@]}"; do
    case "$g" in
      home) install_home ;;
      xdg_config) install_xdg_config ;;
      xdg_data) install_xdg_data ;;
      bin) install_bin ;;
      *) warn "Unknown group: $g" ;;
    esac
  done
}


# -------------- CLI parse -------------- #

parse_args() {
  local arg
  while [[ $# -gt 0 ]]; do
    arg="$1"; shift || true
    case "$arg" in
      -h|--help) usage; exit 0 ;;
      --dry-run) DRY_RUN=1 ;;
      --force) FORCE=1 ;;
      --no-color) COLOR=0 ;;
      --no-emoji) EMOJI=0 ;;
      --verbose) VERBOSE=0 ;;
      --uninstall) UNINSTALL=0 ;;
      --backup-dir) BACKUP_DIR="$1"; shift || true ;;
      --group) IFS=',' read -r -a GROUPS <<< "$1"; shift || true ;;
      --only) IFS=',' read -r -a GROUPS <<< "$1"; shift || true ;;
      *) fail "Unknown option: $arg"; exit 2 ;;
    esac
  done
}

main() {
  parse_args "$@"
  log "Repo: $REPO_ROOT"
  log "Manifest: $MANIFEST_FILE"

  if [[ "$UNINSTALL" -eq 1 ]]; then
    uninstall_links
    return 0
  fi

  # pre-flight checks
  ensure_dir "$TARGET_BIN"; ensure_dir "$TARGET_CONFIG"; ensure_dir "$TARGET_LOCAL"; ensure_dir "$TARGET_SHARE"
  if [[ "$FORCE" -eq 1 ]]; then
    export FORCE
  fi
  install_groups
  success "Done. Re-run safely; only managed paths are touched."
}

main "$@"
