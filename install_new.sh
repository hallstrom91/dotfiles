#!/usr/bin/env bash

# https://linuxcommand.org/lc3_man_pages/testh.html
# https://man7.org/linux/man-pages/man1/ln.1.html
set -euo pipefail
IFS=$'\n\t'

# ENV (DF = DOTFILES)
DF_DRYRUN=0
DF_VERBOSE=0
DF_ONLY=""
declare -A DF_SEEN_DIR=()

# Guard
[[ -n "${BASH_VERSION-}" ]] || {
	# ensure bash
	# echo "Please run with bash"
	printf '%s\n' "Run with bash" >&2
	exit 2
}

# logs
log() { printf '%s\n' "$*"; }
vlog() { ((DF_VERBOSE)) && printf '%s\n' "$*"; }

# fail
exit_fail() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

# runner
run() {
	if ((DF_DRYRUN)); then
		printf '[dry_run] '
		printf '%q ' "$@"
		printf '\n'
		return 0
	fi

	if ((DF_VERBOSE)); then
		printf '[run] '
		printf '%q ' "$@"
		printf '\n'
	fi

	"$@"
}

# ensure directories
ensure_dir() {
	local d="$1"
	d="${d%/}"

	# real dir? use
	[[ -d "$d" && ! -L "$d" ]] && return 0

	# dry-run: dont repeat mkdir/rm spam
	if ((DF_DRYRUN)); then
		[[ -n "${DF_SEEN_DIR["$d"]+x}" ]] && return 0
		DF_SEEN_DIR["$d"]=1
	fi

	# symlink dir? remove
	if [[ -L "$d" ]]; then
		run rm -f -- "$d"
	fi

	run mkdir -p -- "$d"
}

# path checker
abspath() {
	local p="$1"
	if [[ "$p" == /* ]]; then
		printf '%s\n' "$p"
		return 0
	fi
	printf '%s/%s\n' "$(pwd -P)" "$p"
}

# flag match: '--only <relative-path>'
only_match() {
	[[ -z "$DF_ONLY" ]] && return 0
	[[ "$1" == "$DF_ONLY" ]] || [[ "$1" == "$DF_ONLY/"* ]]
}

# symlink target check
sl_target() {
	local dst="$1" src="$2"
	[[ -L "$dst" ]] || return 1
	command -v readlink >/dev/null 2>&1 || return 1 # readlink required

	local t
	t="$(readlink -- "$dst")" || return 1

	if [[ "$t" != /* ]]; then
		t="$(cd -- "$(dirname -- "$dst")" && printf '%s/%s\n' "$(pwd -P)" "$t")"
	fi

	[[ "$(abspath "$t")" == "$(abspath "$src")" ]]
}

# link
link_one() {
	local src="$1" dst="$2"
	ensure_dir "$(dirname -- "$dst")"

	# target check
	if sl_target "$dst" "$src"; then
		# vlog "ok: $dst"
		return 0
	fi

	# if dst is symlink (working or broken), replace.
	if [[ -L "$dst" ]]; then
		vlog "replace symlink: $dst"
		run rm -f -- "$dst"
	# if dst is real file/dir, fail.
	elif [[ -e "$dst" ]]; then
		if ((DF_DRYRUN)); then
			printf '%s\n' "conflict (dry-run): real path exists: $dst (would refuse overwrite)"
			return 0
		fi
		exit_fail "conflict, real path exists: $dst (refusing overwrite)"
	fi

	vlog "ln: $dst -> $src"
	run ln -s -- "$src" "$dst" # replaces 'broken' symlink?
}

# install
install_tree() {
	local src_root="$1" dst_root="$2"
	[[ -d "$src_root" ]] || return 0

	shopt -s dotglob nullglob globstar

	local p rel src dst
	for p in "$src_root"/**; do
		[[ -e "$p" || -L "$p" ]] || continue

		rel="${p#"$src_root"/}"

		# --only flag ?
		only_match "$(basename "$src_root")/$rel" || continue

		src="$p"
		dst="$dst_root/$rel"

		# create dirs as 'real' dirs, no sl.
		if [[ -d "$src" && ! -L "$src" ]]; then
			ensure_dir "$dst"
			continue
		fi

		link_one "$src" "$dst"
	done

	shopt -u dotglob nullglob globstar
}

install_children() {

	local src_root="$1" dst_root="$2"
	[[ -d "$src_root" ]] || return 0

	# shopt -s dotglob nullglob globstar
	shopt -s dotglob nullglob

	local p name src dst
	for p in "$src_root"/*; do
		[[ -e "$p" || -L "$p" ]] || continue
		name="$(basename -- "$p")"

		# --only flag ?
		only_match "$(basename "$src_root")/$name" || continue

		src="$p"
		dst="$dst_root/$name"

		# # create dirs as 'real' dirs, no sl.
		# if [[ -d "$src" && ! -L "$src" ]]; then
		# 	ensure_dir "$dst"
		# 	continue
		# fi

		link_one "$src" "$dst"
	done

	shopt -u dotglob nullglob

}

parse_args() {
	while (($#)); do
		case "$1" in
		--dry-run) DF_DRYRUN=1 ;;
		--verbose) DF_VERBOSE=1 ;;
		--only)
			shift
			[[ $# -gt 0 ]] || exit_fail "--only requires argument"
			DF_ONLY="${1%/}"
			;;
		-h | --help)
			usage
			exit 0
			;;
		*) exit_fail "unknown flag: $1" ;;
		esac
		shift
	done
}

main() {
	parse_args "$@"

	local script_dir df_rootdir
	script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
	df_rootdir="${DF_ROOTDIR:-$script_dir}"

	local xdg_config xdg_data local_bin
	xdg_config="${XDG_CONFIG_HOME:-"$HOME/.config"}"
	xdg_data="${XDG_DATA_HOME:-"$HOME/.local/share"}"
	local_bin="${LOCAL_BIN:-"$HOME/.local/bin"}"

	ensure_dir "$xdg_config"
	ensure_dir "$xdg_data"
	ensure_dir "$local_bin"

	install_tree "$df_rootdir/home" "$HOME"
	# install_tree "$df_rootdir/config" "$xdg_config"
	install_children "$df_rootdir/config" "$xdg_config"
	install_tree "$df_rootdir/data" "$xdg_data"
	install_tree "$df_rootdir/bin" "$local_bin"

	log "Done."
}

main "$@"
