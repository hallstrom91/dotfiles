#!/usr/bin/env bash

# ----- Guard ----- #
# process-name : htop/ps
if [[ "${KDE_REEXECED:-0}" != 1 ]]; then
	export KDE_REEXECED=1
	SELF="$(readlink -f -- "$0" 2>/dev/null || realpath -- "$0" 2>/dev/null || printf '%s\n' "$0")"
	exec -a kde "${BASH:-/bin/bash}" "$SELF" "$@"
fi

# ----- Config ----- #

# polybar fonts/icons (nerdfont)
KDE_FONT_ICON="${FONT_ICON:-4}" # size for icons
KDE_ICON_PHONE="󰄜"
KDE_ICON_DISCON="󰥍"

# State / Log
KDE_STATE_DIR=${KDE_STATE_DIR:-$HOME/state/polybar}
# KDE_LOG_FILE="$KDE_STATE_DIR/kdeconnect.log"

# DBus
# KDE_DBUS_DEST="org.kde.kdeconnect"
# KDE_DBUS_DEV_ROOT="/modules/kdeconnect/devices"

# UI tools
# KDE_ROFI_CMD="${KDE_ROFI_CMD:-rofi -dmenu -i -p KDE Connect}"
KDE_ROFI_BIN="${KDE_ROFI_BIN:-rofi}"
KDE_NOTIFY="${KDE_NOTIFY:-notify-send}"

# Verbose-mode
KDE_VERBOSE="${KDE_VERBOSE:-0}"

# --------------------- #
# ----- Utilities ----- #

# does this command exists?
_have() { command -v "$1" >/dev/null 2>&1; }

# kdeconnect-daemon process running? if not -> start it
_kde_ensure_daemon() {
	pgrep -x kdeconnectd >/dev/null 2>&1 || kdeconnectd >/dev/null 2>&1 &
}

# call helper: path method [args...]
_kde_call() {
	local path="$1"
	shift
	gdbus call --session --dest org.kde.kdeconnect --object-path "$path" --method "$@" 2>/dev/null
}

# extract device name
_extract_squoted() {
	local s="$id" a b
	a=${s#*\'}
	[[ "$a" == "$s" ]] && {
		printf ''
		return 1
	}
	b=${a%%\'*}
	printf '%s' "$b"
}

# ---------------------------------------------------- #
# ----- Menu: rofi/dmenu device/action-selector  ----- #
_rofi_choose() {
	local prompt="$1"
	local bin opts
	bin="${KDE_ROFI_BIN:-rofi}"
	read -r -a opts <<<"${KDE_ROFI_OPTS:--dmenu -i}"

	_have "$bin" || {
		$KDE_NOTIFY "KDE Connect" "rofi missing"
		return 1
	}
	"$bin" "${opts[@]}" -p "$prompt"
}

# ---------------------------------------------- #
# ----- KDE-daemon Getters/Actions/Helpers ----- #

# get device id
_kde_device_ids() {
	local line id
	while IFS= read -r line; do
		case "$line" in
		*"node "*"{")
			id=${line#*"node "}
			id=${id%% *}
			id=${id%\{}

			# safety check
			[[ "$id" == */* ]] && id=${id##*/}
			# sanity check
			[[ "$id" =~ ^[0-9a-fA-F]{32}$ ]] && printf '%s\n' "$id"
			;;
		esac
	done < <(gdbus introspect --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices 2>/dev/null || true)
}

# get device name
_kde_device_name() {
	local id="$1" path out name
	path="/modules/kdeconnect/devices/$id"

	out=$(_kde_call "$path" org.kde.kdeconnect.device.name)
	[[ -z "$out" ]] && out=$(_kde_call "$path" org.kde.kdeconnect.device.deviceName)
	if [[ -n "$out" ]]; then
		name=$(_extract_squoted "$out")
		[[ -n "$name" ]] && {
			printf '%s' "$name"
			return 0
		}
	fi

	# try properties
	out=$(_kde_call "$path" org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device name)
	if [[ -n "$out" ]]; then
		name=$(_extract_squoted "$out")
		[[ -n "$name" ]] && {
			printf '%s' "$name"
			return 0
		}
	fi

	printf '%s' "$id"
}

# KDE boolean getter
_kde_prop_bool() {
	local id="$1" prop="$2" path out
	path="/modules/kdeconnect/devices/$id"
	out=$(
		gdbus call --session --dest org.kde.kdeconnect \
			--object-path "$path" \
			--method org.freedesktop.DBus.Properties.Get \
			org.kde.kdeconnect.device "$prop" 2>/dev/null || true
	)
	[[ "$out" == *"true"* ]]
}

_kde_device_is_reachable() { _kde_prop_bool "$1" isReachable; }
_kde_device_is_paired() { _kde_prop_bool "$1" isPaired; }
_kde_device_pair_requested() { _kde_prop_bool "$1" isPairRequested; }
_kde_device_pair_requested_bypeer() { _kde_prop_bool "$1" isPairRequestedByPeer; }

_kde_device_action() {
	local id="$1" act="$2" path
	path="/modules/kdeconnect/devices/$id"
	case "$act" in
	# pair) gdbus call --session --dest org.kde.kdeconnect --object-path "$path" --method org.kde.kdeconnect.device.requestPairing ;;
	# accept) gdbus call --session --dest org.kde.kdeconnect --object-path "$path" --method org.kde.kdeconnect.device.acceptPairing ;;
	# unpair) gdbus call --session --dest org.kde.kdeconnect --object-path "$path" --method org.kde.kdeconnect.device.unpair ;;
	pair) _kde_call "$path" org.kde.kdeconnect.device.requestPairing ;;
	accept) _kde_call "$path" org.kde.kdeconnect.device.acceptPairing ;;
	unpair) _kde_call "$path" org.kde.kdeconnect.device.unpair ;;
	*) return 1 ;;
	esac
}

# ------------------------------ #
# ----- Polybar Print Icons----- #

_print_icon() {
	local id
	while IFS= read -r id; do
		if _kde_device_is_paired "$id" && _kde_device_is_reachable "$id"; then
			printf '%%{T%s}%s%%{T-}\n' "$KDE_FONT_ICON" "$KDE_ICON_PHONE" #  connected
			return 0
		fi
	done < <(_kde_device_ids)
	printf '%%{T%s}%s%%{T-}\n' "$KDE_FONT_ICON" "$KDE_ICON_DISCON" # disconnected
}

# -------------------------------------------- #
# ----- Menu for device/action-selection ----- #
_menu() {
	_have gdbus || {
		$KDE_NOTIFY "KDE Connect" "gdbus missing"
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
		$KDE_NOTIFY "KDE Connect" "No devices found."
		exit 0
	}

	# main-menu -> select device
	local sel dev_id
	sel="$(printf '%s\n' "${rows[@]}" | _rofi_choose "KDE Connect")" || exit 0
	dev_id="${sel##*$'\t'}"
	[[ -n "$dev_id" ]] || exit 0

	# submenu -> select action
	name="$(_kde_device_name "$dev_id")"
	local actions=()

	if _kde_device_is_paired "$dev_id"; then
		actions+=("Unpair"$'\t'unpair)
	else
		if _kde_device_pair_requested_bypeer "$dev_id"; then
			actions+=("Accept pairing"$'\t'accept)
		fi
		if _kde_device_is_reachable "$dev_id" && ! _kde_device_is_pair_requested "$dev_id"; then
			actions+=("Request pairing"$'\t'pair)
		fi
	fi

	((${#actions[@]})) || {
		$KDE_NOTIFY "KDE Connect" "No actions available for: $name"
		exit 0
	}

	local sel2 act
	sel2="$(printf '%s\n' "${actions[@]}" | _rofi_choose "$name")" || exit 0
	act="${sel2##*$'\t'}"
	[[ -n "$act" ]] || exit 0

	# if _kde_device_action "$dev_id" "$act"; then
	if out=$(_kde_device_action "$dev_id" "$act"); then
		$KDE_NOTIFY "KDE Connect" "$act -> $name"
	else
		$KDE_NOTIFY "KDE Connect" "Failed: $act -> $name"
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
