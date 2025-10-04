#shellcheck shell=bash
[[ -n ${FS_LOADED-} ]] && return 0
FS_LOADED=1

require logs
require cmdrunner

# create parentdir (exists? no-op.)
fs::mkparent() {
	local path=$1
	mkdir -p -- "$(dirname -- "$path")"
}

fs::safe_rm() {
	local target=$1
	# simple policy | TODO: Extend ?
	[[ -z $target || $target == "/" ]] && {
		logger::fail "Refusing to remove '$target'"
		return 64
	}
	cmd::run rm -rf -- "$target"
}

# is dst symlink -> exact src ?
fs::is_symlink_to() {
	local src=$1 dst=$2
	[[ -L $dst ]] || return 1
	local t
	t=$(readlink -- "$dst")
	[[ $t == "$src" ]]
}
