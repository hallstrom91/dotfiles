# shellcheck shell=bash
[[ -n ${LOGGER_LOADED-} ]] && return 0
LOGGER_LOADED=1

: "${ICONS:=1}" # requires nerdfont.
: "${COLOR:=1}" # requires color support in term.
: "${VERBOSE:=0}"

if [[ "$COLOR" -eq 1 && -t 2 && ${TERM-} && $TERM != dumb ]]; then
	_R="\033[31m"
	_G="\033[32m"
	_Y="\033[33m"
	_B="\033[34m"
	_C="\033[36m"
	_N="\033[0m"
else
	_R=""
	_G=""
	_Y=""
	_B=""
	_C=""
	_N=""
fi

# internal helpers
logger::_echoe() { printf '%b\n' "$*" >&2; }
logger::_icon() { [[ "$ICONS" -eq 1 ]] && printf '%s ' "$1" || true; }

# add verbose?   [dbg]
logger::info() { logger::_echoe "$(logger::_icon )${_C}[info]${_N} $*"; }  #nerdfont nf-cod-info
logger::warn() { logger::_echoe "$(logger::_icon )${_Y}[warn]${_N} $*"; }  #nerdfont nf-cod-warning
logger::fail() { logger::_echoe "$(logger::_icon )${_R}[fail]${_N} $*"; }  #nerdfont nf-cod-error
logger::success() { logger::_echoe "$(logger::_icon )${_G}[ok]${_N} $*"; } #nerdfont nf-cod-check
logger::verbose() { ((VERBOSE == 1)) && logger::_echoe "${_B}[dbg]${_N} $*" || :; }

# Util: arrow (ICONS=1 -> nerdfont; else plain)
# usage example --| log "Link $(basename "src") $(logger::arrow) $dst"
logger::arrow() { [[ "$ICONS" -eq 1 ]] && printf -- " " || printf -- '->'; } #nerdfont nf-fa-arrow-right_long
