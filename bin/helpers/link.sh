#shellcheck shell=bash
[[ -n ${LINK_LOADED-} ]] && return 0
LINK_LOADED=1

require logs
require cmdrunner
require fs
require backup
require repo_guard

LINK_OK=0        # exist and ok
LINK_CREATED=1   # create new
LINK_REPLACE=2   # wrong/broken replaced
LINK_OVERWROTE=3 # file/dir (non sl) overwritten.

: "${NO_BAK:=0}" # 1 = write over files/dirs without backup
: "${BACKUP_ROOT:=$HOME/.local/state/dotfiles/backups}"

link::ensure() {
	local src=$1 dst=$2

	local dot_root dst_dir_abs dst_abs
	dot_root="$(readlink -f -- "${DOTFILES}")" || return 3
	dst_dir_abs="$(readlink -f -- "$(dirname -- "$dst")")" || return 3
	dst_abs="${dst_dir_abs}/$(basename -- "$dst")"

	if [[ "$dst_abs" == "$dot_root"* ]]; then
		logger::fail "refusing to create symlink inside repo: $dst_abs"
		return 3
	fi

	[[ -z $src || -z $dst ]] && {
		logger::fail "usage: link::ensure SRC $(logger::arrow) DST"
		return 2
	}

	# policys
	repo::assert_inside "$src" || return 1  # only out from dotfiles
	repo::assert_outside "$dst" || return 1 # never in to dotfiles

	# already correct ?
	if fs::is_symlink_to "$src" "$dst"; then
		logger::success "Symlink is valid and correct: $src $(logger::arrow) $dst"
		return "$LINK_OK"
	fi

	fs::mkparent "$dst"

	# target exists?
	if [[ -e $dst || -L $dst ]]; then
		if [[ -L $dst ]]; then
			if ((NO_BAK == 1)); then
				logger::warn "Overwriting broken/wrong symlink: $dst"
				fs::safe_rm "$dst" || return $?
			else
				backup::optional "$dst" "$BACKUP_ROOT" || {
					# exit-code: 65 = skipped (NO_BAK), # 66 = no such file - continue anyways
					local rc=$?
					((rc == 65 || rc == 66)) || return $rc
				}
			fi
			cmd::run ln -s -- "$src" "$dst" || return $?
			return "$LINK_REPLACE"
		else
			# ordinary file/dir
			if ((NO_BAK == 1)); then
				logger::warn "Overwriting without backup: $dst"
				fs::safe_rm "$dst" || return $?
				cmd::run ln -s -- "$src" "$dst" || return $?
				return "$LINK_OVERWROTE"
			else
				backup::optional "$dst" "$BACKUP_ROOT" || {
					local rc=$?
					((rc == 65 || rc == 66)) || return $rc
				}
				cmd::run ln -s -- "$src" "$dst" || return $?
				return "$LINK_OVERWROTE"
			fi
		fi
	fi

	# or just create (new) symlink
	cmd::run ln -s -- "$src" "$dst" || return $?
	return "$LINK_CREATED"
}
