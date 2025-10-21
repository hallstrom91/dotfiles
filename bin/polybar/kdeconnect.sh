#!/usr/bin/env bash

# KDE Connect integration for Polybar
# Inspired by: https://github.com/haideralipunjabi/polybar-kdeconnect/blob/master/polybar-kdeconnect.sh
# Idempotent autostart of kdeconnectd
# Rofi/dmenu-menu with standard actions
# Polybar font and icon-handling for module statusbar

# ====> Settings | ENV | Policy <==== #
# set -Euo pipefail # without -e (e.g., -Eeuo) ?

# polybar font & icons (requires nerdfont)
FONT_ICON="${FONT_ICON:-4}"
FONT_TEXT="${FONT_TEXT:-1}"
ICON_PHONE="󰄜"
ICON_DISCON="󰥍"
SEP=" "

# device preference
DEV_PREFER_NAME="${DEV_PREFER_NAME:-}" # substring name
DEV_PREFER_ID="${DEV_PREFER_ID:-}"     # exact id

FORCE_BACKEND="${FORCE_BACKEND:-}" # backend override for testing: dbus|cli|none

_VERBOSE=0 # logging (enabled with --verbose flag)
LOG_FILE="${LOG_FILE:-$HOME/.cache/kdeconnect-script-polybar.log}"
# CACHE_FILE="${CACHE_FILE:-$HOME/.cache/kdeconnect-script-polybar.state}" # better here ?

# ====> Utilities <==== #

# check cmd exists
have() { command -v "$1" >/dev/null 2>&1; }

# _log: write timestamped line (if --verbose flag)
_log() {
	((_VERBOSE)) || return 0
	mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
	printf '[%(%F %T)T] %s\n' -1 "$*" >>"$LOG_FILE"
}

# _run : execute command, return $rc of finished/failed process
# VERBOSE: log command + stderr
_run() {
	if ((_VERBOSE)); then
		_log "\$ $*"
		"$@" 2>>"$LOG_FILE"
		local rc=$?
		_log "↳ exit=$rc"
		return $rc
	else
		"$@" 2>/dev/null
		return $? # make rc explicit
	fi
}

# _state_file : change-detect logging for backend discovery (qdbus/cli)
_state_file() {
	local base="${XDG_CACHE_HOME:-$HOME/.cache}/kdeconnect-script-polybar.state"
	mkdir -p "$(dirname "$base")" 2>/dev/null || true
	printf '%s' "$base"
}

# _log_detect : create log if backend value changes
_log_detect() {
	local key="$1" val="$2" file old
	file="$(_state_file)"
	old="$(grep -E "^${key}=" "$file" 2>/dev/null | sed -E "s/^${key}=//")"
	if [[ "$old" != "$val" ]]; then
		_log "$key changed: ${old:-<none>} -> $val"
		{
			grep -Ev "^${key}=" "$file" 2>/dev/null
			echo "${key}=$val"
		} >"${file}.tmp" 2>/dev/null
		mv -f "${file}.tmp" "$file"
	fi
}

# _pick_backend_for : log-helper dbus|cli|none as backend
# _pick_backend_for() {
# 	local what="$1" dev="${2:-}"
# 	if have_qdbus && _kdeconnectd_up; then
# 		_log "[backend:$what] dbus (dev=${dev:-n/a})"
# 		printf '%s' dbus
# 	elif have_cli; then
# 		_log "[backend:$what] cli (dev=${dev:-n/a})"
# 		printf '%s' cli
# 	else
# 		_log "[backend:$what] none (dev=${dev:-n/a})"
# 		printf '%s' none
# 	fi
# }

# _notify : Non-blocking user feedback
# never fail outward; dont let notification effect $rc upwards.
_notify() {
	if have notify-send; then
		notify-send -a "kdeconnect.sh" "$1" "$2" 2>/dev/null 2>&1 &
		disown || true
	elif have kdialog; then
		kdialog --title "$1" --passivepopup "$2" 3 2/dev/null 2>&1 &
		disown || true
	fi
	return 0
}

# ====> Parse: simple flags <==== #

# Find --verbose flag, if any
for _arg in "$@"; do
	case "${_arg}" in
	--verbose) _VERBOSE=1 ;;
	esac
done

if ((_VERBOSE)); then
	if [[ ${1-} == "--menu" ]]; then
		_log "=== start (pid $$, user $USER, mode=menu) ==="
	## NOTE: comment out next (2) line to reduce spam from status polling
	else
		_log "=== start (pid $$, user $USER, mode=status) ==="
	fi
fi

# ====> Discovery: qdbus,cli + wrappers <==== #

#  D1) QDBUS discovery

_qdbus_ok() {
	local -a cmd=("$@")
	"${cmd[@]}" --version >/dev/null 2>&1 ||
		"${cmd[@]}" org.freedesktop.DBus / org.freedesktop.DBus.ListNames >/dev/null 2>&1
}

QDBUS_CMD=()

# prefer PATH first
for cand in qdbus6 qdbus-qt5 qdbus; do
	if candpath=$(command -v "$cand" 2>/dev/null); then
		if _qdbus_ok "$candpath"; then
			QDBUS_CMD=("$candpath")
			_log_detect QDBUS "${QDBUS_CMD[*]}"
			break
		fi
	fi
done

# if no PATH?; try known sys-paths
if ((${#QDBUS_CMD[@]} == 0)); then
	for cand in \
		"/usr/lib/qt6/bin/qdbus6" \
		"/usr/lib/x86_64-linux-gnu/qt5/bin/qdbus" \
		"/usr/lib/qt5/bin/qdbus"; do
		[[ -x "$cand" ]] || continue
		if _qdbus_ok "$cand"; then
			QDBUS_CMD=("$cand")
			_log_detect QDBUS_CMD "${QDBUS_CMD[*]}"
			break
		fi
	done
fi

# last restort if no PATH/sys-path; qtchooser (Qt6 -> Qt5)
if ((${#QDBUS_CMD[@]} == 0)) && have qtchooser; then
	if _qdbus_ok qtchooser -run-tool=qdbus6 -qt=qt6; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus6 -qt=qt6)
	elif _qdbus_ok qtchooser -run-tool=qdbus -qt=qt5; then
		# if _qdbus_ok qtchooser -run-tool=qdbus -qt=qt5; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus -qt=qt5)
	fi
	((${#QDBUS_CMD[@]})) && _log_detect QDBUS "${QDBUS_CMD[*]} via qtchooser"
fi

have_qdbus() { ((${#QDBUS_CMD[@]} > 0)); }

# _qdbus: log full cmd-line and exit code
_qdbus() {
	if ((_VERBOSE)); then
		_log "\$ ${QDBUS_CMD[*]} ${QDBUS_OPTS[*]-} $*"
		"${QDBUS_CMD[@]}" ${QDBUS_OPTS+"${QDBUS_OPTS[@]}"} "$@" 2>>"$LOG_FILE"

		local rc=$?
		_log "↳ qdbus exit=$rc"
		return $rc
	else
		"${QDBUS_CMD[@]}" ${QDBUS_OPTS+"${QDBUS_OPTS[@]}"} "$@" 2>/dev/null
		return $?
	fi
}

# D2) CLI discovery
KDE_CLI_CMD=()

if have kdeconnect-cli; then
	KDE_CLI_CMD=(kdeconnect-cli)
	_log_detect CLI "${KDE_CLI_CMD[*]} detected"
fi

have_cli() { ((${#KDE_CLI_CMD[@]} > 0)); }

_cli() {
	if ((_VERBOSE)); then
		_log "\$ ${KDE_CLI_CMD[*]} $*"
		"${KDE_CLI_CMD[@]}" "$@" 2>>"$LOG_FILE"
		local rc=$?
		_log "↳ cli exit=$rc"
		return $rc
	else
		"${KDE_CLI_CMD[@]}" "$@" 2>/dev/null
		return $?
	fi
}

# ====> Backend Selector & daemon ctrl <==== #

# _kdeconnectd_up: check DBus name
_kdeconnectd_up() {
	have_qdbus || return 1
	_qdbus org.freedesktop.DBus / org.freedesktop.DBus.ListNames 2>/dev/null |
		grep -q 'org.kde.kdeconnect'
}

# _start_kdconnectd: start daemon from known locations
_start_kdeconnectd() {
	local p
	for p in \
		/usr/lib/x86_64-linux-gnu/libexec/kdeconnectd \
		/usr/libexec/kdeconnectd \
		/usr/lib/kdeconnectd; do
		if [[ -x "$p" ]]; then
			_log "starting kde daemon: $p"
			"$p" >/dev/null 2>&1 &
			disown
			sleep 0.3
			return 0
		fi
	done

	# Last resort: kdeconnect-indicator starts daemon
	if have kdeconnect-indicator; then
		_log "starting kdeconnect-indicator (fallback daemon starter)"
		kdeconnect-indicator >/dev/null 2>&1 &
		disown
		sleep 0.5
		return 0
	fi
	_log "failed to start daemon (no binary found); defaulting to 'kdeconnect-cli' (slower)"
	return 1
}

_pick_pick_backend_for() {
	local what="$1" dev="${2:-}" choice
	if [[ -n $FORCE_BACKEND ]]; then
		case "$FORCE_BACKEND" in
		dbus | cli | none) choice=$FORCE_BACKEND ;;
		*) choice=none ;;
		esac
	else
		if have_qdbus && _kdeconnectd_up; then
			choice=dbus
		elif have_cli; then
			choice=cli
		else
			choice=none
		fi
	fi
	_log "[backend:$what] $choice (dev=${dev:-n/a})"
	_log_detect BACKEND "$choice"
	printf '%s' "$choice"
}

# Autostart only if neither PID or bus name exists (in active processes)
if ! pgrep -x kdeconnectd >/dev/null 2>&1 && ! _kdeconnectd_up; then
	_start_kdeconnectd || true
fi

# ====> KDE Helpers: service|path|interface|wait|poll <==== #

_qdbus_list_ids() {
	_qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices 2>/dev/null |
		awk -F'"' '{for(i=2;i<=NF;i+=2) print $i}'
}

#  Dbus getters
_qdbus_dev_name() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.name 2>/dev/null; }
_qdbus_dev_reachable() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isReachable 2>/dev/null; }
_qdbus_dev_paired() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isTrusted 2>/dev/null; }
_qdbus_dev_battery() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/battery" org.kde.kdeconnect.device.battery.charge 2>/dev/null; }
_qdbus_dev_has_pairreq() { _qdbus --literal org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.hasPairingRequests 2>/dev/null; }

#  CLI reachability/paired (boolean via $rc)
_dev_is_reachable() { _run _cli --device "$1" --is-reachable; }
_dev_is_paired() { _run _cli --device "$1" --encryption-info; } # rc 0 = paired

# verbose device dump (debug around pair/unpair)
_dbg_dump_device() {
	((_VERBOSE)) || return 0
	local id="$1" name paired reach pairreq
	name="$(_qdbus_dev_name "$id" 2>/dev/null || printf '%s' "$id")"
	paired="$(_qdbus_dev_paired "$id" 2>/dev/null)"
	reach="$(_qdbus_dev_reachable "$id" 2>/dev/null)"
	pairreq="$(_qdbus_dev_has_pairreq "$id" 2>/dev/null)"
	_log "[dev:$id] name='$name' paired=$paired reachable=$reach pairingRequests=$pairreq"
}

## Extra helpers: Wait/poll and plugins

# _wait_until : "cmd ..." timeout_secs interval_secs
_wait_until() {
	local cmd="$1" timeout="${2:-1.5}" interval="${3:-0.1}"
	local start now
	start=$(printf '%(%s)T' -1)
	while :; do
		# run command silent; true => done
		eval "$cmd" >/dev/null 2>&1 && return 0
		now=$(printf '%(%s)T' -1)
		(($(awk -v n=$now -v s=$start "BEGIN{print (n-s)>=0}"))) || true
		# abort on timeout
		awk -v n="$now" -v s="$start" -v t="$timeout" 'BEGIN{exit ((n - s) > t ? 0 : 1)}' && return 1
		# wait - sleep (blocks stdin/out ?)
		sleep "$interval"
	done
}

# _has_plugin : only for dbus-backend
_has_plugin() {
	local id="$1" plugin="$2"
	[[ "$(_qdbus_has_plugin "$id" "$plugin" 2>/dev/null)" == "true" ]]
}

# ====> KDE Actions (dbus/cli) <==== #

# Dbus actions
_dbus_ping() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/ping" org.kde.kdeconnect.device.ping.sendPing; }
_dbus_ring() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/findmyphone" org.kde.kdeconnect.device.findmyphone.ring; }
_dbus_share_url() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/share" org.kde.kdeconnect.device.share.shareUrl "file://$2"; }
_dbus_share_text() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/share" org.kde.kdeconnect.device.share.shareText "$2"; }
_dbus_sftp_mounted() { _qdbus --literal org.kde.kdeconnect "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.isMounted; }
_dbus_sftp_mount() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.mount; }
_dbus_sftp_browse() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.startBrowsing; }
_dbus_unpair() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.unpair; }
_dbus_pair() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.requestPair; }

# CLI actions; TODO: add missing actionssftp-* (??)
_cli_ping() { _cli --device "$1" --ping; }
_cli_ring() { _cli --device "$1" --ring; }
_cli_share_url() { _cli --device "$1" --share "file://$2"; }
_cli_share_text() { _cli --device "$1" --share-text "$2"; }
_cli_unpair() { _cli --device "$1" --unpair; }
_cli_pair() { _cli --device "$1" --pair; }

# ====> Action Wrappers <==== #

# _action_ping : send ping to device
_action_ping() {
	local id="$1" b rc
	b="$(_pick_backend_for ping "$id")"
	case "$b" in
	dbus) _run _dbus_ping "$id" ;;
	cli) _run _cli_ping "$id" ;;
	*)
		_log "No DBus/CLI available for 'ping' (device $id)"
		return 127
		;;
	esac
	rc=$?
	((_VERBOSE)) && _notify "KDE Connect" "Ping ${rc:+(rc=$rc)}"
	return $rc
}

# _action_ring : find device
_action_ring() {
	local id="$1" b rc
	b="$(_pick_backend_for ring "$id")"

	case "$b" in
	dbus) _run _dbus_ring "$id" ;;
	cli) _run _cli_ring "$id" ;;
	*)
		_log "No DBus/CLI available for 'ring' action (device $id)"
		return 127
		;;
	esac
	rc=$?
	if ((rc == 0)); then
		_notify "KDE Connect" "Find device: request sent"
	else
		_notify "KDE Connect" "Find device: request failed (rc=$rc)"
	fi
	return $rc
}

# _action_share_url : send file(path) for sharing or between browsers
_action_share_url() {
	local id="$1" fpath="$2" b rc
	b="$(_pick_backend_for share_url "$id")"

	# plugin check (dbus)
	if [[ "$b" == "dbus" ]] && ! _has_plugin "$id" "kdeconnect_share"; then
		_notify "KDE Connect" "Share not supported on this device"
		return 95
	fi

	case "$b" in
	dbus) _run _dbus_share_url "$id" "$fpath" ;;
	cli) _run _cli_share_url "$id" "$fpath" ;;
	*)
		_log "No DBus/CLI available for 'share-url' (device $id)"
		return 127
		;;
	esac
	rc=$?
	if ((rc == 0)); then
		_notify "KDE Connect" "Shared URL/file"
	else
		_notify "KDE Connect" "Share failed (rc=$rc)"
	fi
	return $rc
}

# _action_share_text : send clipboard or selected text
_action_share_text() {
	local id="$1" txt="$2" b rc
	b="$(_pick_backend_for share_text "$id")"

	# plugin check (dbus)
	if [[ "$b" == "dbus" ]] && ! _has_plugin "$id" "kdeconnect_share"; then
		_notify "KDE Connect" "Share text not supported on this device"
		return 95
	fi

	case "$b" in
	dbus) _run _dbus_share_text "$id" "$txt" ;;
	cli) _run _cli_share_text "$id" "$txt" ;;
	*)
		_log "No DBus/CLI available for 'share-text' (device $id)"
		return 127
		;;
	esac
	rc=$?
	if ((rc == 0)); then
		_notify "KDE Connect" "Shared text"
	else
		_notify "KDE Connect" "Share text failed (rc=$rc)"
	fi
	return $rc
}

# _action_unpair: close active (old instance of) connection between devices
_action_unpair() {
	local id="$1" b rc
	b="$(_pick_backend_for unpair "$id")"

	case "$b" in
	dbus) _run _dbus_unpair "$id" ;;
	cli) _run _cli_unpair "$id" ;;
	*)
		_log "No DBus/CLI available for 'unpair' (device $id) - makes no sense?! how did you get here?"
		return 127
		;;
	esac
	rc=$?

	# after control
	if ((rc == 0)); then
		if [[ "$b" == "dbus" ]]; then
			_wait_until "[[ \"$(_qdbus_dev_paired \""$id"\")\" != \"true\" ]]" 1.0 0.1 || true
		else
			_dev_is_paired "$id" || true
		fi
		_notify "KDE Connect" "Unpair requested"
	else
		_notify "KDE Connect" "Unpair failed (rc=$rc)"
	fi
	return $rc
	# old
	# if ((rc == 0)); then
	# 	_notify "KDE Connect" "unpair request sent to device $id"
	# else
	# 	_notify "KDE Connect" "unpair request failed (rc=$rc)"
	# fi
	# return $rc
}

# _action_pair: create new (instance of) active connection between devices
_action_pair() {
	local id="$1" b rc
	b="$(_pick_backend_for pair "$id")"

	case "$b" in
	dbus) _run _dbus_pair "$id" ;;
	cli) _run _cli_pair "$id" ;;
	*)
		_log "No DBus/CLI available for 'pair' (device $id)"
		return 127
		;;
	esac
	rc=$?

	if ((rc == 0)); then
		if [[ "$b" == "dbus" ]]; then
			if [[ "$(_qdbus_dev_has_pairreq "$id")" == "true" ]]; then
				_notify "KDE Connect" "Pair requested - approve on phone"
			else
				# await isPaired = true ?
				_wait_until "[[ \"$(_qdbus_dev_paired \""$id"\")\" != \"true\" ]]" 2.0 0.2 || true
				if [[ "$(_qdbus_dev_paired "$id")" == "true" ]]; then
					_notify "KDE Connect" "Paired successfully"
				else
					_notify "KDE Connect" "Pair request sent - awaiting approval"
				fi
			fi
		else
			_notify "KDE Connect" "Pair request sent (CLI)"
		fi
	else
		_notify "KDE Connect" "Pair failed (rc=$rc)"
	fi
	return $rc
	# old
	# if ((rc == 0)); then
	# 	_notify "KDE Connect" "Pair request sent to device $id"
	# else
	# 	_notify "KDE Connect" "Pair request failed (rc=$rc)"
	# fi
	# return $rc
}

############################################################################
##### REMOVE THIS: CONTINUE HERE WHEN LITTLE LELLE SLEEPS AGAIN TONIGHT ####
############################################################################

# _action_browse : mounted|mount|browse
_action_browse() {
	local id="$1" b rc i
	b="$(_pick_backend_for browse "$id")"

	case "$b" in
	dbus)
		if [[ "$(_dbus_sftp_mounted "$id" 2>/dev/null)" != "true" ]]; then
			_run _dbus_sftp_mount "$id" || true

			# TODO: below
			# avoid creating subprocess that takes up sys-resources
			# dont block stdin/out anywhere with sleep
			for ((i = 0; i < 10; i++)); do
				[[ "$(_dbus_sftp_mounted "$id" 2>/dev/null)" == "true" ]] && break
				usleep 100000 2>/dev/null || sleep 0.1
			done
		fi
		_run _dbus_sftp_browse "$id" || true
		;;
	cli)
		# no CLI browse: try generic URL handler
		_run xdg-open "kdeconnect://$id/" >/dev/null 2>&1 || _run kdeconnect-app &
		;;
	*)
		_log "No DBus/CLI available for 'mounted|mount|browse' action (device $id)"
		return 127
		;;
	esac
}

# ====> UI Helpers <==== #

# _pick_first_connected : select first connected / trusted device to display name+status
_pick_first_connected() {
	local id name
	while IFS= read -r id; do
		[[ -n "$id" ]] || continue
		name="$(_qdbus_dev_name "$id" || echo "$id")"

		# enforce preferences if provided
		if [[ -n "$DEV_PREFER_ID" && "$id" != "$DEV_PREFER_ID" ]]; then
			continue
		fi

		if [[ -n "$DEV_PREFER_NAME" && "$name" != *"$DEV_PREFER_NAME"* ]]; then
			continue
		fi

		[[ "$(_qdbus_dev_reachable "$id")" == "true" ]] || continue
		[[ "$(_qdbus_dev_paired "$id")" == "true" ]] || continue

		printf '%s|%s\n' "$id" "$name"
		return 0
	done < <(_qdbus_list_ids)
	return 1
}

# _choose : select/choose options in menu (rofi|dmenu)
_choose() {
	local prompt="${1:-Select}"
	if have rofi; then
		rofi -dmenu -i -p "$prompt"
	else
		dmenu -i -p "$prompt"
	fi
}

# _pick_file : pick file to share or url to browser (zenity|kdialog)
_pick_file() {
	if have zenity; then
		zenity --file-selection 2>/dev/null || true
	elif have kdialog; then
		kdialog --getopenfilename 2>/dev/null || true
	else
		# last resort
		echo ""
	fi
}

# _clip-text : send clipboard (wl-paste|xclip)
_clip_text() {
	# prefer wl-paste on wayland, otherwise xclip; quiet on failure.
	if [[ -n ${WAYLAND_DISPLAY-} ]] && have wl-paste; then
		wl-paste 2>/dev/null || true
	elif have xclip; then
		xclip -o -selection clipboard 2>/dev/null || true
	else
		echo ""
	fi
}

# _prompt_text : send free-text
_prompt_text() {
	local prompt="${1:-Text}"
	if have rofi; then
		# rofi -dmenu with empty input, single-line txt entry
		rofi -dmenu -p "$prompt" <<<""
	else
		dmenu -i -p "$prompt" <<<""
	fi
}

# ====> Status: Polybar <==== #

# printf helper
_print_device_line() {
	local icon="$1" name="${2:-}" battery="${3:-}" suffix="${4:-}"

	# E.g., icon-only "no device"
	if [[ -z $name ]]; then
		printf '%%{T%s}%s%%{T%s}%sno device\n' "$FONT_ICON" "$icon" "$FONT_TEXT" "$SEP"
		return
	fi

	if [[ -n $battery ]]; then
		printf '%%{T%s}%s%%{T%s}%s%s %s%%%s%s\n' "$FONT_ICON" "$icon" "$FONT_TEXT" "$SEP" "$name" "$battery" "$SEP" "${suffix:+ $suffix}"
	else
		printf '%%{T%s}%s%%{T%s}%s%s%s\n' "$FONT_ICON" "$icon" "$FONT_TEXT" "$SEP" "$name" "${suffix:+ $suffix}"
	fi
}

status_line() {
	local id name bat out

	if have_qdbus && _kdeconnectd_up; then
		# Opt 1) Preferred connected device (via qdbus)
		if out="$(_pick_first_connected)"; then
			id="${out%%|*}"
			name="${out#*|}"
			bat="$(_qdbus_dev_battery "$id" | grep -Eo '^[0-9]+' || true)"
			_print_device_line "$ICON_PHONE" "$name" "$bat"
			return 0
		fi

		# Opt 2) No connected device: show first known as offline (if any)
		id="$(_qdbus_list_ids | head -n1 || true)"
		if [[ -n "$id" ]]; then
			name="$(_qdbus_dev_name "$id" || echo "$id")"
			_print_device_line "$ICON_DISCON" "$name" "" "(offline)"
			return
		fi

		# Opt 3) No devices at all
		_print_device_line "$ICON_DISCON"
		return
	fi

	# Opt 4) Fallback using kdeconnect-cli: same logic as above, but not as fast.
	local cli_id
	cli_id="$(_run _cli --list-available --id-only | head -n1 || true)"

	if [[ -n "$cli_id" ]]; then
		name="$(_run _cli --device "$cli_id" --name || echo "$cli_id")"
		bat="$(_run _cli --device "$cli_id" --battery | grep -Eo '[0-9]+' | head -n1 || true)"
		_print_device_line "$ICON_PHONE" "$name" "$bat"
		return
	fi
	name="$(_run _cli --list-devices --name-only | head -n1 || true)"

	if [[ -n "$name" ]]; then
		_print_device_line "$ICON_DISCON" "$name" "" "(offline)"
	else
		_print_device_line "$ICON_DISCON"
	fi
}

###########################################
# Build list for menu
###########################################

# List Device Options; Output: DISPLAY|ID|PAIRED|REACHABLE
list_all_structured() {
	local id name paired reachable display
	if have_qdbus && _kdeconnectd_up; then
		while IFS= read -r id; do
			[[ -z "$id" ]] && continue
			name="$(_qdbus_dev_name "$id" || echo "$id")"

			[[ $(_qdbus_dev_paired "$id") == "true" ]] && paired=1 || paired=0
			[[ $(_qdbus_dev_reachable "$id") == "true" ]] && reachable=1 || reachable=0

			if ((paired == 1 && reachable == 1)); then
				display="Connected: ${name}"
			elif ((paired == 1)); then
				display="Paired: ${name}"
			else
				display="Available: ${name}"
			fi
			printf '%s|%s|%s|%s\n' "$display" "$id" "$paired" "$reachable"
		done < <(_qdbus_list_ids)
		return
	fi

	#  CLI fallback
	local -a ids names
	local i
	mapfile -t ids < <(_run _cli --list-devices --id-only || true)
	mapfile -t names < <(_run _cli --list-devices --name-only || true)

	for i in "${!ids[@]}"; do
		id="${ids[$i]}"
		name="${names[$i]:-$id}"
		_dev_is_paired "$id" && paired=1 || paired=0
		_dev_is_reachable "$id" && reachable=1 || reachable=0
		if ((paired == 1 && reachable == 1)); then
			display="Connected: ${name}"
		elif ((paired == 1)); then
			display="Paired: ${name}"
		else
			display="Available: ${name}"
		fi
		printf '%s|%s|%s|%s\n' "$display" "$id" "$paired" "$reachable"
	done
}

###############################
# Actions Menu
###############################

_device_actions_menu() {
	local id="$1" name="$2" paired="$3" reachable="$4"
	local sel f t
	if ((paired == 1)); then
		sel="$(printf '%s\n' \
			"Ping" "Find Device" "Send File" "Share Clipboard" "Share Text" "Browse Files" "Unpair" "Open Settings" |
			_choose "$name")" || exit 0

		case "$sel" in
		"Ping") _action_ping "$id" ;;
		"Find Device") _action_ring "$id" ;;
		"Send File")
			f="$(_pick_file)"
			[[ -n "${f:-}" ]] && _action_share_url "$id" "$f"
			;;
		"Share Clipboard")
			t="$(_clip_text)"
			[[ -n "${t:-}" ]] && _action_share_text "$id" "$t"
			;;
		"Share Text")
			t="$(_prompt_text 'Text to send')"
			[[ -n "${t:-}" ]] && _action_share_text "$id" "$t"
			;;
		"Browse Files") _action_browse "$id" ;;
		"Unpair")
			_dbg_dump_device "$id"
			_action_unpair "$id"
			_dbg_dump_device "$id"
			;;
		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
		*) : ;;
		esac
	else
		sel="$(printf '%s\n' "Pair Device" "Open Settings" "Cancel" | _choose "$name")" || exit 0
		case "$sel" in
		"Pair Device")
			_dbg_dump_device "$id"
			_action_pair "$id"
			_dbg_dump_device "$id"
			;;
		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
		*) : ;;
		esac
	fi
}
