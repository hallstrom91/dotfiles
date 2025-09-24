#!/usr/bin/env bash
# mountext.sh - mount veracrypt containers/partitions/drives on pre-dest volume.
# wsx.sh - workspace external mount, dismount, and custom.
# Idempotent and clear error msgs.

set -Eeuo pipefail
IFS=$'\n\t'
#-- Config / Global -------------------

# Device/Parition (left) -> Mount points (right)
PARTITIONS=(
  "/dev/sda1" # external
  "/dev/sda2" # external
)

MOUNT_POINTS=(
  "/media/veracrypt1"
  "/media/veracrypt2"
)

# Defaults
DEFAULT_WSDIR="/media/veracrypt2"
DEFAULT_SIGNAL_FILE="/tmp/mount_success.signal" # or ""

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
trap err trap ERR

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
  if command -v mountpoint >/dev/null 2>&1; then
    mountpoint -q -- "$mp"
  else
    findmnt -rno TARGET -- "$mp" &>/dev/null
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
    run sudo isntall -d -m 775 -- "$mp"
  fi
}

read_passphrase_once() {
  ((DRY_RUN)) && {
    log "Would prompt for veracrypt passphrase"
    return 0
  }
  if [[ -n "${PASSPHRASE-}" ]]; then return 0; fi
  printf "Enter veracrypt passphrase: " >&2
  IFS= read -r -s PASSPHRASE </dev/tty
  printf '\n' >&2
  [[ -n "$PASSPHRASE" ]] || {
    fail "Empty passphrase - aborting..."
    exit 1
  }
}

#-- CLI -------------------------------

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
  *)
    fail "Unknown flag: $1"
    exit 2
    ;;
  esac
  shift
done

#-- Main ------------------------------
mount_all() {
  preflight

  all_ok=1
  for mp in "${MOUNT_POINTS[@]}"; do
    if ! is_mounted "$mp"; then
      all_ok=0
      break
    fi
  done

  if ((all_ok)); then
    warn "All mount points already mounted."
    exit 0
  fi

  read_passphrase_once

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
      # send passphrase thru FD 3, dont mix with future stdin
      if veracrypt --text --non-interactive --stdin-fd=3 --fs-options="$FSOPTS" --mount "$part" "$mp" 3<<<"$PASSPHRASE"; then
        : else fail "Mount failed: $part"
        exit 1
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
          success "Dismounted: $mp"
        else
          warn "Could not dismount (busy busy busy?): $mp"
          all_success=0
          any_busy=1
        fi
      else
        warn "$mp dont seem to  be a VC-volume."
        all_success=0
      fi
    else
      warn "$mp: already dismounted."
    fi
  done

  if ((all_success)); then
    success "All volumes dismounted."
  else
    if ((any_busy)); then
      warn "Some volumes could not be dismounted. Tip of the day: lsof +D /media/veracryptX"
    fi
    return 1
  fi
}

# Get status for volumes
status_all() {}

# For WezTerm Terminal
enter_mode() {}

# read passphrase from TTY
# if ((DRY_RUN)); then
#   log "Would prompt for VeraCrypt passphrase on TTY"
# else
#   printf "Enter veracrypt passphrase: " >&2
#   IFS= read -r -s PASSPHRASE </dev/tty
#   printf '\n' >&2
#   if [[ -z "$PASSPHRASE" ]]; then
#     fail "Empty passphrase - operation canceled."
#     exit 1
#   fi
# fi
#
# for i in "${!PARTITIONS[@]}"; do
#   part="${PARTITIONS[$i]}"
#   mp="${MOUNT_POINTS[$i]}"
#
#   if is_mounted "$mp"; then
#     warn "Already mounted: $part @ $mp"
#     continue
#   fi
#
#   ensure_mount_dir "$mp"
#
#   log "Mounting $part -> $mp ..."
#   if ((DRY_RUN)); then
#     log "Would run: veracrypt --text --non-interactive --stdin --fs-options='$FSOPTS' --mount '$part' '$mp'"
#   else
#     # send passphrase thru FD 3, dont mix with future stdin
#     if veracrypt --text --non-interactive --stdin-fd=3 --fs-options="$FSOPTS" --mount "$part" "$mp" 3<<<"$PASSPHRASE"; then
#       : else fail "Mount failed: $part"
#       exit 1
#     fi
#   fi
#
#   # Verify
#   if is_mounted "$mp"; then
#     success "$part mounted @ $mp"
#   else
#     fail "$part: not mounted after attempt."
#     exit 1
#   fi
# done
#
# success "Done, Done, Done!"
# exit
