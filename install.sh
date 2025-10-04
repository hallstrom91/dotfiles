#!/usr/bin/env bash
set -Euo pipefail

###################################
### global cfg-flags + defaults ###
DRY_RUN=0               # OFF
VERBOSE=0               # OFF
NO_BAK=1                # OFF (later ON BY DEFAULT)
ICONS=1                 # ON (requires nerdfonts)
COLOR=1                 # ON
ONLY="all"              # all|home|config|data|bin
DOTFILES="${DOTFILES-}" # set env or autodetect
HOST_KIND=""            # "", "desktop" or "laptop"

[[ -n "${BASH_VERSION-}" ]] || {
	# ensure bash
	echo "Please run with bash"
	exit 2
}

#################################
### path discover / constants ###
if [[ -z ${DOTFILES-} ]]; then
	# set repo-root if empty
	DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
fi

if [[ ! -d "$DOTFILES" ]]; then
	# no $DOTFILES value
	echo "Can't find '$DOTFILES'. Use flag: --root /path/to/dotfiles"
	exit 1
fi

###################################
### require mods/module-helpers ###
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

require logs       # logger::info, logger::warn, logger::fail, logger::success, logger::verbose
require cmdrunner  # cmd::run, cmd::capture,
require fs         # fs::mkparent, fs::safe_rm, fs::is_symlink_to
require backup     # backup::one, backup::optional
require repo_guard # repo::assert_inside, repo::assert_outside
require link       # link::ensure
require copy       # copy::file, copy::tree

#############################
### export required flags ###
# propagate flags to modules
# module usage:
# : "${VAR:=default}"
export DRY_RUN VERBOSE NO_BAK ICONS COLOR

############################
### usage + args-parsing ###
usage() {
	local self="${0##*/}"
	cat <<-TOP
		$self - installer for dotfiles repository

		Usage:
		$self [flags]

		Flags:
	TOP
	printf " %-18s %s\n" "-r, --root PATH" "Set DOTFILES (repo-root)."
	printf " %-18s %s\n" "-n, --dry-run" "Run without write"
	printf " %-18s %s\n" "-v, --verbose" "Extra logs (debug)"
	printf " %-18s %s\n" "    --no-bak" "Skip backup of existing target (default: off)"
	printf " %-18s %s\n" "    --icons 0|1" "Icons in logs (default: 1)"
	printf " %-18s %s\n" "    --color 0|1" "Color in logs (default: 1)"
	printf " %-18s %s\n" "    --only SET" "home|config|data|bin|all (default: all)"
	printf " %-18s %s\n" "    --host KIND" "desktop|laptop (override autodetect)"
	printf " %-18s %s\n" "-h, --help" "Show help."
}

# args parsing
while (($#)); do
	case "${1:-}" in
	-r | --root)
		DOTFILES="$2"
		shift 2
		;;
	-n | --dry-run)
		DRY_RUN=1
		shift
		;;
	-v | --verbose)
		VERBOSE=1
		shift
		;;
	--no-bak)
		NO_BAK=1
		shift
		;;
	--icons)
		ICONS="$2"
		shift 2
		;;
	--color)
		COLOR="$2"
		shift 2
		;;
	--only)
		ONLY="$2"
		shift 2
		;;
	--host)
		HOST_KIND="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	--)
		shift
		break
		;;
	-*)
		echo "Unknown option: $1" >&2
		usage
		exit 2
		;;
	*) break ;;
	esac
done

############################
### source / target tree ###

SRC_HOME="$DOTFILES/home"
SRC_CONFIG="$DOTFILES/config"
SRC_DATA="$DOTFILES/data"
SRC_BIN="$DOTFILES/bin"

TARGET_HOME="$HOME"
TARGET_BIN="$TARGET_HOME/.bin"
TARGET_CONFIG="$TARGET_HOME/.config"
TARGET_DATA="$TARGET_HOME/.local/share"

#######################
### Local Functions ###
link_tree() {
	local src_root=$1 dst_root=$2 what=$3
	shift 3
	local -a skip_globs=("$@") # optional globpattern to skip

	# repo/dst guards
	local dot_root src_abs dst_abs
	dot_root="$(readlink -f -- "${DOTFILES}")" || return 3
	src_abs="$(readlink -f -- "${src_root}")" || return 3
	dst_abs="$(readlink -f -- "${dst_root}")" || return 3

	# source MUST be inside repo
	if [[ "$src_abs" != "$dot_root"* ]]; then
		logger::fail "source not in DOTFILES: $src_abs"
		return 3
	fi

	# dst NEVER inside repo
	if [[ "$dst_abs" == "$dot_root" ]]; then
		logger::fail "destination inside DOTFILES: $dst_abs"
		return 3
	fi

	[[ -d $src_root ]] || {
		logger::fail "Skip $what: no dir $src_root"
		return 0
	}

	logger::info "Link $what: $src_root $(logger::arrow) $dst_root"

	shopt -s globstar nullglob dotglob
	local src rel dst rc pat

	for src in "$src_root"/**; do
		[[ -e $src || -L $src ]] || continue  # broken symlinks include?
		[[ $src == "$src_root" ]] && continue # skip dir-root copy

		rel="${src#"$src_root"/}"

		for pat in "${skip_globs[@]}"; do
			[[ -z $pat ]] && continue
			# shellcheck disable=SC2254
			case "$rel" in
			"$pat") continue 2 ;; # match globpattern and skip file
			esac
		done

		# if dir, create dst_root (no sl to dir)
		if [[ -d $src && ! -L $src ]]; then
			dst="$dst_root/$rel"
			fs::mkparent "$dst"
			continue
		fi

		# files and symlinks -> create sl in dst
		dst="$dst_root/$rel"
		link::ensure "$src" "$dst"
		rc=$?
		if ((rc > 3)); then
			logger::fail "link error ($rc): $src $(logger::arrow) $dst"
			shopt -u globstar dotglob nullglob
			return $rc
		fi
	done

	shopt -u globstar dotglob nullglob
}

# link src: wezterm/configs/{host}.lua
# to dst: ~/.config/wezterm/wezterm.lua
link_wezterm_for_host() {
	local kind=$1
	local src="$SRC_CONFIG/wezterm/configs/$kind.lua"
	local dst="$TARGET_CONFIG/wezterm/wezterm.lua"

	if [[ ! -r $src ]]; then
		logger::fail "wezterm: missing source for host '$kind': $src"
		return 1
	fi
	fs::mkparent "$dst"
	logger::info "wezterm cfg: $src $(logger::arrow) $dst"
	link::ensure "$src" "$dst"
	return $?
}

# link src: kitty/configs/${host}.conf
# to dst: ~/.config/wezterm/kitty.conf
link_kitty_for_host() {
	local kind=$1
	local src="$SRC_CONFIG/kitty/configs/$kind.conf"
	local dst="$TARGET_CONFIG/kitty/kitty.conf"

	if [[ ! -r $src ]]; then
		logger::fail "kitty: missing source for host '$kind': $src"
		return 1
	fi
	fs::mkparent "$dst"
	logger::info "kitty cfg: $src $(logger::arrow) $dst"
	link::ensure "$src" "$dst"
	return $?
}

host::_infer() {
	local hn="${HOSTNAME-}" # try use $HOSTNAME var
	if [[ -z $hn ]]; then
		hn="$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf '')"
	fi

	hn="${hn,,}" # lowercase

	case "$hn" in
	desktop | *desk*) printf '%s' 'desktop' ;;
	laptop | *lap*) printf '%s' 'laptop' ;;
	*) printf '%s' '' ;;
	esac
}

host::resolve() {
	local kind=$1 inferred
	if [[ $kind == "desktop" || $kind == "laptop" ]]; then
		printf '%s' "$kind"
		return 0
	fi
	inferred="$(host::_infer)"
	if [[ -n $inferred ]]; then
		logger::info "Detected host kind: $inferred"
		printf '%s' "$inferred"
		return 0
	fi
	logger::warn "Could not infer host kind; defaulting to 'desktop'. Use --host to override"
	printf '%s' 'desktop'
}

fonts::_fccache() {
	# collect possible font-dirs (current)
	local -a dirs=()

	[[ -d "$TARGET_DATA/fonts" ]] && dirs+=("$TARGET_DATA/fonts")
	[[ -d "$TARGET_DATA/.fonts" ]] && dirs+=("$TARGET_HOME/.fonts") # fallback

	if ((${#dirs[@]} == 0)); then
		logger::verbose "No user font directories found: skipping fc-cache"
		return 0
	fi

	local -a prefix=()
	# installed script run as sudo?
	if [[ ${EUID:-$(id -u)} -eq 0 && -n ${SUDO_USER-} ]]; then
		prefix=(sudo -u "$SUDO_USER")
	fi

	if ! command -v fc-cache >/dev/null 2>&1; then
		logger::warn "fc-cache not found: skipping font cache rebuild"
	fi

	#
	if cmd::run "${prefix[@]}" fc-cache -f -- "${dirs[@]}"; then
		logger::success "font cache rebuilt for: ${dirs[*]}"
	else
		logger::fail "fc-cache failed for: ${dirs[*]}"
	fi
}

##################
##### main() #####
##################
main() {
	logger::info "DOTFILES=$DOTFILES"
	logger::info "DRY_RUN=$DRY_RUN VERBOSE=$VERBOSE NO_BAK=$NO_BAK ICONS=$ICONS COLOR=$COLOR"

	local KIND
	KIND="$(host::resolve "$HOST_KIND")" || return $?
	logger::info "Using host kind: $KIND"

	local -a CONFIG_SKIP=('wezterm/configs/**' 'kitty/configs/**') # skip  wezterm,kitty main-cfgs
	local -a DATA_SKIP=('fonts/**' "icons/**")                     # skip fonts,icons

	case "$ONLY" in
	all)
		link_tree "$SRC_HOME" "$TARGET_HOME" "home"
		link_tree "$SRC_CONFIG" "$TARGET_CONFIG" "config" "${CONFIG_SKIP[@]}"
		link_tree "$SRC_DATA" "$TARGET_DATA" "data" "${DATA_SKIP[@]}"
		link_tree "$SRC_BIN" "$TARGET_BIN" "bin"
		# host-specific links (laptop|desktop)
		link_wezterm_for_host "$KIND" || return $?                               # sl {desktop,laptop}.lua -> ~/.config/wezterm/wezterm.lua
		link_kitty_for_host "$KIND" || return $?                                 # sl {desktop,laptop}.conf -> ~/.config/kitty/kitty.conf
		copy::tree "$SRC_DATA/fonts" "$TARGET_DATA/fonts" 0644 0755 || return $? # copy fonts to dst (no sl)
		copy::tree "$SRC_DATA/icons" "$TARGET_DATA/icons" 0644 0755 || return $? # copy icons to dst (no sl)
		# rebuild font cache
		fonts::_fccache
		;;
	home) link_tree "$SRC_HOME" "$TARGET_HOME" "home" ;;
	config)
		# logs::info "Installing dotfiles/config tree"
		link_tree "$SRC_CONFIG" "$TARGET_CONFIG" "config" "${CONFIG_SKIP[@]}"
		link_wezterm_for_host "$KIND" || return $?
		link_kitty_for_host "$KIND" || return $?
		;;
	data)
		link_tree "$SRC_DATA" "$TARGET_DATA" "data" "${DATA_SKIP[@]}"
		copy::tree "$SRC_DATA/fonts" "$TARGET_DATA/fonts" 0644 0755 || return $?
		copy::tree "$SRC_DATA/icons" "$TARGET_DATA/icons" 0644 0755 || return $?
		# add call to fonts::_fccache if anything changed ?
		fonts::_fccache
		;;
	bin) link_tree "$SRC_BIN" "$TARGET_BIN" "bin" ;;
	*)
		logger::fail "Unknown --only set: $ONLY"
		return 2
		;;
	esac

	logger::success "Done."
}

main "$@"
