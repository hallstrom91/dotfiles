#!/usr/bin/env bash
# based on:
#  https://github.com/haideralipunjabi/polybar-kdeconnect/blob/master/polybar-kdeconnect.sh

kdeconnectd_up() {
	"${QDBUS_CMD[@]}" org.freedesktop.DBus / org.freedesktop.DBus.ListNames 2>/dev/null |
		grep -q 'org.kde.kdeconnect'
}

if ! pgrep -x kdeconnectd >/dev/null 2>&1; then
	# kdeconnectd >/dev/null 2>&1 &
	/usr/lib/x86_64-linux-gnu/libexec/kdeconnectd >/dev/null 2>&1 &
	disown
	sleep 0.2
fi

### Settings ###

FONT_ICON="${FONT_ICON:-4}" # polybar font-index (icons)
FONT_TEXT="${FONT_TEXT:-1}" # polybar font-index (default)

ICON_PHONE="󰄜"
ICON_DISCON="󰥍"
SEP=" "

# control
have() {
	command -v "$1" >/dev/null 2>&1
}

####################################
### qdbus based listing (faster) ###
### is if available ###

_qdbus_ok() {
	local -a cmd=("$@")
	"${cmd[@]}" --version >/dev/null 2>&1 ||
		"${cmd[@]}" org.freedesktop.DBus / org.freedesktop.DBus.ListNames >/dev/null 2>&1
}

QDBUS_CMD=()

for cand in \
	"/usr/lib/qt6/bin/qdbus6" \
	"$(command -v qdbus6 2>/dev/null)" \
	"/usr/lib/x86_64-linux-gnu/qt5/bin/qdbus" \
	"/usr/lib/qt5/bin/qdbus" \
	"$(command -v qdbus-qt5 2>/dev/null)" \
	"$(command -v qdbus 2>/dev/null)"; do
	[[ -n "$cand" && -x "$cand" ]] || continue
	if _qdbus_ok "$cand"; then
		QDBUS_CMD=("$cand")
		break
	fi
done

if ((${#QDBUS_CMD[@]} == 0)) && command -v qtchooser >/dev/null 2>&1; then
	if _qdbus_ok qtchooser -run-tool=qdbus6 -qt=qt6; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus6 -qt=qt6)
	elif _qdbus_ok qtchooser -run-tool=qdbus -qt=qt5; then
		QDBUS_CMD=(qtchooser -run-tool=qdbus -qt=qt5)
	fi
fi

have_qdbus() { ((${#QDBUS_CMD[@]} > 0)); }
_qdbus() { "${QDBUS_CMD[@]}" "$@"; }

qdbus_list_ids() {
	_qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices |
		awk -F'"' '{for(i=2;i<=NF;i+=2) print $i}'
}

qdbus_dev_name() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.name; }
qdbus_dev_reachable() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isReachable; }
qdbus_dev_paired() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" org.kde.kdeconnect.device.isTrusted; }
qdbus_dev_battery() { _qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1/battery" org.kde.kdeconnect.device.battery.charge 2>/dev/null; }

###############
### Helpers ###

dev_is_reachable() { kdeconnect-cli --device "$1" --is-reachable >/dev/null 2>&1; }
dev_is_paired() { kdeconnect-cli --device "$1" --encryption-info >/dev/null 2>&1; }

status_line() {
	local id name bat

	if have_qdbus; then
		# first reachable + paired (qdbus)
		while IFS= read -r id; do
			[[ -z "$id" ]] && continue

			if [[ "$(qdbus_dev_reachable "$id")" == "true" && "$(qdbus_dev_paired "$id")" == "true" ]]; then
				name="$(qdbus_dev_name "$id" 2>/dev/null || echo "$id")"
				bat="$(qdbus_dev_battery "$id" | grep -Eo '[0-9]+' || true)"

				if [[ -n "$bat" ]]; then
					printf '%%{T%s}%s%%{T%s}%s%s %s%%%s\n' "$FONT_ICON" "$ICON_PHONE" "$FONT_TEXT" "$SEP" "$name" "$bat" "$SEP"
				else
					printf '%%{T%s}%s%%{T%s}%s%s\n' "$FONT_ICON" "$ICON_PHONE" "$FONT_TEXT" "$SEP" "$name"
				fi
				return
			fi
		done < <(qdbus_list_ids)

		# no reachable/paired: display offline (if exists)
		id="$(qdbus_list_ids | head -n1 || true)"
		if [[ -n "$id" ]]; then
			name="$(qdbus_dev_name "$id" 2>/dev/null || echo "$id")"
			printf '%%{T%s}%s%%{T%s}%s%s (offline)\n' "$FONT_ICON" "$ICON_DISCON" "$FONT_TEXT" "$SEP" "$name"
			return
		fi
		printf '%%{T%s}%s%%{T%s}%sno device\n' "$FONT_ICON" "$ICON_DISCON" "$FONT_TEXT" "$SEP"
		return
	fi

	# fallback kdeconnect-cli (slower)
	local cli_id
	cli_id="$(kdeconnect-cli --list-available --id-only 2>/dev/null | head -n1 || true)"

	if [[ -n "$cli_id" ]]; then
		name="$(kdeconnect-cli --device "$cli_id" --name 2>/dev/null || echo "$cli_id")"
		bat="$(kdeconnect-cli --device "$cli_id" --battery 2>/dev/null | grep -Eo '[0-9]+' | head -n1 || true)"

		if [[ -n "$bat" ]]; then
			printf '%%{T%s}%s%%{T%s}%s%s %s%%%s\n' "$FONT_ICON" "$ICON_PHONE" "$FONT_TEXT" "$SEP" "$name" "$bat" "$SEP"
		else
			printf '%%{T%s}%s%%{T%s}%s%s\n' "$FONT_ICON" "$ICON_PHONE" "$FONT_TEXT" "$SEP" "$name"
		fi
		return
	fi

	# no reachable devices
	name="$(kdeconnect-cli --list-devices --name-only 2>/dev/null | head -n1 || true)"
	if [[ -n "$name" ]]; then
		printf '%%{T%s}%s%%{T%s}%s%s (offline)\n' "$FONT_ICON" "$ICON_DISCON" "$FONT_TEXT" "$SEP" "$name"
	else
		printf '%%{T%s}%s%%{T%s}%sno device\n' "$FONT_ICON" "$ICON_DISCON" "$FONT_TEXT" "$SEP"
	fi
}

#########################################
### Rofi: dmenu helpers - run @ click ###

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

list_all_structured() {
	#DISPLAY|ID|PAIRED|REACHABLE
	local id name paired reachable display
	if have_qdbus; then
		while IFS= read -r id; do
			[[ -z "$id" ]] && continue
			name="$(qdbus_dev_name "$id" 2>/dev/null || echo "$id")"
			[[ "$(qdbus_dev_paired "$id")" == "true" ]] && paired=1 || paired=0
			[[ "$(qdbus_dev_reachable "$id")" == "true" ]] && reachable=1 || reachable=0
			if ((paired == 1 && reachable == 1)); then
				display="connected ${name}"
			elif ((paired == 1)); then
				display="paired ${name}"
			else
				display="available ${name}"
			fi
			printf '%s|%s|%s|%s\n' "$display" "$id" "$paired" "$reachable"
		done < <(qdbus_list_ids)
		return
	fi

	# kdeconnect-cli (slower)
	local ids names i
	mapfile -t ids < <(kdeconnect-cli --list-devices --id-only 2>/dev/null || true)
	mapfile -t names < <(kdeconnect-cli --list-devices --name-only 2>/dev/null || true)

	for i in "${!ids[@]}"; do
		id="${ids[$i]}"
		name="${names[$i]:-$id}"
		dev_is_paired "$id" && paired=1 || paired=0
		dev_is_reachable "$id" && reachable=1 || reachable=0
		if ((paired == 1 && reachable == 1)); then
			display="connected ${name}"
		elif ((paired == 1)); then
			display="paired ${name}"
		else
			display="available ${name}"
		fi
		printf '%s|%s|%s|%s\n' "$display" "$id" "$paired" "$reachable"
	done
}

device_actions_menu() {
	local id="$1" name="$2" paired="$3" reachable="$4"
	local sel
	if ((paired == 1)); then
		sel="$(printf '%s\n' \
			"Ping" "Find Device" "Send File" "Share Clipboard" "Share Text" "Browse Files" "Unpair" |
			choose "$name")" || exit 0
		case "$sel" in
		"Ping") kdeconnect-cli --device "$id" --ping ;;
		"Find Device") kdeconnect-cli --device "$id" --ring ;;
		"Send File")
			f="$(pick_file)"
			[[ -n "${f:-}" ]] && kdeconnect-cli --device "$id" --share "file://$f"
			;;
		"Share Clipboard")
			t="$(clip_text)"
			[[ -n "${t:-}" ]] && kdeconnect-cli --device "$id" --share-text "$t"
			;;
		"Share Text")
			f="$(pick_file)"
			[[ -n "${f:-}" ]] && kdeconnect-cli --device "$id" --share-text "$t"
			;;
		"Browse Files") xdg-open "kdeconnect://$id/" >/dev/null 2>&1 || kdeconnect-app & ;;
		"Unpair") kdeconnect-cli --device "$id" --unpair ;;
		*) : ;;
		esac
	else
		sel="$(printf '%s\n' "Pair Device" "Cancel" | choose "$name")" || exit 0
		[[ "$sel" == "Pair Device" ]] && kdeconnect-cli --device "$id" --pair
	fi
}

main_menu() {
	local lines choice line id name paired reachable
	# build list
	mapfile -t lines < <(list_all_structured)

	# Extra opts
	if ((${#lines[@]} == 0)); then
		choice="$(printf '%s\n' "Refresh" "Open KDE Connect" | choose 'KDE Connect')" || exit 0
		[[ "$choice" == "Refresh" ]] && {
			kdeconnect-cli --refresh >/dev/null 2>&1 || true
			exec "$0" --menu
		}
		[[ "$choice" == "Open KDE Connect" ]] && kdeconnect-app &
		exit 0
	fi

	choice="$(
		{
			printf '%s\n' "${lines[@]}"
			echo "Refresh|_|0|0"
		} |
			sort -r |
			cut -d'|' -f1 |
			choose "Devices"
	)" || exit 0

	[[ -z "$choice" ]] && exit 0

	line="$(printf '%s\n' "${lines[@]}" | grep -F "^$choice|" | head -n1)"
	id="$(cut -d'|' -f2 <<<"$line")"
	paired="$(cut -d'|' -f3 <<<"$line")"
	reachable="$(cut -d'|' -f4 <<<"$line")"

	name="${choice#connected }"
	name="${name#paired }"
	name="${name#available }"

	device_actions_menu "$id" "$name" "$paired" "$reachable"
}

case "${1:-}" in
--menu) main_menu ;;
*) status_line ;;
esac
