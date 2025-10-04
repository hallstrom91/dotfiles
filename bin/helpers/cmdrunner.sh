# shellcheck shell=bash
[[ -n ${CMDRUNNER_LOADED-} ]] && return 0
CMDRUNNER_LOADED=1

require logs

# return codes:
# 0 = ok
# 1 = fail

: "${DRY_RUN:=0}"
: "${VERBOSE:=0}"

cmd::quote_all() {
	local a q=''

	for a in "$@"; do
		q+=" $(printf '%q' "$a")"
	done

	printf '%s' "${q# }"
}

cmd::run() {
	local q
	q=$(cmd::quote_all "$@")

	if ((DRY_RUN == 1)); then
		((VERBOSE == 1)) && logger::info "[dry-run] $q"
		return 0
	fi

	logger::verbose "run: $q"
	"$@"
}

# run cmd, return exit-code, write STDOUT to given var-name
# usage: if cmd:.capture out_var ls -la --; then ...; fi
cmd::capture() {
	local __var=$1
	shift
	local q
	q=$(cmd::quote_all "$@")

	if ((DRY_RUN == 1)); then
		printf -v "$__var" ''
		((VERBOSE == 1)) && logger::info "[dry-run:capture] $q"
		return 0
	fi
	logger::verbose "run (capture): $q"
	local __out
	if ! __out="$("$@" 2>&1)"; then
		# failed cmd, still write output to var
		printf -v "$__var" '%s' "$__out"
		return 1
	fi
	printf -v "$__var" '%s' "$__out"
}
