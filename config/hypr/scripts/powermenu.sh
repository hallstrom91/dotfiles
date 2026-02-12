#!/usr/bin/env bash

# change to .svg images? for display of ONLY "svg-icons" in column-rows ?
IC_OFF=""    #nf-fa-power_off
IC_REBOOT="" # "" #nf-fa-spinner
IC_LOGOUT="" #nf-fa-door_closed
IC_LOCK=""   #nf-fa-lock

case "${1:-}" in
--print) printf '{"text":"%s","class":"powermenu","tooltip":"Power menu"}\n' "$IC_OFF" ;;
--wofi)
	choice="$(
		printf '%s\n%s\n%s\n%s' \
			"$IC_LOCK" "$IC_LOGOUT" "$IC_OFF" "$IC_REBOOT" |
			wofi \
				--conf ~/.config/wofi/dmenu-rows.conf
	)"

	case "$choice" in
	"$IC_LOCK"*) hyprlock ;;
	"$IC_LOGOUT"*)
		loginctl terminate-session "$XDG_SESSION_ID"
		;;
	"$IC_OFF"*) systemctl poweroff ;;
	"$IC_REBOOT"*) systemctl reboot ;;
	*) exit 0 ;;
	esac
	;;
*) exit 0 ;;
esac
