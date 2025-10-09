# shellcheck shell=bash
[[ -n ${COPY_LOADED-} ]] && return 0
COPY_LOADED=1

require logs
require cmdrunner
require fs
require backup
require repo_guard

# Return codes
COPY_OK=0        # exist and ok
COPY_CREATED=1   # create new
COPY_REPLACE=2   # wrong/broken replaced
COPY_OVERWROTE=3 # non-file (dir/sl/other) overwritten.

: "${DOTFILES:?DOTFILES must be set}"
: "${NO_BAK:=0}"
: "${VERBOSE:=0}"

# prettier paths in logs
_link::shorten() {
	local path=$1
	local df=${DOTFILES-}
	local hm=${HOME-}
	case "$path" in
	"$df"/*)
		printf 'dotfiles/%s\n' "${path#"$df"/}"
		;;
	"$hm"/*)
		printf '~%s\n' "${path#"$hm"}"
		;;
	*) printf '%s\n' "$path" ;;
	esac
}

# copy::file SRC DST [MODE]
copy::file() {
	local src=$1 dst=$2 mode=${3:-0644}

	[[ -n $src && -n $dst ]] || {
		logger::fail "Usage: copy::file SRC $(logger::arrow) DST [MODE]"
		return 64
	}

	repo::assert_inside "$src" || return 1
	repo::assert_outside "$dst" || return 1

	# prettier paths for logs
	# only for usage in loggger::* msgs (not in VERBOSE == 1)
	local src_p dst_p
	src_p=$(_link::shorten "$src")
	dst_p=$(_link::shorten "$dst")

	# source needs to be readable file (follow symlink and copy as file-content (?))
	if [[ ! -e $src ]]; then
		logger::fail "Copy: no such source: $src_p"
		return 66
	fi

	if [[ -d $src && ! -L $src ]]; then
		logger::fail "Copy: SRC is a directory (use copy::tree): $src_p"
		return 65
	fi

	fs::mkparent "$dst"

	# dst exists ?
	if [[ -f $dst ]]; then
		if cmp -s -- "$src" "$dst" 2>/dev/null; then
			logger::verbose "Copy ok (unchanged): $dst"
			return "$COPY_OK"
		fi

		# dst different ? backup (if not NO_BAK)
		backup::optional "$dst" || {
			local rc=$?
			((rc == 65 || rc == 66)) || return "$rc"
		}
		if command -v install >/dev/null 2>&1; then
			cmd::run install -m "$mode" -- "$src" "$dst" || return $?
		else
			cmd::run cp -f -- "$src" "$dst" || return $?
			cmd::run chmod "$mode" -- "$dst" || return $?
		fi
		logger::success "replaced: $dst_p"
		return "$COPY_REPLACE"
	fi

	# dst exists - no regular file (dir/sl/other)
	if [[ -e $dst || -L $dst ]]; then
		backup::optional "$dst" || {
			local rc=$?
			((rc == 65 || rc == 66)) || return "$rc"
		}
		if command -v install >/dev/null 2>&1; then
			cmd::run install -m "$mode" -- "$src" "$dst" || return $?
		else
			cmd::run cp -f -- "$src" "$dst" || return $?
			cmd::run chmod "$mode" -- "$dst" || return $?
		fi
		logger::warn "overwrote non-regular target: $dst_p"
		return "$COPY_OVERWROTE"
	fi

	# new file
	if command -v install >/dev/null 2>&1; then
		cmd::run install -m "$mode" -- "$src" "$dst" || return $?
	else
		cmd::run cp -- "$src" "$dst" || return $?
		cmd::run chmod "$mode" -- "$dst" || return $?
	fi
	logger::success "created: $dst_p"
	return "$COPY_CREATED"
}

# copy::tree SRC_DIR DST_DIR [FILE_MODE] [DIR_MODE] [SKIP_GLOB...]
copy::tree() {
	local src_root=$1 dst_root=$2 fmode=${3:-0644} dmode=${4:-0755}
	shift 4 || true
	local -a skip_globs=("$@")

	[[ -d "$src_root" ]] || {
		if ((VERBOSE == 1)); then
			logger::warn "copy::tree skip (no dir) $src_root"
		fi
		return 0
	}

	repo::assert_inside "$src_root" || return 1
	repo::assert_outside "$dst_root" || return 1

	logger::info "Copy tree: $src_root $(logger::arrow) $dst_root"

	shopt -s globstar nullglob dotglob
	local src rel dst pat

	for src in "$src_root"/**; do
		[[ -e $src || -L $src ]] || continue
		[[ $src == "$src_root" ]] && continue
		rel="${src#"$src_root"/}"

		# skip-pattern (relative to src_root)
		for pat in "${skip_globs[@]}"; do
			[[ -z $pat ]] && continue
			case "$rel" in
			"$pat")
				logger::verbose "skip: $rel"
				continue 2
				;;
			esac
		done

		dst="$dst_root/$rel"

		if [[ -d $src && ! -L $src ]]; then
			#create dir (dirmode)
			if command -v install >/dev/null 2>&1; then
				cmd::run install -d -m "$dmode" -- "$dst" || return $?
			else
				cmd::run mkdir -p -- "$dst" || return $?
				cmd::run chmod "$dmode" -- "$dst" || return $?
			fi
			continue
		fi

		# file or symlin -> copy as filecontent
		copy::file "$src" "$dst" "$fmode" || return $?
	done
	shopt -u globstar dotglob nullglob
}
