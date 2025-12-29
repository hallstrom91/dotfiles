#!/usr/bin/env bash
set -euo pipefail

IC_POWER="󰐥 " #nf-md-power
IC_REBOOT="󰜉 " #nf-md-restart
IC_LOGOUT="󰍃 " #nf-md-logout
PROMPT="Power"
CONFIRM="Confirm?"

###############
### helpers ###
###############

_has() { command -v "$1" >/dev/null 2>&1; }

_fail() { printf 'error: %s\n' "$*" >&2; exit 1;}

# run cmd, as-is.
_run() { "$@"; }

###############
### actions ###
###############
_logout() {
	if _has hyprctl; then
		_run hyprctl dispatch exit
		return 0
	fi

	if _has loginctl; then
		if [[ -n "${XDG_SESSION_ID:-}" ]]; then
			_run loginctl terminate-session "${XDG_SESSION_ID}"
			return 0
		fi

		_die "XDG_SESSION_ID is not set; Cant terminate session."
	fi

	_die "No supported logout method found; hyprctl/swaymsg/loginctl"
}

_poweroff() {
	_has systemctl || _die "systemctl not found"
	_run systemctl poweroff
}

_reboot() {
	_has systemctl || _die "systemctl not found"
	_run systemctl reboot
}

# wofi (UI)
_wofi_dmenu() {
	_has wofi || _die "wofi not found"
	#stdin -> wofi dmenu, return sel on stdout
	# wofi --dmenu --prompt "$1" --cache-file /dev/null
	wofi --dmenu --prompt "$1" --conf "$HOME/.config/wofi/powermenu.conf"
}


_confirm_yes() {
	# return 0 if "Yes", else 1
local ans
ans="$(printf 'No\nYes\n' | _wofi_dmenu "$CONFIRM" || true)"
[[ "$ans" == "Yes" ]]
}

_show_menu() {
	printf '%s Poweroff\n' "$IC_POWER"
	printf '%s Reboot\n' "$IC_REBOOT"
	printf '%s Logout\n' "$IC_LOGOUT"
}

_handle_choice() {
	local choice="$1"
	case "$choice" in
		*"Poweroff")
			_confirm_yes && _poweroff
			;;
		*"Reboot")
			_confirm_yes && _reboot
			;;
		*"Logout")
			_confirm_yes && _logout
			;;
		*)
			return 0
			;;
	esac
}

main() {
	if [[ "${1:-}" != "--menu" ]]; then
		printf '%s\n' "$IC_POWER"
		return 0
	fi

	local sel
	sel="$(_show_menu | _wofi_dmenu "$PROMPT" || true)"
	[[ -n "${sel:-}" ]] && _handle_choice "$sel"
}

main "$@"
