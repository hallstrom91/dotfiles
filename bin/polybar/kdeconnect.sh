#!/usr/bin/env bash
# based on:
#  https://github.com/haideralipunjabi/polybar-kdeconnect/blob/master/polybar-kdeconnect.sh

### Settings ###
ICON_FONT="${ICON_FONT:-4}" # polybar font-index (icons)
TEXT_FONT="${ICON_FONT:-1}" # polybar font-index (default)
ICON_PHONE="󰄜"
ICON_DISCON="󰥍"
SEP=" "

have() {
	command -v "$1" >/dev/null 2>&1
}

### Helpers (CLI) ###

first_available() {
	# first reachable and paired
	local line
	line="$(kdeconnect-cli --list-devices --id-name-only 2>/dev/null | head -n1 || true)"
	[[ -n "$line" ]] && {
		echo "$line"
		return
	}
	# other: first paired could be offline
	kdeconnect-cli --list-devices --id-name-only 2>/dev/null | head -n1 || true
}

dev_battery() {
	# return 0..100 or empty
	kdeconnect-cli --device "$1" --battery 2>/dev/null | grep -Eo '[0-9]+' | head -n1 || true
}

dev_is_reachable() {
	kdeconnect-cli --device "$1" --is-reachable >/dev/null 2>&1
}

dev_is_paired() {
	# encryption-info returns 0 if paired
	kdeconnect-cli --device "$1" --encryption-info >/dev/null 2>&1
}

list_devices_all() {
	# returns rows in format: id|name|reachable|paired
	local ids
	ids="$(kdeconnect-cli --list-devices --id-only 2>/dev/null || true)"
	while IFS= read -r id; do
		[[ -z "$id" ]] && continue
		local name reachable paired
		name="$(kdeconnect-cli --device "$id" --name 2>/dev/null || echo "$id")"
		dev_is_reachable "$id" && reachable=1 || reachable=0
		dev_is_paired "$id" && paired=1 || paired=0
		printf '%s|%s|%s|%s\n' "$id" "$name" "$reachable" "$paired"
	done <<<"$ids"
}

### Polybar: fast, minimal status ###
status_line() {
	local line id name bat reachable paired
	line="$(first_available || true)"
	if [[ -z "$line" ]]; then
		printf '%%{T%s}%s%%{T%s}%sno device\n' "$ICON_FONT" "$ICON_DISCON" "$TEXT_FONT" "$SEP"
		return
	fi

	# line is: "- <id> <name>" - pick id & name
	id="$(awk '{print $2}' <<<"$line")"
	name="$(sed -E 's/^- [^ ]+ (.*)$/\1/' <<<"$line")"

	if dev_is_reachable "$id"; then
		bat="$(dev_battery "$id")"
		if [[ -n "$bat" ]]; then
			printf '%%{T%s}%s%%{T%s}%s%s %s%%%s\n' "$ICON_FONT" "$ICON_PHONE" "$TEXT_FONT" "$SEP" "$name" "$bat" "$SEP"
		else
			printf '%%{T%s}%s%%{T%s}%s%s\n' "$ICON_FONT" "$ICON_PHONE" "$TEXT_FONT" "$SEP" "$name"
		fi
	else
		printf '%%{T%s}%s%%{T%s}%s%s (offline)\n' "$ICON_FONT" "$ICON_DISCON" "$TEXT_FONT" "$SEP" "$name"
	fi
}

### Rofi: dmenu helpers ###
choose() {
	local prompt="${1:-Select}"
	if have rofi; then
		rofi -dmenu -i -p "$prompt"
	else
		dmenu -p "$prompt"
		# fzf --prompt "$prompt" || true
	fi
}

pick_file() {
	if have zenity; then
		zenity --file-selection 2>/dev/null || true
	elif have kdialog; then
		kdialog --getopenfilename 2>/dev/null || true
	else
		# last resort
		echo ""
	fi
}

clip_text() {
	if have xclip; then
		xclip -o -selection clipboard 2>/dev/null || true
	elif have wl-paste; then
		wl-paste 2>/dev/null || true
	else
		echo ""
	fi
}

device_actions_menu() {
	local id="$1" name="$2" paired="$3" reachable="$4"
	local opts rel
	if [[ "$paired" -eq 1 ]]; then
		opts="Ping\nFind Device\nSend File\nShare Clipboard\nShare Text\nBrowse Files\nUnpair"
		sel="$(printf '%b' "$opts" | choose "$name")" || exit 0

		case "$rel" in
		"Ping") kdeconnect-cli --device "$id" --ping ;;
		"Find Device") kdeconnect-cli --device "$id" --ring ;;
		"Send File")
			f="$(pick_file)"
			[[ -n "$f" ]] && kdeconnect-cli --device "$id" --share "file://$f"
			;;
		"Share Clipboard")
			t="$(clip_text)"
			[[ -n "$t" ]] && kdeconnect-cli --device "$id" --share-text "$t"
			;;
		"Share Text")
			t="$(printf '' | choose 'Share text')"
			[[ -n "$t" ]] && kdeconnect-cli --device "$id" --share-text "$t"
			;;
		"Browse Files") xdg-open "kdeconnect://$id/" >/dev/null 2>&1 || kdeconnect-app & ;;
		"Unpair") kdeconnect-cli --device "$id" --unpair ;;
		*) : ;;
		esac
	else
		sel="$(printf 'Pair Device\nCancel\n' | choose "$name")" || exit 0
		[[ "$sel" == "Pair Device" ]] && kdeconnect-cli --device "$id" --pair
	fi
	# "Pair Device") kdeconnect-cli --device "$id" --pair ;;
	# "Unpair") kdeconnect-cli --device "$id" --unpair ;;
	# "Ping") kdeconnect-cli --device "$id" --ping ;;

}

main_menu() {
	kdeconnect-cli --refresh >/dev/null 2>&1 || true

	local rows choice id name reachable paired
	mapfile -t rows < <(list_devices_all)

	if ((${#rows[@]} == 0)); then
		choice="$(printf 'Open KDE Connect\n' | choose 'KDE Connect')" || exit 0
		[[ "$choice" == "Open KDE Connect" ]] && kdeconnect-app &
		exit 0
	fi

	# build minimal device-list
	choice="$(printf '%s\n' "${rows[@]}" |
		awk -F'|' 'BEGIN{OFS="|"}{print $3,$4,$2,$1}' |
		sort -r |
		awk -F'|' -v IF="$ICON_FONT" -v TF="$TEXT_FONT" -v ip="$ICON_PHONE" -v ic"$ICON_DISCON" '
	$1==1 && $2==1 {printf("connected |%s|%s\n",$3,$4); next}
	$1==0 && $2==1 {printf("paired |%s|%s\n",$3,$4); next}
	{printf("available |%s|%s\n",$3,$4)}' |
		awk -F'|' '{print $1 " " $2 "|" $3}' |
		choose "Devices")" exit 0

	[[ -z "$choice" ]] && exit 0

	id="$(cut -d'|' -f2 <<<"$choice")"
	name="$(cut -d' ' -f3- <<<"$(cut -d'|' -f1 <<<"$choice")")"

	dev_is_reachable "$id" && reachable=1 || reachable=0
	dev_is_paired "$id" && paired=1 || paired=0

	device_actions_menu "$id" "$name" "$paired" "$reachable"
}

# actions
# device_menu() {
# 	local id="$1" name="$2" paired="$3" reachable="$4"
# 	local entries=""
# 	if [[ "$paired" -eq 1 ]]; then
# 		entries+="Battery: $(device_battery "$id")%|"
# 		entries+="Ping|Find Device|Send File|Share Clipboard|Share Text|Browse Files|Unpair"
# 	else
# 		entries+="Pair Device"
# 	fi
# 	local sel
# 	sel="$(printf '%s\n' "$entries" | tr '|' '\n' | choose "$name")" || exit 0
#
# 	case "$sel" in
# 	"Pair Device") kdeconnect-cli --device "$id" --pair ;;
# 	"Unpair") kdeconnect-cli --device "$id" --unpair ;;
# 	"Ping") kdeconnect-cli --device "$id" --ping ;;
# 	"Find Device") kdeconnect-cli --device "$id" --ring ;;
# 	"Send File")
# 		file="$(pick_file)"
# 		[[ -n "${file:-}" ]] && kdeconnect-cli --device "$id" --share "file://$file"
# 		;;
# 	"Share Clipboard")
# 		if have xclip; then
# 			txt="$(xclip -0 -selection clipboard 2>/dev/null || true)"
# 		elif have wl-paste; then
# 			txt="$(wl-pase 2>/dev/null || true)"
# 		else
# 			txt=""
# 		fi
# 		[[ -n "${txt:-}" ]] && kdeconnect-cli --device "$id" --share-text "$txt"
# 		;;
# 	"Browse Files")
# 		# try GVfs URL; Works in Nautilus/dolphin
# 		if have xdg-open; then
# 			xdg-open "kdeconnect://$id/" >/dev/null 2>&1 || kdeconnect-app &
# 		else
# 			kdeconnect-app &
# 		fi
# 		;;
# 	*) : ;;
# 	esac
# }
#
# show_menu() {
# 	kdeconnect-cli --refresh >/dev/null 2>&1 || true
#
# 	local lines name id reachable paired tag
# 	mapfile -t lines < <(list_devices)
# 	if ((${#lines[@]} == 0)); then
# 		choose "KDE Connect" <<<"No devices|Open app" | grep -q "Open app" && kdeconnect-app &
# 		exit 0
# 	fi
#
# 	menu=""
# 	for l in "${lines[@]}"; do
# 		IFS="|" read -r id name reachable paired <<<"$l"
# 		if [[ "$paired" -eq 1 && "$reachable" -eq 1 ]]; then
# 			tag="connected"
# 			icon="$ICON_PHONE"
# 		elif [[ "$paired" -eq 1 ]]; then
# 			tag="paired"
# 			icon="$ICON_DISCON"
# 		else
# 			tag="available"
# 			icon="$ICON_DISCON"
# 		fi
# 		menu+="${icon} ${name} [${tag}]|${id}|${name}|${paired}|${reachable}"$'\n'
# 	done
#
# 	# select device
# 	choice="$(printf '%s' "$menu" | awk -F'|' '{printf $1}' | choose "Devices")" || exit 0
# 	[[ -z "$choice" ]] && exit 0
#
# 	meta="$(printf '%s' "$menu" | grep -F "^$choice|" | head -n1)"
# 	IFS="|" read -r _ id name paired reachable <<<"$meta"
# 	device_menu "$id" "$name" "$paired" "$reachable"
# }
#
case "${1:-}" in
--menu) show_menu ;;
*) status_line ;;
esac
