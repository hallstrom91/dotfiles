#!/usr/bin/env bash
# install.sh - idempotent, fail-safe dotfiles-script.

# -- Globals / Cfg -----------------------------------
REPO_ROOT="$(cd -- "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd -P)"

BACKUP_DIR_DEFAULT="$HOME/.local/share/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
MANIFEST_DIR="$HOME/.local/share/dotfiles-installer"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"

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

declare -A ENSURED_DIRS=()

declare -A APP_ENTRYPOINT_DEST=(
  [kitty]="kitty/kitty.conf"
  [wezterm]="wezterm/wezterm.lua"
)

declare -A APP_ENTRYPOINT_SRC_FMT=(
  [kitty]="kitty/configs/%s.conf"
  [wezterm]="wezterm/configs/%s.lua"
)

# detect role (desktop/laptop env)
detect_role() {
  local host="${HOSTNAME:-$(hostname -s 2>/dev/null || hostname || uname -n)}"
  local role="${DOTFILES_ROLE:-}"
  [[ -n $role ]] || case "$host" in
  laptop) role="laptop" ;;
  desktop) role="desktop" ;;
  *)
    role="desktop"
    warn "Unknown host '$host' -> default 'desktop'"
    ;;
  esac
  printf '%s\n' "$role"
}

# Map xdg_data special subpaths -> ~/.local/*/*
# here: xdg_data/applications -> ~/.local/share/applications
map_xdg_data_dest() {
  local rel
  rel="$1"
  case "$rel" in
  applications/* | applications) printf '%s\n' "$TARGET_XDG_SHARE/${rel#applications/}" ;;
  icons/* | icons) printf '%s\n' "$TARGET_XDG_SHARE/${rel#icons/}" ;;
  fonts/* | fonts) printf '%s\n' "$TARGET_XDG_SHARE/${rel#fonts/}" ;;
  *) printf '%s\n' "$TARGET_XDG_LOCAL/$rel" ;;
  esac
}

# -- Usage / Help ------------------------------------
usage() {
  cat <<'EOF'
  install.sh - idempotent, fail-safe dotfiles Installers

  Usage:
  ./install.sh [options]

  Options:
  -h, --help          Show help
  --dry-run           Print planned actions without changing the system
  --verbose           Extra debug logging
  --no-color          Disable colored output
  --no-emoji          Disable icons/emoji (requires nerd-fonts)
  --force             Reserverd flag (no prompt)
  --uninstall         Remove symlinks listed in manifest.txt
  --backup-dir <path> Override default backup directory
  --group <list>      Comma-separated groups to install: home,bin,xdg_config,xdg_data
  --only <list>       Comma-separated substrings to filter src/dst paths

  Environment:
  DOTFILES_ROLE       Force role (desktop|laptop). Automatic detection from hostname.
  EMOJI=0|1           Toggle nerdfont icon/emoji  (default 1)
  COLOR=0|1           Toggle color (default 1)
  DRY_RUN=0|1         Toggle dry-run (default 0)
EOF
}

# -- Logging -----------------------------------------

if [[ "$COLOR" -eq 1 ]]; then
  _R="\033[31m"
  _G="\033[32m"
  _Y="\033[33m"
  _B="\033[34m"
  _C="\033[36m"
  _N="\033[0m"
else
  _R=""
  _G=""
  _Y=""
  _B=""
  _C=""
  _N=""
fi

echoe() { printf '%b\n' "$*" >&2; }
icon() { [[ "$EMOJI" -eq 1 ]] && printf '%s ' "$1" || true; }
log() { echoe "$(icon )${_C}[info]${_N} $*"; }   #nerdfont nf-cod-info
warn() { echoe "$(icon )${_Y}[warn]${_N} $*"; }  #nerdfont nf-cod-warning
fail() { echoe "$(icon )${_R}[fail]${_N} $*"; }  #nerdfont nf-cod-error
success() { echoe "$(icon )${_G}[ok]${_N} $*"; } #nerdfont nf-cod-check
verbose() { [[ "$VERBOSE" -eq 1 ]] && echoe "${_B}[dbg]${_N} $*" || true; }

# -- Traps -------------------------------------------

cleanup() { :; }

err_trap() {
  local ec=$?
  fail "Aborted (exit $ec). See logs above."
  exit "$ec"
}

trap cleanup EXIT
trap err_trap ERR

# -- Command runner ----------------------------------
run() {
  local q='' a
  for a in "$@"; do q+=" $(printf '%q' "$a")"; done
  q="${q# }"

  if ((DRY_RUN == 1)); then
    if ((VERBOSE == 1)); then
      printf '%b[dry-run]%b %s\n' "$_C" "$_N" "$q" >&2
    fi
    return 0
  fi

  verbose "run:$q"
  "$@"
}

# -- Canonical paths (portable) -----------------------

canonpath() {
  # use 1) realpath | 2) Python fallback | 3) echo original
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath -- "$p" 2>/dev/null && return
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$p" <<'PY' 2>/dev/null || true
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
    return
  fi
  printf '%s\n' "$p"
}

# -- Symlink helpers ---------------------------------

issame_link() {
  local link="$1" #src
  local want="$2" #dst
  [[ -L "$link" ]] || return 1

  local cur
  cur=$(readlink -- "$link" 2>/dev/null || true)
  [[ -n "$cur" ]] || return 1

  # if cur = relative
  if [[ "$cur" != /* ]]; then
    cur="$(canonpath "$(dirname -- "$link")/$cur")"
  else
    cur="$(canonpath "$cur")"
  fi

  local want_abs
  want_abs="$(canonpath "$want")"
  [[ "$cur" == "$want_abs" ]]
}

# -- Dirs and guards ---------------------------------

ensure_dir() {
  local dir="$1"
  [[ -n "${ENSURED_DIRS[$dir]:-}" ]] && return 0

  #exists?
  if [[ -d "$dir" ]]; then
    ENSURED_DIRS["$dir"]=1
    return 0
  fi

  #or CREATE
  run mkdir -p -- "$dir"
  #save in mem
  ENSURED_DIRS["$dir"]=1
}

# ensure_dir() {
#   [[ -d "$1" ]] || run mkdir -p -- "$1"
# }

is_forbidden_dst() {
  case "$1" in
  "/" | "/etc" | "/usr" | "/bin" | "/boot" | "/opt" | "/sbin") return 0 ;;
  esac

  # REQUIRE TARGET IN HOME/* (or whitelisted)
  case "$1" in
  "$HOME" | "$HOME"/*) return 1 ;; # allowed (in/under $HOME)
  esac

  return 0 # forbidden (outside $HOME)
}

require_under_home() {
  local dst="$1"
  if is_forbidden_dst "$dst"; then
    fail "Refusing to touch path outside \$HOME or forbidden: $dst"
    return 1
  fi
  return 0
}

#-- Backups ------------------------------------------

mkbackdir() {
  [[ -n "$BACKUP_DIR" ]] || BACKUP_DIR="$BACKUP_DIR_DEFAULT"
  ensure_dir "$BACKUP_DIR"
}

_backup_name_for() {
  local dst="$1" ts rel rel_dir base dir out
  ts="$(date +%H%M%S)" #timestamp

  #realative to $HOME
  rel="${dst#"$HOME"/}"
  rel_dir="$(dirname -- "$rel")"
  [[ "$rel_dir" == "." ]] && rel_dir="" # root in $HOME, no subdir

  dir="$BACKUP_DIR"
  [[ -n "$rel_dir" ]] && dir="$dir/$rel_dir"

  ensure_dir "$dir"
  base="$(basename -- "$dst")"
  out="$dir/$base.$ts.bak"
  printf '%s\n' "$out"
}

backup_existing() {
  local dst="$1" src="$2"
  [[ -e "$dst" || -L "$dst" ]] || return 0

  # correct? no-op
  if issame_link "$dst" "$src"; then
    verbose "already linked: $dst -> $src"
    return 0
  fi

  # safety-net
  require_under_home "$dst" || return 1
  mkbackdir
  local bak
  bak="$(_backup_name_for "$dst")"
  if ((DRY_RUN == 1)); then
    warn "Would backup: $dst -> $bak"
  else
    warn "Backing up: $dst -> $bak"
  fi
  run mv -f -- "$dst" "$bak"
}

# -- Symlink Creation --------------------------------

_ln_symlink() {
  #prefer GNU ln -r
  local have_rel=0
  ln --help 2>/dev/null | grep -q -- ' -r, ' && have_rel=1

  local src="$1" dst="$2"
  if ((have_rel == 1)); then
    #GNU ln -srf (r = relative, f = overwrite symlink/file)
    run ln -srf -- "$src" "$dst"
  else
    # portabel: remove current -> create absolute symlink
    run ln -s -- "$src" "$dst"
  fi
}

link_file() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    fail "Source does not exist: $src"
    return 1
  fi

  ensure_dir "$(dirname -- "$dst")"
  backup_existing "$dst" "$src" || return 1
  require_under_home "$dst" || return 1

  _ln_symlink "$src" "$dst" || {
    fail "ln failed for: $dst"
    return 1
  }

  if ((DRY_RUN == 1)); then
    log "Would link: $dst -> $src"
  else
    success "Link: $dst -> $src"
  fi

  record_manifest "$dst" "$src"
}

# -- Manifest (dst<TAB>src) --------------------------
record_manifest() {
  local dst="$1"
  local src="$2"

  ((DRY_RUN == 1)) && {
    verbose "skip manifest (dry-run): $dst"
    return 0
  }

  ensure_dir "$MANIFEST_DIR"
  # if row exists - NO-OP
  if [[ -f "$MANIFEST_FILE" ]] && grep -Fqx -- "$dst"$'\t'"$src" "$MANIFEST_FILE"; then
    return 0
  fi
  printf '%s\t%s\n' "$dst" "$src" >>"$MANIFEST_FILE"
}

uninstall_links() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    warn "No manifest found: $MANIFEST_FILE (no-op)"
    return 0
  fi

  warn "Removing symlinks listed in manifest"
  local dst src

  while IFS=$'\t' read -r dst src || [[ -n "$dst" ]]; do
    [[ -z "$dst" ]] && continue
    if [[ -L "$dst" ]]; then
      if issame_link "$dst" "$src"; then
        log "unlink: $dst"
        run rm -f -- "$dst"
      else
        warn "skip (link target changed): $dst"
      fi
    else
      warn "skip (not a symlink): $dst"
    fi
  done <"$MANIFEST_FILE"

  run rm -f -- "$MANIFEST_FILE"
  success "Uninstall complete."
}

# -- Filter: --only ----------------------------------
should_process() {
  ((${#ONLY_PATHS[@]} == 0)) && return 0
  local needle src="$1" dst="$2"
  for needle in "${ONLY_PATHS[@]}"; do
    [[ "$src" == *"$needle"* || "$dst" == *"$needle"* ]] && return 0
  done
  return 1
}

# -- Installers --------------------------------------

install_home() {
  [[ -d "$REPO_ROOT/home" ]] || return 0

  # Files in home/ -> $HOME/.<name> (always dot-prefix for top-lvl files)
  while IFS= read -r -d '' path; do
    local rel dst base
    rel=${path#"${REPO_ROOT}"/home/}
    base="$(basename -- "$rel")"
    case "$base" in
    .*) dst="$HOME/$base" ;;   # file with dot-prefix
    *) dst="$HOME/.${base}" ;; # add dot-prefix in symlink dest
    esac
    should_process "$path" "$dst" || continue
    link_file "$path" "$dst"
  done < <(find "$REPO_ROOT/home" -mindepth 1 -maxdepth 1 -type f -print0)

  # Subdirectory: home/<dir>/* -> $HOME/.<dir>/*
  while IFS= read -r -d '' subdir; do
    local dname dst_dir
    dname="$(basename -- "$subdir")"
    dst_dir="$HOME/.${dname}"
    ensure_dir "$dst_dir"

    # Special-case GnuPG: Strict Policy
    if [[ "$dname" == "gnupg" ]]; then
      run chmod 700 -- "$dst_dir"
      while IFS= read -r -d '' f; do
        local relf destf
        relf=${f#"$subdir"/}
        destf="$dst_dir/$relf"
        should_process "$f" "$destf" || continue
        ensure_dir "$(dirname -- "$destf")"
        case "$relf" in
        *conf)
          run install -m 600 -- "$f" "$destf"
          verbose "copied (secure): $f -> $destf"
          ;;
        *)
          if ((DRY_RUN == 1)); then
            warn "gnupg: skipping unexpected file (dry-run): $f"
          else
            warn "GnuPG: unexpected file skipped: $f"
            NONFATAL_ERRORS=1
          fi
          ;;
        esac
      done < <(find "$subdir" -type f -print0)
      continue
    fi

    while IFS= read -r -d '' f; do
      local relf destf
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
  local role
  role="$(detect_role)"

  # files directly under xdg_config/
  while IFS= read -r -d '' f; do
    local rel dest
    rel=${f#"${REPO_ROOT}"/xdg_config/}
    dest="$TARGET_XDG_CONFIG/$rel"
    should_process "$f" "$dest" || continue
    ensure_dir "$(dirname -- "$dest")"
    link_file "$f" "$dest"
  done < <(find "$REPO_ROOT/xdg_config" -mindepth 1 -maxdepth 1 -type f -print0)

  # App dirs (kitty/, wezterm/ ...)
  while IFS= read -r -d '' appdir; do
    local app dst_root entry_name
    app="${appdir##*/}"
    dst_root="$TARGET_XDG_CONFIG/$app"
    ensure_dir "$dst_root"

    entry_name=""
    if [[ -n ${APP_ENTRYPOINT_DEST[$app]:-} ]]; then
      entry_name="$(basename -- "${APP_ENTRYPOINT_DEST[$app]}")"
    fi

    while IFS= read -r -d '' f; do
      local rel dest pdir
      rel=${f#"$appdir"/}
      case "$rel" in
      configs/*) continue ;;
      "$entry_name") continue ;;
      esac
      dest="$dst_root/$rel"
      should_process "$f" "$dest" || continue
      pdir=$(dirname -- "$dest")
      ensure_dir "$pdir"
      link_file "$f" "$dest"
    done < <(find "$appdir" -type f -print0)

    # entrypoint (IF DEFINED)
    if [[ -n ${APP_ENTRYPOINT_DEST[$app]:-} ]]; then
      local fmt src_rel src dest
      fmt="${APP_ENTRYPOINT_SRC_FMT[$app]}"
      src_rel="${fmt//%s/$role}"
      src="$REPO_ROOT/xdg_config/$src_rel"
      dest="$TARGET_XDG_CONFIG/${APP_ENTRYPOINT_DEST[$app]}"
      if [[ -f "$src" ]]; then
        should_process "$src" "$dest" || continue
        ensure_dir "$(dirname -- "$dest")"
        link_file "$src" "$dest"
      else
        warn "$app: missing role config for '$role' at $src"
      fi
    fi
  done < <(find "$REPO_ROOT/xdg_config" -mindepth 1 -maxdepth 1 -type d -print0)
}

install_xdg_data() {
  [[ -d "$REPO_ROOT/xdg_data" ]] || return 0

  while IFS= read -r -d '' top; do
    local reltop dst_base
    reltop=${top#"$REPO_ROOT"/xdg_data/}
    dst_base="$(map_xdg_data_dest "$reltop")"

    if [[ -d "$top" ]]; then
      ensure_dir "$dst_base"
      while IFS= read -r -d '' f; do
        local relf destf
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
    local base dst
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

# -- CLI parse ---------------------------------------

parse_args() {
  local arg
  while [[ $# -gt 0 ]]; do
    arg="$1"
    shift || true
    case "$arg" in
    -h | --help)
      usage
      exit 0
      ;;
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --no-color) COLOR=0 ;;
    --no-emoji) EMOJI=0 ;;
    --verbose) VERBOSE=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --backup-dir)
      BACKUP_DIR="$1"
      shift || true
      ;;
    --group)
      IFS=',' read -r -a INSTALL_GROUPS <<<"$1"
      shift || true
      ;;
    --only)
      IFS=',' read -r -a ONLY_PATHS <<<"$1"
      shift || true
      ;;
    *)
      fail "Unknown option: $arg"
      exit 2
      ;;
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
  ensure_dir "$TARGET_BIN"
  ensure_dir "$TARGET_XDG_CONFIG"
  ensure_dir "$TARGET_XDG_LOCAL"
  ensure_dir "$TARGET_XDG_SHARE"
  ensure_dir "$MANIFEST_DIR"

  ((FORCE == 1)) && export FORCE

  install_groups

  if ((NONFATAL_ERRORS != 0)); then
    warn "Completed with non-fatal errors (see logs)."
    return 2
  fi
  success "Done. Finito. Completed."
}

main "$@"
