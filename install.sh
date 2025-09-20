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
# |- bin/                -> link to $HOME/.bin/
# |- home/               -> link files or subdirs to $HOME
# |  ├── bash/           -> link to $HOME/.bash/<files>
# |  └── gnupg/          -> special-case: sensitive to permissions; only copy (hard) *.conf
# |- xdg_config/         -> link subdirs/files into ~/.config/
# |  |-- autostart/      -> special-case: only link files
# |- xdg_data/           -> link into ~/.local/ | special-case mapping to ~/.local/share/
#    |-- applications/
#    |-- fonts/
#    |-- icons/

set -Eeuo pipefail
IFS=$'\n\t'

# -------------- Config -------------- #

REPO_ROOT="$(cd -- "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd -P)"
BACKUP_DIR_DEFAULT="$HOME/.local/share/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
MANIFEST_DIR="$HOME/.local/share/dotfiles-installer" # ?
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt" # ?
TARGET_BIN="$HOME/.bin"
TARGET_XDG_CONFIG="$HOME/.config"
TARGET_XDG_LOCAL="$HOME/.local"
TARGET_XDG_SHARE="$HOME/.local/share"
EMOJI=${EMOJI:-1}
COLOR=${COLOR:-1}
VERBOSE=${VERBOSE:-0}
DRY_RUN=${DRY_RUN:-0}
FORCE=${FORCE:-0}
UNINSTALL=${UNINSTALL:-0}
BACKUP_DIR=""
INSTALL_GROUPS=(home xdg_config xdg_data bin)
ONLY_PATHS=()
NONFATAL_ERRORS=0

# Map xdg_data special subpaths -> ~/.local/*/*
# here: xdg_data/applications -> ~/.local/share/applications
map_xdg_data_dest() {
  local rel
  rel="$1"
  case "$rel" in
    applications/*|applications) printf '%s\n' "$TARGET_XDG_SHARE/${rel#applications/}" ;;
    icons/*|icons)               printf '%s\n' "$TARGET_XDG_SHARE/${rel#icons/}" ;;
    fonts/*|fonts)               printf '%s\n' "$TARGET_XDG_SHARE/${rel#fonts/}" ;;
    *)                           printf '%s\n' "$TARGET_XDG_LOCAL/$rel" ;;
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
    printf '%b[dry-run]%b %s\n' "$_C" "$_N" "$(printf '%q ' "$@")"
  else
    verbose "run: $(printf '%q' "$@")"
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
  if [[ -L "$dst" ]] && issame_link "$dst" "$2"; then
  # if issymlink "$dst" && issame_link "$dst" "$2"; then
    verbose "already linked: $dst -> $2"
    return 0
  fi

  # Or create original dotfiles backup
  mkbackdir
  local base
  local bak
  base=$(basename -- "$dst")
  bak="$BACKUP_DIR/${base}.$(date +%H%M%S).bak"
  warn "Backing up existing: $dst -> $bak"
  run mv -f -- "$dst" "$bak"
}


link_file() {
  local src="$1"
  local dst="$2"
  ensure_dir "$(dirname -- "$dst")"
  backup_existing "$dst" "$src"
  #log "Link: $src -> $dst"
  success "Link: $src -> $dst"
  run ln -sfn -- "$src" "$dst"
  record_manifest "$dst"
}

record_manifest() {
  local p="$1"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    verbose "skip manifest (dry-run): $p"
    return 0
  fi

  ensure_dir "$MANIFEST_DIR"
  # avoid duplicate lines
  if ! grep -Fxq -- "$p" "$MANIFEST_FILE" 2>/dev/null; then
    printf '%s\n' "$p" >> "$MANIFEST_FILE"
  fi
}

uninstall_links() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    err "No manifest found: $MANIFEST_FILE"
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
  [[ -d "$REPO_ROOT/home" ]] || return 0

  # Files in home/ -> $HOME/.<name> (always dot-prefix for top-lvl files)
  while IFS= read -r -d '' path; do
    local rel
    local dst
    local base
    rel=${path#"${REPO_ROOT}"/home/}
    base="$(basename -- "$rel")"
    case "$base" in
      .* ) dst="$HOME/$base" ;; # file with dot-prefix
      *  ) dst="$HOME/.${base}" ;; # add dot-prefix in symlink dest
    esac
    should_process "$path" "$dst" || continue
    link_file "$path" "$dst"
  done < <(find "$REPO_ROOT/home" -mindepth 1 -maxdepth 1 -type f -print0)

  # Subdirectory: home/<dir>/* -> $HOME/.<dir>/*
  while IFS= read -r -d '' subdir; do
    local dname
    local dst_dir
    dname="$(basename -- "$subdir")"
    dst_dir="$HOME/.${dname}"
    ensure_dir "$dst_dir"

    # Special-case: GnuPG sensitive to permissions. Hard copy + set permission.
    if [[ "$dname" == "gnupg" ]]; then
      run chmod 700 -- "$dst_dir"
      while IFS= read -r -d '' f; do
        local relf
        local destf
        relf=${f#"$subdir"/}
        destf="$dst_dir/$relf"
        should_process "$f" "$destf" || continue
        ensure_dir "$(dirname -- "$destf")"
        case "$relf" in
          *conf)
            # copy (hard) and strict perms
            run install -m 600 -- "$f" "$destf"
            verbose "copied (secure): $f -> $destf"
            ;;
          *)
            # default for unexpected file in gnupg/* - deny.
            if [[ "$DRY_RUN" -eq 1 ]]; then
              warn "gnupg: skipping unexpected file (dry-run): $f"
            else
              warn "gnupg: unexpected file skipped: $f"
              NONFATAL_ERRORS=1
            fi
            ;;
        esac
      done < <(find "$subdir" -type f -print0)
      continue
    fi

    while IFS= read -r -d '' f; do
      local relf
      local destf
      relf=${f#"$subdir"/}
      destf="$dst_dir/$relf"
      should_process "$f" "$destf" || continue
      ensure_dir "$(dirname -- "$destf")"
      link_file "$f" "$destf"
    done < <(find "$subdir" -type f -print0)
  done < <(find "$REPO_ROOT/home" -mindepth 1 -maxdepth 1 -type d -print0)
}

install_xdg_config() {
  [[ -d "$REPO_ROOT/xdg_config" ]] || return 0

  # hostname
  local host
  local role
  host="${HOSTNAME:-$(hostname -s 2>/dev/null || hostname || uname -n)}"
  case "$host" in
    laptop) role="laptop" ;;
    desktop) role="desktop" ;;
    *) role="desktop"
      warn "Unknown host: '$host' -> defaulting to 'desktop'"
      ;;
  esac

  while IFS= read -r -d '' item; do
    local rel
    local dst
    rel=${item#"${REPO_ROOT}"/xdg_config/}
    dst="$TARGET_XDG_CONFIG/$rel"
    should_process "$item" "$dst" || continue


    # Special-case: autostart/ -> ~/.config/autostart/*
    if [[ -d "$item"  && "$rel" == "autostart" ]]; then
      ensure_dir "$dst"
      while IFS= read -r -d '' f; do
        local relf
        local destf
        relf=${f#"$item"/}
        destf="$dst/$relf"
        should_process "$f" "$destf" || continue
        ensure_dir "$(dirname -- "$destf")"
        link_file "$f" "$destf"
      done < <(find "$item" -type f -print0)
      continue
    fi

    # Special-case: kitty/ -> select cfg based on hostname
    if [[ "$rel" == "kitty" || "$rel" == "kitty/"* ]]; then

      local kitty_root
      kitty_root="$REPO_ROOT/xdg_config/kitty"

      # 1) kitty/themes/
      if [[ -d "$kitty_root/themes" ]]; then
        ensure_dir "$TARGET_XDG_CONFIG/kitty"
        link_file "$kitty_root/themes" "$TARGET_XDG_CONFIG/kitty/themes"
        fi

        # 2) kitty/configs/<role>.conf
        local cfg_src
        local cfg_dst
        cfg_src="$kitty_root/configs/${role}.conf"
        cfg_dst="$TARGET_XDG_CONFIG/kitty/${role}.conf"
        if [[ -f "$cfg_src" ]]; then
          ensure_dir "$(dirname -- "$cfg_dst")"
          link_file "$cfg_src" "$cfg_dst"
        else
          warn "kitty: missing config for role: '$role' at $cfg_src"
          fi

          #3) other kitty files in top
          while IFS= read -r -d '' topf; do
            [[ -d "$topf" ]] && continue
            case "$topf" in
              "$kitty_root"/themes/*|"$kitty_root"/configs/*) continue ;;
            esac
            local destf
            destf="$TARGET_XDG_CONFIG/kitty/$(basename -- "$topf")"
            should_process "$topf" "$destf" || continue
            ensure_dir "$(dirname -- "$destf")"
            link_file "$topf" "$destf"
          done < <(find "$kitty_root" -mindepth 1 -maxdepth 1 -print0)
          continue
    fi

    # Special-case: wezterm/ -> select cfg based on hostname



    #   if [[ "$rel" == "autostart" ]]; then
    #     #special-case: autostart/ -> ~/.config/autostart/*
    #     ensure_dir "$dst"
    #     while IFS= read -r -d '' f; do
    #       local relf
    #       local destf
    #       relf=${f#"$item"/}
    #       destf="$dst/$relf"
    #       should_process "$f" "$destf" || continue
    #       ensure_dir "$(dirname -- "$destf")"
    #       link_file "$f" "$destf"
    #     done < <(find "$item" -type f -print0)
    # else
    #   link_file "$item" "$dst"
    #   fi

    # else
    #   ensure_dir "$(dirname -- "$dst")"
    #   link_file "$item" "$dst"
    # fi
  done < <(find "$REPO_ROOT/xdg_config" -mindepth 1 -maxdepth 1 -print0)
}

install_xdg_data() {
  [[ -d "$REPO_ROOT/xdg_data" ]] || return 0

  while IFS= read -r -d '' top; do
    local reltop
    local dst_base
    reltop=${top#"$REPO_ROOT"/xdg_data/}
    dst_base="$(map_xdg_data_dest "$reltop")"

    if [[ -d "$top" ]]; then
      ensure_dir "$dst_base"
      while IFS= read -r -d '' f; do
        local relf
        local destf
        relf=${f#"$top"/}
        destf="$dst_base/$relf"
        should_process "$f" "$destf" || continue
        ensure_dir "$(dirname -- "$destf")"
        link_file "$f" "$destf"
      done < <(find "$top" -type f -print0)
    else
      local dst
      dst="$dst_base"
      should_process "$top" "$dst" || continue
      ensure_dir "$(dirname -- "$dst")"
      link_file "$top" "$dst"
    fi
  done < <(find "$REPO_ROOT/xdg_data" -mindepth 1 -maxdepth 1 -print0)
}

install_bin() {
  [[ -d "$REPO_ROOT/bin" ]] || return 0
  ensure_dir "$TARGET_BIN"

  while IFS= read -r -d '' f; do
    local base
    local dst
    base="$(basename -- "$f")"
    dst="$TARGET_BIN/$base"
    should_process "$f" "$dst" || continue

    # Ensure executable (on source)
    if [[ "$base" == *.sh && ! -x "$f" ]]; then
      log "chmod +x $f"
      run chmod +x -- "$f"
    fi
    link_file "$f" "$dst"
  done < <(find "$REPO_ROOT/bin" -maxdepth 1 -type f -print0)
}

install_groups() {
  local g
  for g in "${INSTALL_GROUPS[@]}"; do
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
      --verbose) VERBOSE=1 ;;
      --uninstall) UNINSTALL=1 ;;
      --backup-dir) BACKUP_DIR="$1"; shift || true ;;
      --group) IFS=',' read -r -a INSTALL_GROUPS <<< "$1"; shift || true ;;
      --only) IFS=',' read -r -a ONLY_PATHS <<< "$1"; shift || true ;;
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
  ensure_dir "$TARGET_BIN"; ensure_dir "$TARGET_XDG_CONFIG"; ensure_dir "$TARGET_XDG_LOCAL"; ensure_dir "$TARGET_XDG_SHARE"; ensure_dir "$MANIFEST_DIR"
  if [[ "$FORCE" -eq 1 ]]; then
    export FORCE
  fi

  install_groups

  if [[ "$NONFATAL_ERRORS" -ne 0 ]]; then
    warn "Completed with non-fatal errors (see logs)."
    return 2
  fi
  success "Done."
}

main "$@"
