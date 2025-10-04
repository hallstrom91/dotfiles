#shellcheck shell=bash
[[ -n ${REPO_GUARD_LOADED-} ]] && return 0
REPO_GUARD_LOADED=1

require logs

# add envs for paths in env or main-script
# expects DOTFILES, SRC_HOME, SRC_CONFIG, SRC_DATA, SRC_BIN
# to be set by main script
repo::is_inside_dotfiles() {
	local p=$1

	[[ -n ${DOTFILES-} ]] || return 1

	# protect source-tree (dotfiles/ -dir)
	case "$p" in
	"$DOTFILES"/* | "$SRC_CONFIG"/* | "$SRC_DATA"/* | "$SRC_HOME"/* | "$SRC_BIN"/*) return 0 ;;
	*) return 1 ;;
	esac
}

# only link out from repo
# usage: repo::assert_inside "$src" || return 1
repo::assert_inside() {
	local p=$1
	if repo::is_inside_dotfiles "$p"; then
		return 0
	fi
	logger::fail "Path must be inside dotfiles repo: $p"
	return 1
}

# never write into repo{
# usage: repo::assert_outside "$dst" || return 1
repo::assert_outside() {
	local p=$1
	if repo::is_inside_dotfiles "$p"; then
		logger::fail "Refusing to write into dotfiles tree: $p"
		return 1
	fi
	return 0
}
