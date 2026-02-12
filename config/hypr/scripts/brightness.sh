#!/usr/bin/env bash

STEP=10 # brightness adjustment val
VCP=10  # VCP code

IC_BULB=""
IC_PLUS=""
IC_MINUS=""

cur="$(
	ddcutil getvcp "$VCP" --display 1 2>/dev/null |
		sed -n 's/.*current value = *\([0-9]\+\).*/\1/p' |
		head -n1 || true
)"

[[ -n "${cur:-}" ]] || cur="?"

case "${1:-}" in
--print)
	if [[ "$cur" == "?" ]]; then
		printf '{"text":"?","alt":"%s","class":"error"}\n' "$IC_BULB"
	else
		printf '{"text":"%s%%","class":"value","alt":"%s","tooltip":"%s%%"}\n' "$cur" "$IC_BULB" "$cur"
	fi
	;;
--wofi)
	choice="$(
		printf '%s %s%%\n%s %s%%' \
			"$IC_PLUS" "$STEP" \
			"$IC_MINUS" "$STEP" |
			wofi --conf ~/.config/wofi/dmenu.conf
	)"

	[ -n "${choice}" ] || exit 0

	case "$choice" in
	"$IC_PLUS"*)
		v=$((cur + STEP))

		((v < 0)) && v=0
		((v > 100)) && v=100

		for d in 1 2; do
			ddcutil setvcp "$VCP" "$v" --display "$d" >/dev/null
		done
		;;
	"$IC_MINUS"*)
		v=$((cur - STEP))
		((v < 0)) && v=0
		((v > 100)) && v=100

		for d in 1 2; do
			ddcutil setvcp "$VCP" "$v" --display "$d" >/dev/null
		done
		;;
	esac
	;;
*)
	notify-send -u low -t 4000 "brightness.sh" "Invalid flag: ${1:-} \nValid flags: [--print|--up|--down|--daylight|--evening|--night]"
	exit 2
	;;
esac
