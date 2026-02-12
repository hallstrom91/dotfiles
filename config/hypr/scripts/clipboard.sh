#!/usr/bin/env bash

_notify() {
	notify-send "clipboard.sh" "$1"
	# notify-send -u low -t 4000 "clipboard.sh" "$1"
}

_wofi() {
	local prompt="$1"
	local filter="${2:-}"
	local selection

	if [[ -n "$filter" ]]; then
		selection="$(
			cliphist list |
				grep -i "$filter" |
				wofi --dmenu --prompt "$prompt" --pre-display-cmd "echo '%s' | cut -f2-"
		)"
	else
		selection="$(
			cliphist list |
				wofi --dmenu --prompt "$prompt" --pre-display-cmd "echo '%s' | cut -f2-"
		)"
	fi

	[[ -z "${selection:-}" ]] && exit 0

	printf '%s\n' "$selection" |
		cliphist decode |
		wl-copy
}

case "${1:-}" in
--cliphist-img)
	_wofi "Clipboard (img)" "image"
	;;
--cliphist-txt)
	_wofi "Clipboard (txt)" "text"
	;;
--cliphist-all)
	_wofi "Clipboard"
	;;
--cliphist-wipe)
	cliphist wipe
	_notify "Clipboard history wiped!"
	;;
*)
	_notify "Failed. Valid flags: [--img|--txt|--all|--wipe]"
	exit 1
	;;
esac

### FIRST DRAFT
# case "${1:-}" in
# --cliphist-img)
# 	cliphist list |
# 		wofi --dmenu --prompt "Clipboard (img)" --pre-display-cmd "echo '%s' | cut -f2-" |
# 		cliphist decode |
# 		wl-copy
# 	;;
# --cliphist-txt)
# 	cliphist list |
# 		wofi --dmenu --prompt "Clipboard (txt)" --pre-display-cmd "echo '%s' | cut -f2-" |
# 		cliphist decode |
# 		wl-copy
# 	;;
# --cliphist-wipe) cliphist wipe ;;
# *) notify-send "clipboard.sh" "Failed to execute selected '${1:-}' option" ;;
# esac
