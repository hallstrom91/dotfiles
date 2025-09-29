#!/usr/bin/env bash

# install.sh - dotfiles install script.
# idempotent, fail-safe script.

##########################
# --- Defaults / CLI --- #
##########################
EMOJI=${EMOJI:-1}
COLOR=${COLOR:-1}
VERBOSE=${VERBOSE:-0}
DRY_RUN=${DRY_RUN:-0}
NO_BAK=${NO_BAK:-0}
YES=${YES:-0}
SHOW_PATHS=${SHOW_PATHS:-0}
DOTFILES_ROOT='' # auto-detect if empty
ROLE=''          # override with --role

usage() {
  cat <<EOF
Usage: ${0##*/} [options]

Options:
-n, --dry-run          Print planned actions without changing the system
-v, --verbose          Extra debug logging
-p, --path             Show 'src -> dst' values (preflight only)
-y, --yes, --force     Skip confirmation prompt (pflight etc)
--no-bak               Skip backup of existing files/dirs before actions.
--no-color             Disable colored output
--no-emoji             Disable icons/emoji (requires nerd-fonts)
--root PATH            Set dotfiles root (auto cwd based on install.sh location)
--role ROLE            Force (role) 'laptop' or 'desktop' (auto from hostname OR default: 'desktop')
-h, --help          Show help
EOF
}

while (($#)); do
  case "$1" in
  -n | --dry-run) DRY_RUN=1 ;;
  -v | --verbose) VERBOSE=1 ;;
  -p | --path) SHOW_PATHS=1 ;;
  -y | --yes | --force) YES=1 ;;
  --no-bak) NO_BAK=1 ;;
  --no-color) COLOR=0 ;;
  --no-emoji) EMOJI=0 ;;
  --root)
    DOTFILES_ROOT=$2
    shift
    ;;
  --role)
    ROLE=$2
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    break
    ;;
  -*)
    echo "Unknown flag: $1" >&2
    usage
    exit 2
    ;;
  *) break ;;
  esac
  shift
done

#########################
# --- Source Helper --- #
#########################
# ARROW ICON: nf-fa-arrow-right_long OR unicode.
ARROW=$([[ "$EMOJI" -eq 1 ]] && printf " " || printf '->')
AR="$ARROW"

short_src() {
  local p=$1
  if [[ $p == "$DOTFILES_ROOT"* ]]; then
    printf 'dotfiles/%s' "${p#"$DOTFILES_ROOT/"}"
  else
    printf '%s' "$p"
  fi
}

short_dst() {
  local p=$1
  printf '%s' "${p/#$HOME/~}"
}

_report_pair() {
  local sl=$1 sp=$2 dp=$3 # src_label src_path dst_path

  local s_ok=0 d_ok=0 status

  [[ -d $sp ]] && s_ok=1
  [[ -d $dp ]] && d_ok=1

  local SS #DS
  SS=$(short_src "$sp")
  DS=$(short_dst "$dp")

  if ((s_ok)); then
    if ((d_ok)); then
      status="${_G}[confirmed]${_N}"
    else
      status="${_Y}[create]${_N}"
    fi

    # ok OR create - info
    log "$status $(printf '%s %-16s %s %16s' "$sl:" "${SS}" "$AR" "${DS}")"
    return 0 # 0 = success
  else
    status="${_R}[missing]${_N}"
    fail "$status $(printf '%s %-16s %-16s %s' "$sl:" "${SS}" "$AR" "$DS")"
    return 1 # 1 = fail
  fi
}

# validate sources
validate_sources() {
  log "${_G}[found]${_N} DOTFILES_ROOT: $DOTFILES_ROOT"

  local ok=1
  _report_pair "CONFIG" "$SRC_XDG_CONFIG" "$TARGET_XDG_CONFIG" || ok=0
  _report_pair "HOME" "$SRC_HOME" "$TARGET_HOME" || ok=0
  _report_pair "BIN" "$SRC_BIN" "$TARGET_BIN" || ok=0
  _report_pair "DATA" "$SRC_XDG_DATA" "$TARGET_XDG_DATA" || ok=0

  ((ok)) || exit 1
  # return 0
}

# confirm or abort
confirm_or_abort() {
  local ans
  printf '%bProceed with installation?%b [%s/%s]: ' "$_C" "$_N" "${_G}Y${_N}" "${_R}n${_N}"
  read -r ans
  case "$ans" in
  '' | [Yy] | [Yy][Ee][Ss]) return 0 ;;
  *)
    fail "Operation aborted by user."
    exit 130
    ;;
  esac
}

###########################
# --- Paths / Targets --- #
###########################

if [[ -z $DOTFILES_ROOT ]]; then
  DOTFILES_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
fi

if [[ ! -d "$DOTFILES_ROOT/xdg_config" ]]; then
  fail "Can't find '$DOTFILES_ROOT/xdg_config'. Use flag: --root /path/to/dotfiles"
  exit 1
fi

# dst = users $HOME
TARGET_HOME="$HOME"
TARGET_BIN="$TARGET_HOME/.bin"
TARGET_XDG_CONFIG=${XDG_CONFIG_HOME:-"$TARGET_HOME/.config"}
TARGET_XDG_DATA=${XDG_DATA_HOME:-"$TARGET_HOME/.local/share"}

# src = dotfiles-repo
SRC_HOME="$DOTFILES_ROOT/home"
SRC_XDG_CONFIG="$DOTFILES_ROOT/xdg_config"
SRC_XDG_DATA="$DOTFILES_ROOT/xdg_data"
SRC_BIN="$DOTFILES_ROOT/bin"

#######################
# --- Role / Host --- #
#######################

declare -A APP_ENTRYPOINT_DEST=(
  [kitty]="kitty/kitty.conf"
  [wezterm]="wezterm/wezterm.lua"
)

declare -A APP_ENTRYPOINT_SRC_FMT=(
  [kitty]="kitty/configs/%s.conf"
  [wezterm]="wezterm/configs/%s.lua"
)

detect_role() {
  local host role
  if [[ -n $ROLE ]]; then
    printf '%s\n' "$ROLE"
    return
  fi

  host="${HOSTNAME:-$(hostname -s 2>/dev/null || hostname || uname -n)}"

  case "$host" in
  laptop) role="laptop" ;;
  desktop) role="desktop" ;;
  *)
    role="desktop"
    warn "Unknown host '$host' $ARROW default 'desktop'"
    ;;
  esac
  printf '%s\n' "$role"
}

# Map xdg_data special subpaths -> ~/.local/*/*
# ex: xdg_data/applications -> ~/.local/share/applications
map_xdg_data_dest() {
  local rel
  rel="$1"

  case "$rel" in
  applications | applications/*) printf '%s\n' "$TARGET_XDG_DATA/${rel#applications/}" ;;
  icons | icons/*) printf '%s\n' "$TARGET_XDG_DATA/${rel#icons/}" ;;
  fonts | fonts/*) printf '%s\n' "$TARGET_XDG_DATA/${rel#fonts/}" ;;
  *) printf '%s\n' "$TARGET_XDG_DATA/$rel" ;;
  esac
}

###################
# --- Logging --- #
###################
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

#######################
# --- Error Traps --- #
#######################

cleanup() { :; }

err_trap() {
  local ec=$?
  fail "Aborted (exit $ec). See logs above."
  exit "$ec"
}

trap cleanup EXIT
trap err_trap ERR

##########################
# --- Command runner --- #
##########################

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

#########################
# --- Helper Func's --- #
#########################

mkparent() {
  local dst="$1" dir
  dir="${dst%/*}"

  [[ $dir == "$dst" ]] && return 0
  if [[ -n $dir && ! -d $dir ]]; then
    run mkdir -p -- "$dir"
  fi
}

safe_rm() {
  local p=$1
  [[ -n $p && $p != "/" ]] || {
    fail "Refusing to remove: '$p'"
    exit 1
  }
  run rm -rf -- "$p"
}
## return codes:
# 0: symlink = OK | 1: create sl |
# 2: replace wrong/broken sl | 3: backup (?)
ensure_link() {
  local src=$1 dst=$2
  mkparent "$dst"

  # correct ?
  if [[ -L $dst ]]; then
    local cur
    cur=$(readlink -f -- "$dst" 2>/dev/null || true)
    local want
    want=$(readlink -f -- "$src" 2>/dev/null || true)

    if [[ -n $cur && -n $want && $cur == "$want" ]]; then
      verbose "Link ok: $src $ARROW $dst"
      return 0
    fi
    warn "Replacing link: $dst"
    run rm -f -- "$dst"
    run ln -s -- "$src" "$dst"
    return 2
  elif [[ -e $dst ]]; then
    if ((NO_BAK == 1)); then
      warn "Overwriting without backup: $dst"
      safe_rm "$dst"
      run ln -s -- "$src" "$dst"
      return 3
    else
      local ts bak
      ts=$(date +%Y%m%d_%H%M%S)
      bak="${dst}.bak.${ts}"
      warn "Existing file/dir backup at: $dst $ARROW $bak"
      run mv -- "$dst" "$bak"
      run ln -s -- "$src" "$dst"
      return 3
    fi
  else
    run ln -s -- "$src" "$dst"
    return 1
  fi
}

# hard copy (not sl)
# gnupg, fonts/icons (?), ?
copy_file() {
  local src=$1 dst=$2 mode=$3
  mkparent "$dst"
  if cmp -s -- "$src" "$dst" 2>/dev/null; then
    verbose "Copy ok (unchanged): $dst"
  else
    run install -m "${mode:-0644}" -- "$src" "$dst"
  fi
}

############################
############################
# -----| Installers |----- #
############################
############################

# install xdg_config/* -dirs to $HOME/.config/*
install_xdg_config_dirs() {
  log "Creating symlinks for xdg_config/* $ARROW $TARGET_XDG_CONFIG"
  local d name src dst
  local _save
  _save=$(shopt -p nullglob)
  shopt -s nullglob

  for d in "$SRC_XDG_CONFIG"/*; do
    [[ -d $d ]] || continue
    name=${d##*/}
    src=$d
    dst="$TARGET_XDG_CONFIG/$name"
    ensure_link "$src" "$dst"
  done

  eval "$_save"
}

# select -| [kitty/wezterm]-dirs
# select -| {desktop,latop}-cfg based on hostname.
# ex: xdg_config/kitty/configs/desktop.conf -> ~/.config/kitty/kitty.conf
configure_app_entrypoints() {
  local role template rel app dest src_rel target_path
  role=$(detect_role)
  log "Applications entrypoints for app-cfgs (role: $role)"
  for app in "${!APP_ENTRYPOINT_DEST[@]}"; do
    dest=${APP_ENTRYPOINT_DEST[$app]}        # ex: kitty/kitty.conf
    template=${APP_ENTRYPOINT_SRC_FMT[$app]} # ex kitty/configs/%s.conf
    rel=${template//%s/$role}                # ex kitty/configs/desktop.conf

    src_rel="$SRC_XDG_CONFIG/$rel"
    target_path="$TARGET_XDG_CONFIG/$dest"

    if [[ ! -e $src_rel ]]; then
      warn "$app: missing source '$rel' - skipping."
      continue
    fi
    ensure_link "$src_rel" "$target_path"
  done

}

# install xdg_data/{dirs|files} -> ~/.local/share
# fonts -| copy files|dirs -> ~/.local/share/fonts
# icons -| copy files|dirs -> ~/.local/share/icons
# applications -| sl *.desktop files -> ~/.local/share/applications
install_xdg_data() {
  [[ -d $SRC_XDG_DATA ]] || return 0
  log "Creating symlink and copies xdg_data $ARROW $TARGET_XDG_DATA"

  local p rel dst changed_fonts=0
  #shopt -s dotglob nullglob
  local _save
  _save=$(shopt -p nullglob)
  shopt -s nullglob

  while IFS= read -r -d '' p; do
    rel=${p#"$SRC_XDG_DATA/"}
    dst=$(map_xdg_data_dest "$rel")
    case "$rel" in
    fonts | fonts/* | icons | icons/*)
      if [[ -d $p ]]; then
        # mirror
        run mkdir -p -- "$dst"
        run cp -a -- "$p"/. "$dst"/
      else
        copy_file "$p" "$dst" 0644
      fi
      [[ $rel == fonts* ]] && changed_fonts=1
      ;;
    *)
      ensure_link "$p" "$dst"
      ;;
    esac
  done < <(find "$SRC_XDG_DATA" -mindepth 1 -maxdepth 1 -print0)

  eval "$_save"

  if ((changed_fonts == 1)) && command -v fc-cache >/dev/null 2>&1; then
    run fc-cache -f
  elif ((changed_fonts == 1)); then
    warn "fc-cache missing. Skipping refresh"
  fi

}

# copy/sl: bin/* -files  $HOME/.bin/* or $HOME/.local/bin/*
install_bin() {
  [[ -d "$SRC_BIN" ]] || return 0
  log "symlink for bin/* $ARROW \$HOME/.bin (or create)"
  local target_bin="$TARGET_BIN" # switch to ~/.local/bin ?
  run mkdir -p -- "$target_bin"

  local f
  for f in "$SRC_BIN"/*; do
    [[ -f $f ]] || continue
    if [[ $f == *.sh && ! -x $f ]]; then
      run chmod +x -- "$f"
    fi
    [[ -x $f ]] || continue
    ensure_link "$f" "$target_bin/${f##*/}"

  done
}

# install home/ -dir/files to $HOME ...
install_home_files() {
  if [[ -f $SRC_HOME/bashrc ]]; then
    ensure_link "$SRC_HOME/bashrc" "$TARGET_HOME/.bashrc"
  fi

  if [[ -d $SRC_HOME/bash ]]; then
    run mkdir -p -- "$TARGET_HOME/.bash"
    local f
    for f in "$SRC_HOME/bash"/*; do
      [[ -f $f ]] || continue
      ensure_link "$f" "$TARGET_HOME/.bash/${f##*/}"
    done
  fi

  # other files
  [[ -f $SRC_HOME/editorconfig ]] && ensure_link "$SRC_HOME/editorconfig" "$TARGET_HOME/.editorconfig"
  [[ -f $SRC_HOME/gitignore_global ]] && ensure_link "$SRC_HOME/gitignore_global" "$TARGET_HOME/.gitignore_global"

  if [[ -d $SRC_HOME/templates && -f $SRC_HOME/templates/commit_template ]]; then
    ensure_link "$SRC_HOME/templates/commit_template" "$TARGET_HOME/Templates/.commit_template"
  fi
}

install_gnupg() {
  local src="$SRC_HOME/gnupg/gpg-agent.conf"
  [[ -f $src ]] || return 0
  log "Copying gnupg/gpg-agent.conf"
  # run mkdir -p -- "$TARGET_HOME/.gnupg"
  # run chmod 700 -- "$TARGET_HOME/.gnupg"
  copy_file "$src" "$TARGET_HOME/.gnupg/gpg-agent.conf" 0600
}

####################
####################
# ----| Main |---- #
####################
####################

# if flag: -p | --path is used: show sources -> exit
if ((SHOW_PATHS == 1)); then
  validate_sources
  exit 0
fi

main() {
  validate_sources
  if ((YES == 0)); then
    if ((DRY_RUN == 1)); then
      warn "Dry-run: skipping confirmation."
    else
      confirm_or_abort
    fi
  fi

  install_xdg_config_dirs
  configure_app_entrypoints
  install_xdg_data
  install_home_files
  install_gnupg
  install_bin

  success "Done."
  ((DRY_RUN == 1)) && warn "Dry-run only. Re-run without flag to apply."
}

main "$@"
