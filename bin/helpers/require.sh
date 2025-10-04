# shellcheck shell=bash
[[ -n ${__REQUIRE_LOADED-} ]] && return 0
__REQUIRE_LOADED=1

declare -gA __REQUIRED=()
require() {
	local mod="$1" path root helpers
	root="${DOTFILES:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)}"
	helpers="$root/bin/helpers"

	# allow "require logs" OR "require logs.sh"
	for ext in "" ".sh"; do
		path="$helpers/${mod}${ext}"
		if [[ -f "$path" && -r "$path" ]]; then
			[[ -n ${__REQUIRED[$path]-} ]] && return 0
			__REQUIRED[$path]=1
			# shellcheck source=/dev/null
			source "$path"
			return 0
		fi
	done

	echo "require: module not found: $mod" >&2
	exit 127
}
#
# # Search for modules to load
# : "${DOTFILES:?must set DOTFILES (e.g, export DOTFILES=$HOME)}"
#
# __LIB_DIRS=(
# 	"$DOTFILES/bin/helpers"
# 	"$DOTFILES/helpers" # remove ? always under bin/helpers/*.sh
# )
#
# # map of loaded modules
# declare -Ag __LOADED_MODS=()
#
# require() {
# 	local mod=$1 d cand
# 	[[ -z $mod ]] && {
# 		printf 'require: missing module name\n' >&2
# 		return 2
# 	}
#
# 	[[ -n ${__LOADED_MODS[$mod]-} ]] && return 0
#
# 	# Find file: "logs" -> "logs.sh"
# 	for d in "${__LIB_DIRS[@]}"; do
# 		for cand in "$d/$mod.sh" "$d/$mod"; do
# 			if [[ -r $cand ]]; then
# 				# shellcheck source=/dev/null
# 				source "$cand"
# 				__LOADED_MODS[$mod]=1
# 				return 0
# 			fi
# 		done
# 	done
#
# 	printf 'require: module not found %s\n' "$mod" >&2
# 	return 127 # 127 meaning ?
# }
