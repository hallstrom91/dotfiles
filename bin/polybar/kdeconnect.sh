#!/usr/bin/env bash

# KDE Connect integration for Polybar
# Idempotent autostart of kdeconnectd
# Rofi/dmenu-menu with standard actions
# Polybar font and icon-handling
# Based on / inspired by: https://github.com/haideralipunjabi/polybar-kdeconnect/blob/master/polybar-kdeconnect.sh

######################
### Settings | ENV ###
######################

# polybar font & icons
FONT_ICON="${FONT_ICON:-4}"
FONT_TEXT="${FONT_TEXT:-1}"
ICON_PHONE="󰄜"
ICON_DISCON="󰥍"
SEP=" "

# optional device preference for status selection
DEV_PREFER_NAME="${DEV_PREFER_NAME:-}" # substring match in device name
DEV_PREFER_ID="${DEV_PREFER_ID:-}"     # exact device id match

# logging (enabled with --verbose)
LOG_FILE="${LOG_FILE:-$HOME/.cache/kdeconnect-script-polybar.log}"
_VERBOSE=0

#################
### Utilities ###
#################

have() { command -v "$1" >/dev/null 2>&1; }

# _log(): write timestamped line (if verbose)
_log() {
	((_VERBOSE)) || return 0
	mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
	printf '[%(%F %T)T] %s\n' -1 "$*" >>"$LOG_FILE"
}

_backend_for() {
	local what="$1" dev="${2:-}"
	if have_qdbus && _kdeconnectd_up; then
		_log "[backend:$what] dbus (dev=${dev:-n/a})"
		printf '%s' dbus
	elif have_cli; then
		_log "[backend:$what] cli (dev=${dev:-n/a})"
		printf '%s' cli
	else
		_log "[backend:$what] none (dev=${dev:-n/a})"
		printf '%s' none
	fi
}

# _run(): run and log cmd + stderr (if verbose)
_run() {
	if ((_VERBOSE)); then
		_log "\$ $*"
		"$@" 2>>"$LOG_FILE"
		local rc=$?
		_log "↳ exit=$rc"
		return $rc
	else
		"$@" 2>/dev/null
	fi
}

################################
### Parse simple flags first ###
################################

for _arg in "$@"; do
	case "${_arg}" in
	--verbose) _VERBOSE=1 ;;
	esac
done
if ((_VERBOSE)); then
	_log "=== start (pid $$, user $USER) ==="
fi

#######################################################
### Control: qdbus detection (no eval; arrays only) ###
#######################################################

# _qdbus_ok: sanity check
_qdbus_ok() {
	local -a cmd=("$@")
	"${cmd[@]}" --version >/dev/null 2>&1 ||
		"${cmd[@]}" org.freedesktop.DBus / org.freedesktop.DBus.ListNames >/dev/null 2>&1
}

QDBUS_CMD=()
# try binaries: qt6 -> qt5 -> system
for cand in \
	"/usr/lib/qt6/bin/qdbus6" \
	"$(command -v qdbus6 2>/dev/null)" \
	"/usr/lib/x86_64-linux-gnu/qt5/bin/qdbus" \
	"/usr/lib/qt5/bin/qdbus" \
	"$(command -v qdbus-qt5 2>/dev/null)" \
	"$(command -v qdbus 2>/dev/null)"; do
	[[ -n "${cand:-}" && -x "$cand" ]] || continue
	if _qdbus_ok "$cand"; then
		QDBUS_CMD=("$cand")
		_log "qdbus selected: $cand"
		break
	fi
done

if ((${#QDBUS_CMD[@]} == 0)) && have qtchooser; then
	if _qdbus_ok qtchooser -run-tool=qdbus6 -qt=qt6; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus6 -qt=qt6)
	elif _qdbus_ok qtchooser -run-tool=qdbus -qt=qt5; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus -qt=qt5)
	fi
	((${#QDBUS_CMD[@]})) && _log "qdbus via qtchooser: ${QDBUS_CMD[*]}"
fi

have_qdbus() { ((${#QDBUS_CMD[@]} > 0)); }

_qdbus() { "${QDBUS_CMD[@]}" "$@"; }

##################################
### Fallback Sanity Check: CLI ###
##################################

KDE_CLI_CMD=()
if have kdeconnect-cli; then
	KDE_CLI_CMD=(kdeconnect-cli)
	_log "kdeconnect-cli detected: ${KDE_CLI_CMD[*]}"
fi

have_cli() { ((${#KDE_CLI_CMD[@]} > 0)); }

_cli() { "${KDE_CLI_CMD[@]}" "$@"; }

#############################
# Controls
#############################

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
	_log "failed to start daemon (no binary found): defaulting to 'kdeconnect-cli' (slower)"
	return 1
}

# start daemon if neither pid nor dbus name is present
if ! pgrep -x kdeconnectd >/dev/null 2>&1 && ! _kdeconnectd_up; then
	_start_kdeconnectd || true
fi

###############################################
### qdbus helpers (service,path,interface)  ###
###############################################

_qdbus_list_ids() {
	_qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices 2>/dev/null |
		awk -F'"' '{for(i=2;i<=NF;i+=2) print $i}'
}

_qdbus_dev_name() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.name 2>/dev/null; }
_qdbus_dev_reachable() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isReachable 2>/dev/null; }
_qdbus_dev_paired() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isTrusted 2>/dev/null; }
_qdbus_dev_battery() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/battery" org.kde.kdeconnect.device.battery.charge 2>/dev/null; }

#############################
### CLI fallback helpers  ###
#############################

#Dbus first helper | CLI fallback for actions

# dbus actions
_dbus_ping() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/ping" org.kde.kdeconnect.device.ping.sendPing; }
_dbus_ring() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/findmyphone" org.kde.kdeconnect.device.findmyphone.ring; }
_dbus_share_url() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/share" org.kde.kdeconnect.device.share.shareUrl "file://$2"; }
_dbus_share_text() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/share" org.kde.kdeconnect.device.share.shareText "$2"; }
_dbus_sftp_mounted() { _qdbus org.kde.kdeconnect --literal "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.isMounted; }
_dbus_sftp_mount() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.mount; }
_dbus_sftp_browse() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/sftp" org.kde.kdeconnect.device.sftp.startBrowsing; }
_dbus_unpair() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.unpair; }
_dbus_pair() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.requestPair; }

# cli actions # add have kdeconnect-cli here or in _action_*() -wrappers ?
_cli_ping() { _cli --device "$1" --ping; }
_cli_ring() { _cli --device "$1" --ring; }
_cli_share_url() { _cli --device "$1" --share "file://$2"; }
_cli_share_text() { _cli --device "$1" --share-text "$2"; }
_cli_unpair() { _cli --device "$1" --unpair; }
_cli_pair() { _cli --device "$1" --pair; }
# add more? sms ?

######################################
# Action Wrappers: dbus first, cli fallback.
######################################

_action_ping() {
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_ping "$1"
	elif have_cli; then
		_run _cli_ping "$1"
	else
		_log "No DBus/CLI available for 'ping' action (device $1)"
		return 127
	fi
}

_action_ring() {
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_ring "$1"
	elif have_cli; then
		_run _cli_ring "$1"
	else
		_log "No DBus/CLI available for 'ring' action (device $1)"
		return 127
	fi
}

_action_share_url() {
	local id="$1" fpath="$2"
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_share_url "$id" "$fpath"
	elif have_cli; then
		_run _cli_share_url "$id" "$fpath"
	else
		_log "No DBus/CLI available for 'share-url' action (device $1)"
		return 127
	fi
}

_action_share_text() {
	local id="$1" txt="$2"
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_share_text "$id" "$txt"
	elif have_cli; then
		_run _cli_share_text "$id" "$txt"
	else
		_log "No DBus/CLI available for 'share-text' action (device $1)"
		return 127
	fi
}

_action_unpair() {
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_unpair "$id"
	elif have_cli; then
		_run _cli_unpair "$id"
	else
		_log "No DBus/CLI available for 'unpair' action (device $1) - makes no sense?! how did you get here?"
		return 127
	fi
}

_action_pair() {
	if have_qdbus && _kdeconnectd_up; then
		_run _dbus_pair "$id"
	elif have_cli; then
		_run _cli_pair "$id"
	else
		_log "No DBus/CLI available for 'pair' action (device $1)"
		return 127
	fi
}

# Browse: DBus sftp mount/browse | CLI fallback: open kdeconnect://
_action_browse() {
	local id="$1"
	if have_qdbus && _kdeconnectd_up; then
		if [[ "$(_dbus_sftp_mounted "$id" 2>/dev/null)" != "true" ]]; then
			_run _dbus_sftp_mount "$id" || true
			sleep 0.2
		fi
		_run _dbus_sftp_browse "$id" || true
	elif have_cli; then
		# no CLI browse: try generic URL
		_run xdg-open "kdeconnect://$id/" >/dev/null 2>&1 || _run kdeconnect-app &
	else
		_log "No DBus/CLI available for 'mount/browse' action (device $1)"
		return 127
	fi
}

# _dev_is_reachable() { _run kdeconnect-cli --device "$1" --is-reachable; }
# _dev_is_paired() { _run kdeconnect-cli --device "$1" --encryption-info; }

########################################
### Device selection for statusline  ###
########################################

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

###############################
### Polybar: display status ###
###############################

# printf helper for status_line()
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
	cli_id="$(_run kdeconnect-cli --list-available --id-only | head -n1 || true)"

	if [[ -n "$cli_id" ]]; then
		name="$(_run kdeconnect-cli --device "$cli_id" --name || echo "$cli_id")"
		bat="$(_run kdeconnect-cli --device "$cli_id" --battery | grep -Eo '[0-9]+' | head -n1 || true)"
		_print_device_line "$ICON_PHONE" "$name" "$bat"
		return
	fi

	name="$(_run kdeconnect-cli --list-devices --name-only | head -n1 || true)"
	if [[ -n "$name" ]]; then
		_print_device_line "$ICON_DISCON" "$name" "" "(offline)"
		# printf '%%{T%s}%s%%{T%s}%s%s (offline)\n' "$FONT_ICON" "$ICON_DISCON" "$FONT_TEXT" "$SEP" "$name"
	else
		_print_device_line "$ICON_DISCON"
	fi
}

############################
### Rofi / dmenu helpers ###
############################

# helper: select/choose options in menu
_choose() {
	local prompt="${1:-Select}"
	if have rofi; then
		rofi -dmenu -i -p "$prompt"
	else
		dmenu -i -p "$prompt"
	fi
}

# helper: pick file to share
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

# helper: send clipboard
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

# helper: send free-text
_prompt_text() {
	local prompt="${1:-Text}"
	if have rofi; then
		# rofi -dmenu with empty input, single-line txt entry
		rofi -dmenu -p "$prompt" <<<""
	else
		dmenu -i -p "$prompt" <<<""
	fi
}

###########################################
###					Build list for menu					###
###########################################

# List Output: DISPLAY|ID|PAIRED|REACHABLE
list_all_structured() {
	local id name paired reachable display
	if have_qdbus && _kdeconnectd_up; then
		while IFS= read -r id; do
			[[ -z "$id" ]] && continue
			name="$(_qdbus_dev_name "$id" || echo "$id")"

			[[ $(_qdbus_dev_paired "$id") == "true" ]] && paired=1 || paired=0
			[[ $(_qdbus_dev_reachable "$id") == "true" ]] && reachable=1 || reachable=0
			# [[ "$(_qdbus_dev_paired "$id")" == "true" ]] && paired=1 || paired=0
			# [[ "$(_qdbus_dev_reachable "$id")" == "true" ]] && reachable=1 || reachable=0

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
	mapfile -t ids < <(_run kdeconnect-cli --list-devices --id-only || true)
	mapfile -t names < <(_run kdeconnect-cli --list-devices --name-only || true)

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
### Actions menu per device ###
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
		"Unpair") _action_unpair "$id" ;;
		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
		*) : ;;
		esac
	else
		sel="$(printf '%s\n' "Pair Device" "Open Settings" "Cancel" | _choose "$name")" || exit 0
		case "$sel" in
		"Pair Device") _action_pair "$id" ;;
		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
		*) : ;;
		esac
	fi
}

# _device_actions_menu() {
# 	local id="$1" name="$2" paired="$3" reachable="$4"
# 	local sel f t
# 	if ((paired == 1)); then
# 		sel="$(printf '%s\n' \
# 			"Ping" "Find Device" "Send File" "Share Clipboard" "Share Text" "Browse Files" "Unpair" "Open Settings" |
# 			_choose "$name")" || exit 0
#
# 		case "$sel" in
# 		"Ping") _run kdeconnect-cli --device "$id" --ping ;;
# 		"Find Device") _run kdeconnect-cli --device "$id" --ring ;;
# 		"Send File")
# 			f="$(_pick_file)"
# 			[[ -n "${f:-}" ]] && _run kdeconnect-cli --device "$id" --share "file://$f"
# 			;;
# 		"Share Clipboard")
# 			t="$(_clip_text)"
# 			[[ -n "${t:-}" ]] && _run kdeconnect-cli --device "$id" --share-text "$t"
# 			;;
# 		"Share Text")
# 			t="$(_prompt_text 'Text to send')"
# 			[[ -n "${t:-}" ]] && _run kdeconnect-cli --device "$id" --share-text "$t"
# 			;;
# 		"Browse Files") _run xdg-open "kdeconnect://$id/" >dev/null 2>&1 || _run kdeconnect-app & ;;
# 		"Unpair") _run kdeconnect-cli --device "$id" --unpair ;;
# 		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
# 		*) : ;;
# 		esac
# 	else
# 		sel="$(printf '%s\n' "Pair Device" "Open Settings" "Cancel" | _choose "$name")" || exit 0
# 		case "$sel" in
# 		"Pair Device") _run kdeconnect-cli --device "$id" --pair ;;
# 		"Open Settings") _run kdeconnect-settings >/dev/null 2>&1 & ;;
# 		*) : ;;
# 		esac
# 	fi
# }

#################
### Main Menu ###
#################

# Accessed with '--menu' -flag
_main_menu() {
	local -a lines
	local choice line id name paired reachable
	mapfile -t lines < <(list_all_structured)

	if ((${#lines[@]} == 0)); then
		choice="$(printf '%s\n' "Refresh" "Open Settings" | _choose 'KDE Connect')" || exit 0

		if [[ "$choice" == "Refresh" ]]; then
			_run kdeconnect-cli --refresh || true
			exec "$0" --menu ${_VERBOSE:+--verbose}
		elif [[ "$choice" == "Open Settings" ]]; then
			_run kdeconnect-settings >/dev/null 2>&1 &
		fi
		exit 0
	fi

	# stable ordering: Connected=3, Paired=2, Available=1, Refresh=0
	choice="$(
		{
			local line
			for line in "${lines[@]}"; do
				case "$line" in
				Connected:\ *) echo "3|$line" ;;
				Paired:\ *) echo "2|$line" ;;
				Available:\ *) echo "1|$line" ;;
				esac
			done
			echo "0|Refresh|_|0|0"
		} | sort -t'|' -k1,1nr -k2,2 |
			cut -d'|' -f2 |
			cut -d'|' -f1 |
			_choose "Devices"
	)" || exit 0

	[[ -z "$choice" ]] && exit 0

	if [[ "$choice" == "Refresh" ]]; then
		_run kdeconnect-cli --refresh || true
		exec "$0" --menu ${_VERBOSE:+--verbose}
	fi

	line="$(printf '%s\n' "${lines[@]}" | grep -F "^$choice|" | head -n1)"
	id="$(cut -d'|' -f2 <<<"$line")"
	paired="$(cut -d'|' -f3 <<<"$line")"
	reachable="$(cut -d'|' -f4 <<<"$line")"

	name="${choice#Connected: }"
	name="${name#Paired: }"
	name="${name#Available: }"

	_device_actions_menu "$id" "$name" "$paired" "$reachable"
}

#########################
### Entrypoint ###
#########################
case "${1:-}" in
--menu) _main_menu ;;
*) status_line ;;
esac
