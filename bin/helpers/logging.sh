#!/usr/bin/env bash
# helpers/logger.sh - color/icon-aware logs to stderr
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

logger::_echoe() { printf '%b\n' "$*" >&2; }
logger::_icon() { [[ "$ICONS" -eq 1 ]] && printf '%s ' "$1" || true; }

# add verbose?   [dbg]
log() { logger::_echoe "$(logger::_icon )${_C}[info]${_N} $*"; }   #nerdfont nf-cod-info
warn() { logger::_echoe "$(logger::_icon )${_Y}[warn]${_N} $*"; }  #nerdfont nf-cod-warning
fail() { logger::_echoe "$(logger::_icon )${_R}[fail]${_N} $*"; }  #nerdfont nf-cod-error
success() { logger::_echoe "$(logger::_icon )${_G}[ok]${_N} $*"; } #nerdfont nf-cod-check
verbose() { [[ "$VERBOSE" -eq 1 ]] && logger::_echoe "${_B}[dbg]${_N} $*" || true; }

# demo
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	log "info"
	warn "warn"
	verbose "verbose (dbg) - flag needed."
	success "ok"
	fail "fail"
fi

### USAGE ###
# set -o pipefail
# : "${DOTFILES:=$HOME/dotfiles}" # or export in shellprofile / bashrc
#
# #shellcheck source=/dev/null
# source "$DOTFILES/bin/helpers/logging.sh"
#
# log "Starting job"
# or
# fail "Failed to start job"
