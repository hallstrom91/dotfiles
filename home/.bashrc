### .bashrc | interactive shell ###
# debug: `bash --noprofile --norc -ix` -> `source ~/.bashrc` |or to file| `source ~/.bashrc >bashrc.dbgout.log 2>&1`
# err check; bash -n ~/.bashrc ~/.bash/bash_*

case $- in *i*) ;; *) return ;; esac

# ---- sys default ---- #
if [ -r /etc/bashrc ]; then
	# shellcheck disable=SC1091
	. /etc/bashrc
elif [ -r /etc/bash.bashrc ]; then
	# shellcheck disable=SC1091
	. /etc/bash.bashrc
fi

shopt -s histappend
shopt -s checkwinsize
# shopt -s cdspell
# shopt -s dirspell

#---- history ----

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups
HISTTIMEFORMAT='%F %T'
TIMEFORMAT='real:%lR user:%lU sys:%lS'

# -a append new lines to histfile;
# -n read new lines from histfile;
# -c clear cur hist list; -r reload;
# __hist_sync() {
# history -a
# history -n
# }

# ---- less / pager ---- #

# lesspipe (if available)
if command -v lesspipe >/dev/null 2>&1; then
	eval "$(SHELL=/bin/sh lesspipe)"
fi

# dircolors (if available)
if command -v dircolors >/dev/null 2>&1; then
	eval "$(dircolors -b 2>/dev/null || dircolors -b)"
fi

# ---- bash completion ---- #
if ! shopt -oq posix; then
	if [ -r /usr/share/bash-completion/bash_completion ]; then
		# shellcheck source=/dev/null
		. /usr/share/bash-completion/bash_completion
	elif [ -r /etc/bash_completion ]; then
		# shellcheck source=/dev/null
		. /etc/bash_completion
	fi
fi

# ---- extend config ---- #
for f in "$HOME/.bash"/{00-env,10-path,20-aliases,30-functions}; do
	# shellcheck source=/dev/null
	[ -r "$f" ] && . "$f"
done

# extend config; integrations
for f in "$HOME/.bash/40-integrations/"*; do
	# for f in "$HOME/.bash/40-integrations"/{00-fzf,10-nvm,20-ble,30-starship}; do
	# shellcheck source=/dev/null
	[ -r "$f" ] && . "$f"
done

[[ ! ${BLE_VERSION-} ]] || ble-attach
