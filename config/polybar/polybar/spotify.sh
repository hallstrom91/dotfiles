#!/usr/bin/env bash

PLAYER_OPT="${PLAYER_OPT:-spotify}"
MAXLEN="${MAXLEN:-40}"
FONT_ICON="${FONT_ICON:-4}"
FONT_PL="${FONT_PL:-5}"
SEP=" "

# ICON_PLAY="󰐊"
# ICON_PAUSE="󰏤"
ICON_PLAY="󰐍"
ICON_PAUSE="󰏦"
ICON_STOP="󰓛"
ICON_PREV="󰒮"
ICON_NEXT="󰒭"
ICON_SPOT="󰓇"
PL_L=""
PL_R=""

# helpers
truncate() {
	local s max len
	s="$1"
	max=${2:-60}
	len=${#s}
	if ((len <= max)); then
		printf '%s\n' "$s"
	else
		printf '%s...\n' "${s:0:max-1}"
	fi
}

format_line() {
	local trackid="$1" album="$2" artist="$3" title="$4"

	# podcast:
	if [[ "$trackid" == *"/episode/"* ]]; then
		# find ep-number if any in title (ex - "943: ..." or "#943 - ...")
		local ep="" rest="$title"
		if [[ "$title" =~ ^\#?([0-9]+) ]]; then
			ep="${BASH_REMATCH[1]}"
			rest="$(sed -E 's/^#?[0-9]+([[:space:]]*[:.\---])?[[:space::]]*//' <<<"$title")"
		fi

		if [[ -n "$ep" ]]; then
			truncate "${album} - Ep ${ep}: ${rest}" "$MAXLEN"
		else
			truncate "${album} - ${title}" "$MAXLEN"
		fi
	else
		# music: Artist - Song Title
		if [[ -n "$artist" && "$artist" != "null" ]]; then
			truncate "${artist} - ${title}" "$MAXLEN"
		else
			truncate "${album} - ${title}" "$MAXLEN"
		fi
	fi
}

# print play|pause|stop icon correctly to polybar modules
# NerdFonts MDI: https://pictogrammers.github.io/@mdi/font/5.4.55/
pp_icon() {
	case "$1" in
	Playing) printf '%s\n' "$ICON_PAUSE" ;;
	Paused) printf '%s\n' "$ICON_PLAY" ;;
	Stopped | "") printf '%s\n' "$ICON_STOP" ;;
	*) printf '%s\n' "$ICON_STOP" ;;
	esac
}

render() {
	local status="$1" trackid="$2" album="$3" artist="$4" title="$5"
	local text
	text="$(format_line "$trackid" "$album" "$artist" "$title")"

	# dont write if $text is empty
	[[ -z "$text" ]] && return 0

	local bg="#2E3440"
	local spot_clr="#1DB954" # spotify hex clr green

	# print powerline-icon, LEFT-side | $bg clr used as pline-icon `fg`
	printf '%%{T%s}%%{F%s}%s%%{F-}%%{T-}' "$FONT_PL" "$bg" "$PL_L"

	#bg color
	printf '%%{B%s}' "$bg"

	# icon+text
	# printf '%%{T%s}%s%%{T-} %s%s' "$FONT_ICON" "$ICON_SPOT" "$text" "$SEP"
	printf '%%{T%s}%%{F%s}%s%%{F-}%%{T-} %s%s' "$FONT_ICON" "$spot_clr" "$ICON_SPOT" "$text" "$SEP"

	# ctrl-btns (prev|play/pause|next)
	printf '%%{T%s}' "$FONT_ICON"
	printf '%%{A1:playerctl previous -p %s:}%s%%{A}%s' "$PLAYER_OPT" "$ICON_PREV" "$SEP"
	printf '%%{A1:playerctl play-pause -p %s:}%s%%{A}%s' "$PLAYER_OPT" "$(pp_icon "$status")" "$SEP"
	printf '%%{A1:playerctl next -p %s:}%s%%{A}' "$PLAYER_OPT" "$ICON_NEXT"

	# print powerline-icon, RIGHT-side | $bg clr used as pline-icon `fg`
	printf '%%{B-}%%{T%s}%%{F%s}%s%%{F-}%%{T-}' "$FONT_PL" "$bg" "$PL_R"
	# restore bg / font
	printf '%%{B-}%%{T-}\n'
}

command -v playerctl >/dev/null 2>&1 || exit 0

while :; do
	if playerctl --player="$PLAYER_OPT" status >/dev/null 2>&1; then
		playerctl --player="$PLAYER_OPT" metadata --follow \
			--format '{{status}}|{{mpris:trackid}}|{{xesam:album}}|{{xesam:artist}}|{{xesam:title}}' |
			while IFS="|" read -r status trackid album artist title; do
				[[ -z "${status:-}" ]] && {
					echo ""
					continue
				}
				[[ "$album" == "null" ]] && album=""
				[[ "$artist" == "null" ]] && artist=""
				[[ "$title" == "null" ]] && title=""
				render "$status" "$trackid" "$album" "$artist" "$title"
			done
		# if player close/exits - show nothing
		echo ""
	else
		echo ""
		sleep 1
	fi
done
