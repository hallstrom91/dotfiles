#!/usr/bin/env bash

# wsx.sh - mount,unmount,status,enter for VeraCrypt workspaces.

set -Euo pipefail
IFS=$'\n\t'

#-- Config / Global -------------------

PW_TIMEOUT="${VC_TIMEOUT:-60}" # 1min

# Device/Parition (left) -> Mount points (right)
PARTITIONS=(
  "/dev/sdc1" # external
  "/dev/sdc2" # external
)

MOUNT_POINTS=(
  "/media/veracrypt1"
  "/media/veracrypt2"
)

# Defaults
DEFAULT_WORKDIR="/media/veracrypt2"
#DEFAULT_SIGNAL_FILE="mount_success.signal" # or ""
DEFAULT_SIGNAL_FILE="/run/user/$(id -u)/wsx.mount.signal"
LOCK_FILE="${WSX_LOCK_FILE:-/run/user/$(id -u)/wsx.mount.lock}"

# FS-owner & mask
FS_UID="$(id -u)"
FS_GID="$(id -g)"
FS_MASKS="umask=0002,dmask=0002,fmask=0002" #ntfs
FSOPTS="uid=${FS_UID},gid=${FS_GID},${FS_MASKS}"

# Log
EMOJI=${EMOJI:-1}
COLOR=${COLOR:-1}
VERBOSE=${VERBOSE:-0}
DRY_RUN=${DRY_RUN:-0}

#-- Logging ---------------------------

if [[ "$COLOR" -eq 1 ]]; then
  _R=$'\033[31m'
  _G=$'\033[32m'
  _Y=$'\033[33m'
  _C=$'\033[36m'
  _N=$'\033[0m'
else
  _R=""
  _G=""
  _Y=""
  _C=""
  _N=""
fi

icon() { [[ "$EMOJI" -eq 1 ]] && printf '%s ' "$1" || true; }
echoe() { printf '%b\n' "$*" >&2; }
log() { echoe "$(icon )${_C}[info]${_N} $*"; }   #nerdfont nf-cod-info
warn() { echoe "$(icon )${_Y}[warn]${_N} $*"; }  #nerdfont nf-cod-warning
fail() { echoe "$(icon )${_R}[fail]${_N} $*"; }  #nerdfont nf-cod-error
success() { echoe "$(icon )${_G}[ok]${_N} $*"; } #nerdfont nf-cod-check
verbose() { [[ "$VERBOSE" -eq 1 ]] && echo "${_C}[dbg]${_N} $*" || true; }

run() {
  if ((DRY_RUN)); then
    ((VERBOSE)) && printf '%s[dry-run]%s %s\n' "$_C" "$_N" "$(printf '%q ' "$@")" >&2
    return 0
  fi
  verbose "run: $(printf '%q ' "$@")"
  "$@"
}

#-- Traps & cleaning ------------------

PASSPHRASE=""

cleanup() {
  if [[ -n "${PASSPHRASE-}" ]]; then
    PASSPHRASE="" # clear var
    unset PASSPHRASE || true
  fi
}

err_trap() {
  local ec=$?
  fail "Abort (exit $ec)."
  cleanup
  exit "$ec"
}
trap cleanup EXIT
trap err_trap ERR

#-- Helpers ---------------------------
usage() {
  cat <<'EOF'
  wsx.sh <command> [options]

  Commands:
  mount         Mount all defined volumes (skip mounted)
  unmount       Unmount all defined mount points (VeraCrypt)
  status        Show mount-status for all mount points
  enter         Mount depending on need/status, cd to workdir, exec: $SHELL (wezterm/vty)


  Flags (Global):
  --dry-run     Show actions (without change/execution)
  --verbose     Show even more logs (debug)
  --no-color    Deactivate colors
  --no-emoji    Deactivate emoji/icons (nerdfont required if active)

  Flags (for `enter`):
  --workdir <path>    Change directory (cd) to (default: /media/veracrypt2)
  --signal-file <p>   Create file if successful mount (default: non ? or?)

  Example:
  wsx.sh mount
  wsx.sh unmount
  wsx.sh status
  wsx.sh enter --workdir /media/veracrypt2 --signal-file /tmp/mount_success.signal
EOF
}

is_mounted() {
  local mp="$1"

  if veracrypt -t -l 2>/dev/null | awk 'NF{print $NF}' | grep -Fxq -- "$mp"; then
    return 0
  fi

  if command -v mountpoint >/dev/null 2>&1; then
    mountpoint -q -- "$mp"
  else
    findmnt -rno TARGET -- "$mp" &>/dev/null 2>&1
  fi
}

preflight() {
  command -v veracrypt >/dev/null 2>&1 || {
    fail "Veracrypt is missing from \$PATH"
    exit 127
  }

  command -v sudo >/dev/null 2>&1 || {
    fail "sudo missing"
    exit 127
  }

  if ((${#PARTITIONS[@]} != ${#MOUNT_POINTS[@]})); then
    fail "PARTITIONS and MOUNT_POINTS has different length."
    exit 2
  fi

  if ! sudo -n true 2>/dev/null; then
    log "sudo authentication required."
    run sudo -v
  fi
}

ensure_mount_dir() {
  local mp="$1"
  if [[ ! -d "$mp" ]]; then
    run sudo install -d -m 775 -- "$mp"
  fi
}

read_passphrase_once() {
  ((DRY_RUN)) && {
    log "Would prompt for veracrypt passphrase"
    return 0
  }

  if [[ -n "${PASSPHRASE-}" ]]; then return 0; fi
  local t="${PW_TIMEOUT:-30}"
  printf "Enter veracrypt passphrase: (timeout %ss) " "$t" >&2

  # -s = silent , -t = timeout ,
  if ! IFS= read -r -s -t "$t" PASSPHRASE </dev/tty; then
    printf '\n' >&2
    fail "No passphrase entered within ${t}s."
    return 1
  fi

  printf '\n' >&2
  [[ -n "$PASSPHRASE" ]] || {
    fail "Empty passphrase - aborting..."
    return 1
  }
}

vc_mount() {
  local part="$1" mp="$2"
  local cmd=(sudo veracrypt --text --non-interactive --stdin --fs-options="$FSOPTS" --keyfiles= --protect-hidden=no --mount "$part" "$mp")

  if command -v timeout >/dev/null 2>&1; then
    # fg dont disturb sudo
    cmd=(timeout --foreground "${VC_TIMEOUT}s" "${cmd[@]}")
  else
    warn "timeout(1) missing - going without timeout (if err, press CTRL+C)"
  fi

  if ! printf "%s" "$PASSPHRASE" | "${cmd[@]}"; then
    local ec=$?
    if [[ $ec -eq 124 ]]; then
      fail "VeraCrypt timeout after ${VC_TIMEOUT}s: $part"
    else
      fail "Mount unsuccessful (exit $ec): $part"
    fi
    return 1
  fi
}

wait_for_dir() {
  local dir="$1" s="${2:-15}"
  while ((s-- > 0)); do
    [[ -d "$dir" ]] && return 0
    sleep 1
  done
  return 1
}

signal_file_path() {
  printf '%s\n' "${WSX_SIGNAL_FILE:-$DEFAULT_SIGNAL_FILE}"
}

#-- Main ------------------------------
mount_all() {
  preflight

  local all_ok=1
  for mp in "${MOUNT_POINTS[@]}"; do
    if ! is_mounted "$mp"; then
      all_ok=0
      break
    fi
  done

  if ((all_ok)); then
    warn "All mount points already mounted."
    return 0
  fi

  if ! read_passphrase_once; then
    return 1
  fi

  local i part mp
  for i in "${!PARTITIONS[@]}"; do
    part="${PARTITIONS[$i]}"
    mp="${MOUNT_POINTS[$i]}"

    if is_mounted "$mp"; then
      warn "Already mounted: $part @ $mp"
      continue
    fi

    ensure_mount_dir "$mp"
    log "Mounting $part -> $mp ..."
    if ((DRY_RUN)); then
      log "Would run: veracrypt --text --non-interactive --stdin --fs-options='$FSOPTS' --mount '$part' '$mp'"
    else
      if ! vc_mount "$part" "$mp"; then
        return 1
      fi
    fi

    if is_mounted "$mp"; then
      success "$part mounted at $mp"
    else
      fail "$part: failed during attempt to mount."
      exit 1
    fi
  done
}

# Unmount all containers/volumes
unmount_all() {
  preflight
  local all_success=1
  local any_busy=0

  for mp in "${MOUNT_POINTS[@]}"; do
    if is_mounted "$mp"; then
      log "Dismount: $mp ..."
      # check if VC-volume
      if sudo veracrypt -t -l | grep -Fq -- "$mp"; then
        if run sudo veracrypt --text --dismount "$mp" --non-interactive; then
          success "Unmounted: $mp"
        else
          warn "Could not unmount (busy busy busy?): $mp"
          all_success=0
          any_busy=1
        fi
      else
        warn "$mp dont seem to  be a VC-volume."
        all_success=0
      fi
    else
      warn "$mp: already unmounted."
    fi
  done

  if ((all_success)); then
    success "All volumes unmounted."
    local sf
    sf="$DEFAULT_SIGNAL_FILE"
    [[ -n "$sf" ]] && run rm -f -- "$sf" && verbose "signal file: $sf removed."
  else
    if ((any_busy)); then
      warn "Some volumes could not be unmounted. Tip of the day: lsof +D /media/veracryptX"
    fi
    return 1
  fi
}

# Get status for volumes
status_all() {
  local i part mp
  for i in "${!MOUNT_POINTS[@]}"; do
    part="${PARTITIONS[$i]}"
    mp="${MOUNT_POINTS[$i]}"
    if is_mounted "$mp"; then
      echoe "${_G}mounted${_N} $mp (from $part)"
    else
      echoe "${_Y}not mounted${_N} $mp (from $part)"
    fi
  done
}

# For WezTerm Terminal
enter_mode() {
  local workdir="$DEFAULT_WORKDIR"
  local signal_file="$DEFAULT_SIGNAL_FILE"
  local EXEC_SHELL=0

  # parse "enter-mode" specific flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --workdir)
      workdir="$2"
      shift 2
      ;;
    --signal-file)
      signal_file="$2"
      shift 2
      ;;
    --exec-shell)
      EXEC_SHELL=1
      shift
      ;;
    *)
      fail "Unknown flag for 'enter': $1"
      exit 2
      ;;
    esac
  done

  # check missing mounts
  local need_mount=0
  for mp in "${MOUNT_POINTS[@]}"; do
    if ! is_mounted "$mp"; then
      need_mount=1
      break
    fi
  done

  if ((need_mount)); then
    exec 9>"$LOCK_FILE"
    if flock -n 9; then
      preflight
      if ! mount_all; then
        warn "Mount failed."
      else

        if [[ -n "$signal_file" ]]; then
          if ((DRY_RUN)); then
            log "Would touch signal file: $signal_file"
          else
            run touch -- "$signal_file"
            verbose "signal: $signal_file created."
          fi
        fi
      fi
    else
      warn "Mount is ongoing in another process. "
      wait_for_dir "$workdir" 30 || warn "workdir missing: $workdir"
    fi
  fi

  # navigate
  if ! wait_for_dir "$workdir" 5; then
    warn "Workdir missing: $workdir - redirect to \$HOME."
    workdir="$HOME"
  fi

  cd -- "$workdir" || {
    fail "Could not cd into: $workdir"
    exit1
  }

  log "Opening shell in: $workdir"
  if ((EXEC_SHELL)); then
    exec "${SHELL:-/bin/bash}"
  fi

}

#-- CLI -------------------------------
#subcmd is first non-flag arg
cmd=""
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  --dry-run) DRY_RUN=1 ;;
  --verbose) VERBOSE=1 ;;
  --no-color) COLOR=0 ;;
  --no-emoji) EMOJI=0 ;;
  mount | unmount | status | enter)
    cmd="$1"
    shift
    break
    ;;
  *)
    fail "Unknown flag: $1"
    exit 2
    ;;
  esac
  shift
done

[[ -n "$cmd" ]] || {
  usage
  exit 2
}
case "$cmd" in
mount) mount_all ;;
unmount) unmount_all ;;
status) status_all ;;
enter) enter_mode "$@" ;;
esac
