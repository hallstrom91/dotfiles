#!/usr/bin/env bash

# ----- Guard ----- #
# process-name : htop/ps
if [[ "${KDE_REEXECED:-0}" != 1 ]]; then
	export KDE_REEXECED=1
	SELF="$(readlink -f -- "$0" 2>/dev/null || realpath -- "$0" 2>/dev/null || printf '%s\n' "$0")"
	exec -a kde-script "${BASH:-/bin/bash}" "$SELF" "$@"
fi

# ----- Config ----- #

# polybar fonts/icons (nerdfont)
KDE_FONT_ICON="${FONT_ICON:-4}" # size for icons
KDE_FONT_TEXT="${FONT_TEXT:-1}" # default text (font-0) in polybar
# KDE_ICON_PHONE="󰄜"
# KDE_ICON_DISCON="󰥍"
KDE_ICON_PHONE="${KDE_ICON_PHONE:-󰄜}"
KDE_ICON_DISCON="${KDE_ICON_DISCON:-󰥍}"
KDE_CLR_RED="${KDE_CLR_RED:-#BF616A}"
KDE_CLR_YELLOW="${KDE_CLR_YELLOW:-#EBCB8B}"
KDE_CLR_GREEN="${KDE_CLR_GREEN:-#A3BE8C}"

# State / Log
KDE_STATE_DIR=${KDE_STATE_DIR:-$HOME/state/polybar}

# UI tools - Menu|Notify
KDE_ROFI_BIN="${KDE_ROFI_BIN:-rofi}"
KDE_ROFI_OPTS="${KDE_ROFI_OPTS:--dmenu -i}"
KDE_NOTIFY="${KDE_NOTIFY:-notify-send}"

# DBus constants
KDE_DBUS_DEST="org.kde.kdeconnect"
KDE_DBUS_DEV_ROOT="/modules/kdeconnect/devices"

# Verbose-mode
KDE_VERBOSE="${KDE_VERBOSE:-0}"

# --------------------- #
# ----- Utilities ----- #

# does this command exists?
_have() { command -v "$1" >/dev/null 2>&1; }

# kdeconnect-daemon installed and/or process running? if not -> start it/or exit
_kde_ensure_daemon() {
	_have kdeconnectd || return 0
	pgrep -x kdeconnectd >/dev/null 2>&1 || kdeconnectd >/dev/null 2>&1 &
}

# gdbus call wrapper: path method [args...]
_daemon_call() {
	local path="$1"
	shift
	gdbus call --session --dest "$KDE_DBUS_DEST" --object-path "$path" --method "$@" 2>/dev/null || true
}

# extract first 'single-quoted' field from gdbus tuple output
_extract_squoted() {
	local s="$1" a b
	a=${s#*\'}
	[[ "$a" == "$s" ]] && {
		printf ''
		return 1
	}
	b=${a%%\'*}
	printf '%s' "$b"
}

# ---------------------------------------------- #
# ----- KDE-daemon Getters/Actions/Helpers ----- #
# ---- TEST

# get device id
_kde_device_ids() {
	local line path id
	while IFS= read -r line; do
		case "$line" in
		*"node "*"{")
			id=${line#*"node "}
			id=${id%% *}
			id=${id%\{}

			# safety check
			[[ "$id" == */* ]] && id=${id##*/}

			# sanity check; strict 32 hex case-insensitive
			[[ "$id" =~ ^[0-9a-fA-F]{32}$ ]] && printf '%s\n' "$id"
			;;
		esac
	done < <(gdbus introspect --session --dest "$KDE_DBUS_DEST" --object-path "$KDE_DBUS_DEV_ROOT" 2>/dev/null || true)

}

# -------------------------------------------------------- #
# ----- KDEConnect: DBus -> Properties.Get (boolean) ----- #

# KDE boolean getter
_kde_prop_bool() {
	local id="$1" prop="$2" path out
	# path="/modules/kdeconnect/devices/$id"
	path="$KDE_DBUS_DEV_ROOT/$id"
	out=$(
		gdbus call --session --dest "$KDE_DBUS_DEST" \
			--object-path "$path" \
			--method org.freedesktop.DBus.Properties.Get \
			org.kde.kdeconnect.device "$prop" 2>/dev/null || true
	)
	[[ $out == *"true"* ]]
}

_kde_device_is_reachable() { _kde_prop_bool "$1" isReachable; }
_kde_device_is_paired() { _kde_prop_bool "$1" isPaired; }
_kde_device_pair_requested() { _kde_prop_bool "$1" isPairRequested; }
_kde_device_pair_requested_bypeer() { _kde_prop_bool "$1" isPairRequestedByPeer; }

# get device name
_kde_device_name() {
	local id="$1" path out name
	# path="/modules/kdeconnect/devices/$id"
	path="$KDE_DBUS_DEV_ROOT/$id"

	out=$(_daemon_call "$path" org.kde.kdeconnect.device.name)
	[[ -z "$out" ]] && out=$(_daemon_call "$path" org.kde.kdeconnect.device.deviceName)
	if [[ -n "$out" ]]; then
		name=$(_extract_squoted "$out")
		[[ -n "$name" ]] && {
			printf '%s' "$name"
			return 0
		}
	fi
	# try properties
	out=$(_daemon_call "$path" org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device name)
	if [[ -n "$out" ]]; then
		name=$(_extract_squoted "$out")
		[[ -n "$name" ]] && {
			printf '%s' "$name"
			return 0
		}
	fi

	# fallback: missing device-name? print short-ID
	printf '%s...' "${id:0:8}"
}

# Actions
_kde_device_action() {
	local id="$1" act="$2" path
	# path="/modules/kdeconnect/devices/$id"
	path="$KDE_DBUS_DEV_ROOT/$id"
	case "$act" in
	pair) _daemon_call "$path" org.kde.kdeconnect.device.requestPairing ;;
	accept) _daemon_call "$path" org.kde.kdeconnect.device.acceptPairing ;;
	unpair) _daemon_call "$path" org.kde.kdeconnect.device.unpair ;;
	*) return 1 ;;
	esac
}

# count reachable devices - for status-display (polybar)
_kde_counts() {
	# stdout -> three number-values
	local id connected=0 online_unpaired=0 offline=0
	while IFS= read -r id; do
		if _kde_device_is_reachable "$id"; then
			if _kde_device_is_paired "$id"; then
				connected=$((connected + 1))
			else
				online_unpaired=$((online_unpaired + 1))
			fi
		else
			offline=$((offline + 1))
		fi
	done < <(_kde_device_ids)
	printf '%d %d %d' "$connected" "$online_unpaired" "$offline"
}

# ----------------------------------------------- #
# ----- Polybar output: no polling; IPC hook ---- #

_print_icon() {
	local connected online_unpaired offline
	read -r connected online_unpaired offline < <(_kde_counts)

	# coloring:
	# -> no connected -> red 'DISCON'-ic
	# -> >=1 connected -> green 'PHONE'-ic
	# -> extra online_unpiared+offline = append "+N" in yellow
	local extra=$((online_unpaired + offline))

	if ((connected > 0)); then
		if ((extra > 0)); then
			#  connected -> display: PHONE-ic +number-of-devices-reachable
			printf '%%{F%s}%%{T%s}%s%%{T-}%%{F-} %%{F%s}%%{T%s}+%d%%{T-}%%{F-}\n' \
				"$KDE_CLR_GREEN" "$KDE_FONT_ICON" "$KDE_ICON_PHONE" \
				"$KDE_CLR_YELLOW" "$KDE_FONT_TEXT" "$extra"
		else
			#  connected - no extra
			printf '%%{F%s}%%{T%s}%s%%{T-}%%{F-}\n' "$KDE_CLR_GREEN" "$KDE_FONT_ICON" "$KDE_ICON_PHONE"
		fi
	else
		if ((extra > 0)); then
			#  no connected -> display: DISCON-ic +number-of-devices-reachable
			printf '%%{F%s}%%{T%s}%s%%{T-}%%{F-} %%{F%s}%%{T%s}+%d%%{T-}%%{F-}\n' \
				"$KDE_CLR_RED" "$KDE_FONT_ICON" "$KDE_ICON_DISCON" \
				"$KDE_CLR_YELLOW" "$KDE_FONT_TEXT" "$extra"
		else
			#  no connected - no extra
			printf '%%{F%s}%%{T%s}%s%%{T-}%%{F-}\n' "$KDE_CLR_RED" "$KDE_FONT_ICON" "$KDE_ICON_DISCON"
		fi
	fi
}

# -------------------------------------------- #
# ----- Menu for device/action-selection ----- #

_rofi_choose() {
	local prompt="$1" bin opts
	bin="$KDE_ROFI_BIN"
	local -a opts

	IFS=' ' read -r -a opts <<<"$KDE_ROFI_OPTS"
	# read -r -a opts <<<"${KDE_ROFI_OPTS:--dmenu -i}"

	_have "$bin" || {
		$KDE_NOTIFY "KDEConnect" "rofi missing"
		return 1
	}

	"$bin" "${opts[@]}" -p "$prompt"
}

_menu() {

	_have gdbus || {
		$KDE_NOTIFY "KDEConnect" "gdbus missing"
		exit 1
	}

	_kde_ensure_daemon

	# build rows
	local rows=()
	local id name tag1 tag2
	while IFS= read -r id; do
		name="$(_kde_device_name "$id")"
		_kde_device_is_paired "$id" && tag1="[paired]" || tag1="[unpaired]"
		_kde_device_is_reachable "$id" && tag2="[online]" || tag2="[offline]"
		rows+=("$name $tag1 $tag2"$'\t'"$id")
	done < <(_kde_device_ids)

	# if empty device list
	((${#rows[@]})) || {
		$KDE_NOTIFY "KDEConnect" "No devices found."
		exit 0
	}

	# main-menu -> select device
	local sel dev_id
	sel="$(
		{ for ((i = 0; i < ${#rows[@]}; i++)); do printf '%s\n' "${rows[i]}"; done; } |
			_rofi_choose "KDEConnect"
	)" || exit 0
	dev_id="${sel##*$'\t'}"
	[[ -n "$dev_id" ]] || exit 0

	# submenu -> actions
	local actions=() dev_name
	dev_name="$(_kde_device_name "$dev_id")"

	if _kde_device_is_paired "$dev_id"; then
		actions+=("Unpair"$'\t'unpair)
	else
		_kde_device_pair_requested_bypeer "$dev_id" && actions+=("Accept pairing"$'\t'accept)
		if _kde_device_is_reachable "$dev_id" && ! _kde_device_pair_requested "$dev_id"; then
			actions+=("Request pairing"$'\t'pair)
		fi
	fi

	((${#actions[@]})) || {
		$KDE_NOTIFY "KDEConnect" "No actions available for: $dev_name"
		exit 0
	}

	local sel2 act
	sel2="$(
		{ for ((i = 0; i < ${#actions[@]}; i++)); do printf '%s\n' "${actions[i]}"; done; } |
			_rofi_choose "$dev_name"
	)" || exit 0
	act="${sel2##*$'\t'}"
	[[ -n "$act" ]] || exit 0

	if _kde_device_action "$dev_id" "$act" >/dev/null; then
		# if out=$(_kde_device_action "$dev_id" "$act"); then
		$KDE_NOTIFY "KDEConnect" "$act -> $dev_name"
	else
		$KDE_NOTIFY "KDEConnect" "Failed: $act -> $dev_name"
	fi
}

# --------------------- #
# ----- CLI Flags ----- #
case "${1:-}" in
--print) _print_icon ;;
--menu) _menu ;;
--verbose) KDE_VERBOSE=1 _menu ;;
*) _print_icon ;;
esac
