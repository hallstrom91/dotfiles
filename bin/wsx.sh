#!/usr/bin/env bash
# wsx.sh - mount,unmount,status,enter for VeraCrypt workspaces.

set -Euo pipefail
IFS=$'\n\t'

#-- Config / Global -------------------

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
VC_TIMEOUT="${VC_TIMEOUT:-30}" # 30s
PW_TIMEOUT="${PW_TIMEOUT:-60}" # 1min
DEFAULT_WORKDIR="/media/veracrypt2"

# runtime dir resolution
uid="$(id -u)"
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$uid}"
[[ -d "$runtime_dir" && -w "$runtime_dir" ]] || runtime_dir="/tmp/"

DEFAULT_LOCK_FILE="$runtime_dir/wsx.$uid.mount.lock"
DEFAULT_SIGNAL_FILE="$runtime_dir/wsx.$uid.mount.signal"

signal_file_path() {
	printf '%s\n' "${WSX_SIGNAL_FILE:-$DEFAULT_SIGNAL_FILE}"
}

lock_file_path() {
	printf "%s\n" "${WSX_LOCK_FILE:-$DEFAULT_LOCK_FILE}"
}

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

# helper - is mounted ?
is_mounted() {
	local mp="$1"

	if veracrypt -t -l 2>/dev/null | awk 'NF{print $NF}' | grep -Fxq -- "$mp"; then
		return 0
	fi

	if command -v mountpoint >/dev/null 2>&1; then
		mountpoint -q -- "$mp"
	else
		findmnt -rno TARGET -- "$mp" >/dev/null 2>&1
	fi
}

# helper - preflight check
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

# helper - ensure mounted disk and dir is accessable
ensure_mount_dir() {
	local mp="$1"
	if [[ ! -d "$mp" ]]; then
		run sudo install -d -m 775 -- "$mp"
	fi
}

# helper - read passphrase
read_passphrase_once() {
	((DRY_RUN)) && {
		log "Would prompt for veracrypt passphrase"
		return 0
	}

	if [[ -n "${PASSPHRASE-}" ]]; then return 0; fi
	local t="${PW_TIMEOUT}"
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

# helper - VC mount
vc_mount() {
	local part="$1" mp="$2"
	local vc_argv=(sudo veracrypt --text --non-interactive --stdin --fs-options="$FSOPTS" --keyfiles= --protect-hidden=no --mount "$part" "$mp")

	if command -v timeout >/dev/null 2>&1; then
		vc_argv=(timeout --foreground "${VC_TIMEOUT}s" "${vc_argv[@]}")
	else
		warn "timeout(1) missing - going without timeout (if err, press CTRL+C)"
	fi

	if ! printf "%s" "$PASSPHRASE" | "${vc_argv[@]}"; then
		local ec=$?
		if [[ $ec -eq 124 ]]; then
			fail "VeraCrypt timeout after ${VC_TIMEOUT}s: $part"
		else
			fail "Mount unsuccessful (exit $ec): $part"
		fi
		return 1
	fi
}
# wait for mounted volume and dir
wait_for_dir() {
	local dir="$1" s="${2:-15}"
	while ((s-- > 0)); do
		[[ -d "$dir" ]] && return 0
		sleep 1
	done
	return 1
}

require_mount_for_dir() {
	local dir="$1"
	local mp
	for mp in "${MOUNT_POINTS[@]}"; do
		if [[ "$dir" == "$mp" || "$dir" == "$mp/"* ]]; then
			if is_mounted "$mp"; then
				return 0
			else
				return 1
			fi
		fi
	done
	# dir is not tied to VC-MP -> no req
	return 0
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
		sf="$(signal_file_path)"
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
	local signal_file="" # CLI signal_file set ?
	# local signal_file="$DEFAULT_SIGNAL_FILE"

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
		exec 9>"$(lock_file_path)"
		# exec 9>"$LOCK_FILE"
		if flock -n 9; then
			preflight
			if ! mount_all; then
				warn "Mount failed."
			else

				if [[ -n "$signal_file" ]]; then
					# CLI > env > default
					local effective_signal="${signal_file:-$(signal_file_path)}"
					if ((DRY_RUN)); then
						log "Would touch signal file: $effective_signal"
					else
						run touch -- "$effective_signal"
						verbose "signal: $effective_signal created."
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
	elif ! require_mount_for_dir "$workdir"; then
		warn "Workdir is on an unmounted volume: $workdir - redirect to \$HOME"
		workdir="$HOME"
	fi

	cd -- "$workdir" || {
		fail "Could not cd into: $workdir"
		exit 1
	}

	log "Opening shell in: $workdir"
	if ((EXEC_SHELL)); then
		exec "${SHELL:-/bin/bash}"
	fi

}

#-- CLI -------------------------------
#cmd is first non-flag arg
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
