#!/usr/bin/env bash

DIR="$HOME/Pictures/screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +'%Y-%m%d_%H-%M-%S').png"

_need() {
	command -v "$1" >/dev/null 2>&1 || {
		printf 'error: missing dependency: %s\n' "$1" >&2
		exit 127
	}
}

_copy_png_stdin() {
	_need wl-copy
	wl-copy --type image/png
}

_shot_region() {
	_need grim
	_need slurp

	local geom
	geom="$(slurp)" || exit 0

	grim -g "$geom" - | tee "$FILE" | _copy_png_stdin >/dev/null

}

_shot_fullscreen() {
	_need grim
	grim - | tee "$FILE" | _copy_png_stdin >/dev/null
}

_shot_window() {
	_need grim
	_need slurp

	local geom
	geom="$(slurp -w)" || exit

	grim -g "$geom" - | tee "$FILE" | _copy_png_stdin >/dev/null
}

_usage() { printf '%s\n' "Usage: $(basename "$0") [--region|--fullscreen|--window]"; }

case "${1:---help}" in
--region) _shot_region ;;
--fullscreen) _shot_fullscreen ;;
--window) _shot_window ;;
-h | --help) _usage ;;
*) exit 0 ;; # dont do nothing if no option flag

esac
