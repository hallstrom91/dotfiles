#shellcheck shell=bash
[[ -n ${BACKUP_LOADED-} ]] && return 0
BACKUP_LOADED=1

require logs
require cmdrunner

# Return codes:
#BACKUP_CREATED=0  # 0 = backup created (ok)
BACKUP_SKIPPED=65 # 65 = backup skipped (NO_BAK=1)
BACKUP_MISSING=66 # 66 = missing path / non to backup

: "${NO_BAK:=0}"                                        # 1 = skip backup (backup::optional)
: "${BACKUP_ROOT:=$HOME/.local/state/dotfiles/backups}" # default backup dir

# time stamp (internal)
backup::_stamp() {
	date +%Y%m%d_%H%M
}

# Calc target for backup (internal)
backup::_resolve_dst() {
	local path=$1 root=${2-} ts base
	ts=$(backup::_stamp)

	if [[ -z $root ]]; then
		printf '%s.%s.bak' "$path" "$ts"
		return
	fi

	# $root set? move backup to root-path.
	mkdir -p -- "$root"
	base=$(basename -- "$path")
	printf '%s/%s.%s.bak' "$root" "$base" "$ts"
}

# forced backup: move path to .bak
# usage: backup::one <path> [<backup_root>]
backup::one() {
	local path=$1 root=${2-} bak

	[[ -e $path || -L $path ]] || {
		logger::warn "No such file to backup: $path"
		return "$BACKUP_MISSING"
	}

	bak=$(backup::_resolve_dst "$path" "$root")
	logger::warn "Backup: $path $(logger::arrow) $bak"
	cmd::run mv -- "$path" "$bak"
}

# optional backup: respect NO_BAK=1 (or explicit flag)
# usage: backup::optional <path> [<backup_root>]
backup::optional() {
	local path=$1 root=${2-}
	((NO_BAK == 1)) && {
		logger::warn "Skipping backup (NO_BAK=1): $path"
		return "$BACKUP_SKIPPED"
	}
	backup::one "$path" "$root"
}
