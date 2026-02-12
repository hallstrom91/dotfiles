#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

## Theme palette ##
declare -A PALETTE=(
	# blue scale (waybar modules)
	[blue5]="0f2e4a"
	[blue4]="144272"
	[blue3]="1b5687"
	[blue2]="205295"
	[blue1]="4a8fd0"

	# purple scale (waybar modules)
	[purple5]="311746"
	[purple4]="371b58"
	[purple3]="4c3575"
	[purple2]="5b4b8a"
	[purple1]="8a7fc0"

	# theme base
	[bg]="1b2430"

	# state colors
	["state-ok"]="7fd889"    # green: ok|success
	["state-info"]="4a8fd0"  # blue: info|connected
	["state-warn"]="f2b24d"  # amber: warn|
	["state-error"]="f44c4c" # red:
	["state-off"]="a8b3c2"   # white/grey "dimmed"

	# foregrounds
	[fg]="f1f1f1"         # white
	["fg-dark"]="0a1f33"  # dark
	["fg-state"]="526d82" # green-blueish??
	["fg-icon"]="dcd7c9"  # beige

)

usage() {
	cat <<'EOF'
	Usage: theme.sh [options]

	Options:
	--output                            Print all stored variables.
	-h, --help                          Show help.

EOF
}
# alpha (opacity) values
# hex=00 | dec=0   = transparent
# hex=80 | dec=128 = ~50%
# hex=cc | dec=204 = ~80%
# hex=ff | dec=255 = 100% (normal)

alpha_hex="ff"  # 00-ff | rgba(rrggbbaa)
alpha_dec="255" # 0-255 | rgba(r,g,b,a)

hex_to_rgb() {
	local h=${1,,}
	printf '%d %d %d\n' \
		"$((16#${h:0:2}))" \
		"$((16#${h:2:2}))" \
		"$((16#${h:4:2}))"
}

print_all() {
	local k hex r g b

	printf '%-12s %-8s %-16s %-24s\n' \
		"[NAME]" "[HEX]" "[RGBA_HEX]" "[RGBA_DEC]"
	for k in "${!PALETTE[@]}"; do
		hex=${PALETTE[$k]}
		IFS=' '
		read -r r g b <<<"$(hex_to_rgb "$hex")"
		printf '%-12s %-8s %-16s %-24s\n' \
			"$k" \
			"#$hex" \
			"rgba(${hex}${alpha_hex})" \
			"rgba($r, $g, $b, $alpha_dec)"

	done
}

print_all
