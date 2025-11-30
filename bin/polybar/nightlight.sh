#!/usr/bin/env bash

# ----- Config ----- #

# process-name : show "nightlight" in htop/btop/ps
if [[ "${NL_REEXECED:-0}" != 1 ]]; then
	export NL_REEXECED=1
	SELF="$(readlink -f -- "$0" 2>/dev/null || realpath -- "$0" 2>/dev/null || printf '%s\n' "$0")"
	exec -a nightlight "${BASH:-/bin/bash/env bash}" "$SELF" "$@"
fi

# get display name value: 'xrandr --output'
NL_OUTPUTS=(DP-2 DP-0)

# xrandr-profiles (RGB-gamma)
NL_NORMAL_GAMMA="1:1:1"
NL_NIGHT_GAMMA="1.0:0.85:0.70"

# gammastep (if installed) settings
NL_TEMP_K="${NL_TEMP_K:-4500}" # kelvin nightlight
NL_GAMMASTEP_METHOD="randr"    # x11 / i3

# Method: 'xrandr' as default or 'gammastep'
NL_METHOD="${NL_METHOD:-xrandr}"

# Polyar Icons:
NL_IC_NORMAL="" # nf-oct-sun
NL_IC_NIGHT=""  # nf-oct-moon
NL_ICON_FONT="${ICON_FONT:-4}"

NL_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/polybar"
mkdir -p "$NL_STATE_DIR"
NL_STATE_FILE="$NL_STATE_DIR/nightlight.state"
NL_PID_FILE="$NL_STATE_DIR/nightlight.pid"

# ----- Helpers ----- #
nl_is_on() { [[ -f "$NL_STATE_FILE" ]]; }

nl_apply_xrandr_on() {
	for out in "${NL_OUTPUTS[@]}"; do
		xrandr --output "$out" --gamma "$NL_NIGHT_GAMMA"
	done
}

nl_apply_xrandr_off() {
	for out in "${NL_OUTPUTS[@]}"; do
		xrandr --output "$out" --gamma "$NL_NORMAL_GAMMA"
	done
}

nl_apply_gammastep_on() {
	(
		gammastep -m "$NL_GAMMASTEP_METHOD" -O "$NL_TEMP_K" &
		echo $! >"$NL_PID_FILE"
	) >/dev/null 2>&1
}

nl_apply_gammastep_off() {
	if [[ -f "$NL_PID_FILE" ]]; then
		kill "$(cat "$NL_PID_FILE")" 2>/dev/null || true
		rm -f "$NL_PID_FILE"
	fi
	gammastep -m "$NL_GAMMASTEP_METHOD" -x >/dev/null 2>&1 || true
}

### main funcs

nl_set_on() {
	if [[ "$NL_METHOD" == "gammastep" ]]; then
		nl_apply_gammastep_on
	else
		nl_apply_xrandr_on
	fi
	echo on >"$NL_STATE_FILE"
}

nl_set_off() {
	if [[ "$NL_METHOD" == "gammastep" ]]; then
		nl_apply_gammastep_off
	else
		nl_apply_xrandr_off
	fi
	rm -f "$NL_STATE_FILE"
}

nl_toggle() {
	if nl_is_on; then
		nl_set_off
	else
		nl_set_on
	fi
}

nl_print_icon() {
	if nl_is_on; then
		printf '%%{T%s}%s%%{T-}\n' "$NL_ICON_FONT" "$NL_IC_NIGHT" # nightlight: 'moon icon'
		# echo "$IC_NORMAL"
	else
		printf '%%{T%s}%s%%{T-}\n' "$NL_ICON_FONT" "$NL_IC_NORMAL" # normal: 'sun icon'
	# echo "$IC_NIGHT"
	fi
}

case "${1:-}" in
--on) nl_set_on ;;
--off) nl_set_off ;;
--toggle) nl_toggle ;;
--status | *) nl_print_icon ;;
esac
