#!/usr/bin/env bash

IC_SUN=""
IC_SUNSET=""
IC_MOON=""

TEMP_DAY=7500
TEMP_EVE=4200
TEMP_NIGHT=3400

temp="$(
	hyprctl hyprsunset temperature 2>/dev/null |
		grep -oE '[0-9]+' |
		# sed -n 's/[^0-9]*\([0-9]\+\).*/\1/p' |
		head -n1
)"
[[ -n "${temp:-}" ]] || temp="?"

mode="day"
icon="$IC_SUN"

[[ "$temp" == "?" ]] && mode="error" && icon="?"
[[ "$temp" == "$TEMP_EVE" ]] && mode="evening" && icon="$IC_SUNSET"
[[ "$temp" == "$TEMP_NIGHT" ]] && mode="night" && icon="$IC_MOON"

case "${1:-}" in
--print)
	if [[ "$temp" == "?" ]]; then
		printf '{"text":"?","class":"error"}\n'
	else
		printf '{"text":"%s","class":"%s","temperature":"%sK","tooltip":"%sK"}\n' "$icon" "$mode" "$temp" "$temp"
	fi
	;;
--wofi)
	choice="$(
		printf '%s %sK\n%s %sK\n%s %sK\n' \
			"$IC_SUN" "$TEMP_DAY" \
			"$IC_SUNSET" "$TEMP_EVE" \
			"$IC_MOON" "$TEMP_NIGHT" |
			wofi --conf ~/.config/wofi/dmenu.conf \
				--width 150 \
				--height 120

	)"

	[ -n "${choice}" ] || exit 0

	case "${choice:-}" in
	"$IC_SUN"*)
		hyprctl hyprsunset temperature "$TEMP_DAY" >/dev/null 2>&1 || true
		;;
	"$IC_SUNSET"*)
		hyprctl hyprsunset temperature "$TEMP_EVE" >/dev/null 2>&1 || true
		;;
	"$IC_MOON"*)
		hyprctl hyprsunset temperature "$TEMP_NIGHT" >/dev/null 2>&1 || true
		;;
	esac
	;;
*)
	notify-send -u low -t 4000 "nightlight.sh" "Invalid flag: ${1:-} \nValid flags: [--print|--wofi]"
	exit 2
	;;
esac
