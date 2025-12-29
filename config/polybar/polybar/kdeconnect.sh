#!/usr/bin/env bash

# Inspired by: https://github.com/haideralipunjabi/polybar-kdeconnect/blob/master/polybar-kdeconnect.sh

# KDE Connect integration for Polybar
# Idempotent autostart of kdeconnectd
# Polybar integration - custom module statusbar
# Rofi/dmenu integration - action selection in menu

### ====> ENV: Required (externally configurable) <==== ###

# polybar font & icons (requires nerdfont)
FONT_ICON="${FONT_ICON:-4}" # size for icons
FONT_TEXT="${FONT_TEXT:-1}" # size for text
ICON_PHONE="󰄜"
ICON_DISCON="󰥍"
SEP="${SEP:- }"

# Logging
KDE_STATE_DIR=${KDE_STATE_DIR:-$HOME/state/polybar}
KDE_LOG_FILE="$KDE_STATE_DIR/kdeconnect-script.log}"

# ====> ENV: state <==== #

_verbose=0 # enable via --verbose

### ====> Utilities <==== ####

# check command exists in PATH; usage: have <cmd>
have() { command -v "$1" >/dev/null 2>&1; }

_state_file() {
	local base dir
	base="$KDE_STATE_DIR/kdeconnect-script.state"
	dir="${base%/*}"
	[[ -d $dir ]] || mkdir -p "$dir" 2>/dev/null || true
	printf '%s' "$base"
}

# write timestamped (--verbose)
_log() {
	((_verbose)) || return 0
	local ts
	printf -v ts '[%(%F %T)T]' -1
	local dir="${KDE_LOG_FILE%/*}"
	[[ -d $dir ]] || mkdir -p "$dir" 2>/dev/null || true
	printf '%s%s\n' "$ts" "$*" >>"$KDE_LOG_FILE"
}

# _run : execute command; preserv $rc, log (--verbose)
_run() {
	if ((_verbose)); then
		_log "\$ $*"
		"$@" 2>>"$LOG_FILE"
		local rc=$?
		_log "↳ exit=$rc"
		return "$rc"
	else
		"$@" 2>/dev/null
		return "$?"
	fi
}

# _run_out : execute command, return stdout and preserve $rc
# _run_out() {
# 	local __outvar="$1"
# 	shift
# 	local out rc
# 	if ((_verbose)); then
# 		_log "\$ $*"
# 		out="$("@" 2>>"$LOG_FILE")"
# 		rc=$?
# 		_log "↳ exit=$rc"
# 	else
# 		out="$("$@" 2>/dev/null)"
# 		rc=$?
# 	fi
# 	printf -v "$__outvar" '%s' "$out"
# 	return "$rc"
# }

# _log_detect : create log if backend value changes
_log_detect() {
	local key="$1" val="$2" file tmp old k v
	file="$(_state_file)"
	tmp="${file}.tmp"

	# read old value for key
	if [[ -r $file ]]; then
		while IFS='=' read -r k v; do
			[[ $k == "$key" ]] || continue
			old=$v
			break
		done <"$file"
	fi

	# log change
	if [[ ${old-} != "$val" ]]; then
		_log "$key changed: ${old:-<none>} -> $val"
		# rewrite file atomic
		: >"$tmp"
		if [[ -r $file ]]; then
			while IFS='=' read -r k v; do
				[[ $k == "$key" ]] && continue
				printf '%s=%s\n' "$k" "$v" >>"$tmp"
			done <"$file"
		fi
		printf '%s=%s\n' "$key" "$val" >>"$tmp"
		mv -f -- "$tmp" "$file"
	fi
}

# Non-blocking user feedback (fail safe); usage: _notify <title> <body>
_notify() {
	local title="$1" body="$2"
	if have notify-send; then
		notify-send -a "kdeconnect.sh" "$title" "$body" 2>/dev/null &
		# disown || true
	elif have kdialog; then
		kdialog --title "$title" --passivepopup "$body" 3 2/dev/null &
		# disown || true
	fi
	return 0
}

### ====> Parse: simple flags <==== ####

# Find --verbose flag, if any
for _arg in "$@"; do
	case $_arg in
	--verbose) _verbose=1 ;;
	esac
done

# log poll (spam...)
if ((_verbose)); then
	if [[ ${1-} == "--menu" ]]; then
		_log "=== start (pid $$, user $USER, mode=menu) ==="
	## NOTE: comment out next (2) line to reduce spam from status polling
	else
		_log "=== start (pid $$, user $USER, mode=status) ==="
	fi
fi

#### ====> Backend Discovery: gdbus -> qdbus -> cli <==== ###
#
## _backend - global choice; value set by _select_backend
#_backend=none
#
## Primary) gdbus -> response from daemon via D-Bus ?
#_kdeconnectd_up_gdbus() {
#	# requires qdbus; org.kde.kdeconnect must respond on Peer.Ping
#	have gdbus || return 2
#	_run gdbus call \
#		--session \
#		--dest org.kde.kdeconnect \
#		--object-path /modules \
#		--method org.freedesktop.DBus.Peer.Ping
#	# check rc ? response is only ()
#}
#
## Secondary)
#_kdeconnectd_up_qdbus() {
#	have qdbus || return 2
#	# qdbus: service / path / method
#	_run qdbus org.kde.kdeconnect /modules org.freedesktop.DBus.Peer.Ping
#	# no res, check rc
#}
#
## Fallback)
#_kdeconnectd_up_cli() {
#	have kdeconnect-cli || return 2
#	# list devices; exit 0 if daemon is reachable (even if zero devices)
#	_run kdeconnect-cli --list-devices
#}
#
## select candidates -> use FORCE_BACKEND if set
#_backend_candidates() {
#	# FORCE_BACKEND=dbus|qdbus|cli|none
#	local f="${FORCE_BACKEND:-}"
#	if [[ $f == dbus || $f == gdbus ]]; then
#		printf '%s\n' gdbus
#		return 0
#	elif [[ $f == qdbus ]]; then
#		printf '%s\n' qdbus
#		return 0
#	elif [[ $f == cli || $f == kdeconnect-cli ]]; then
#		printf '%s\n' cli
#		return 0
#	elif [[ $f == none ]]; then
#		printf '%s\n' none
#		return 0
#	fi
#
#	# default order
#	printf '%s\n' gdbus qdbus cli
#}
#
## read stored state value and use; if empty/different, use current
#_current_backend() {
#	local file k v
#	file="$(_state_file)"
#	[[ -r $file ]] || {
#		printf '%s' "$_backend"
#		return 0
#	}
#	while IFS='=' read -r k v; do
#		[[ $k == backend ]] || continue
#		printf '%s' "$v"
#		return 0
#	done <"$file"
#	printf '%s' "$_backend"
#}
#
## select first working candidate; log change (--verbose)
#_select_backend() {
#	local cand
#	cand=$(_backend_candidates)
#
#	for c in $cand; do
#		case $c in
#		gdbus)
#			if _kdeconnectd_up_gdbus; then
#				_backend=gdbus
#				break
#			fi
#			;;
#		qdbus)
#			if _kdeconnectd_up_qdbus; then
#				_backend=qdbus
#				break
#			fi
#			;;
#		cli)
#			if _kdeconnectd_up_cli; then
#				_backend=cli
#				break
#			fi
#			;;
#		none)
#			_backend=none
#			break
#			;;
#		esac
#	done
#
#	# log change to state-file + verbose log
#	_log_detect backend "$_backend"
#	((_verbose)) && _log "backend selected=$_backend"
#
#	# return 0 if value is "none"
#	[[ $_backend != none ]]
#}
#
## auto find and select value for backend
#_select_backend || true
