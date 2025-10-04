# check for err in bash-cfg (if trouble)
# cmd: bash -n ~/.bashrc ~/.bash/bash_*

#---- interactive shell ---------------
case $- in *i*) ;; *) return ;; esac

# load sys-defaults (fedora)
# [[ -r /etc/bashrc ]] && source /etc/bashrc

#---- Load Modular user-cfgs ----------------
# shellcheck disable=SC1091
[ -r "$HOME/.bash/bash_exports" ] && . "$HOME/.bash/bash_exports"
# chellcheck disable=SC1091
[ -r "$HOME/.bash/bash_aliases" ] && . "$HOME/.bash/bash_aliases"
# chellcheck disable=SC1091
[ -r "$HOME/.bash/bash_functions" ] && . "$HOME/.bash/bash_functions"

#---- Shell behavior & history --------
shopt -s histappend checkwinsize

#shopt -s autocd globstar cdspell # optional

HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoredups:erasedups:ignorespace

PROMPT_COMMAND='history -a; history -n; '"${PROMPT_COMMAND:-:}"

#---- less/dircolors ------------------
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b 2>/dev/null || dircolors -b)"
fi
# alias ls='ls --color=auto'
# alias grep='grep --color=auto'

#---- Bash completion -----------------
# if ! shopt -oq posix; then
#   for bc in \
#     /usr/share/bash-completion/bash_completion \
#     /etc/bash_completion \
#     /usr/local/share/bash-completion/bash_completion; do
#     [[ -r "$bc" ]] && {
#       source "$bc"
#       break
#     }
#   done
# fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#---- fzf -----------------------------
# if [[ -r "$HOME/.fzf.bash" ]]; then

#   source "$HOME/.fzf.bash"
# else
#   [[ -r /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
#   [[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
# fi

#---- Starship (replace PS1) ----------
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

#---- Opt?: readline-binds ------------
#set -o vi
# bind '"\e[1;5C": forward-word'
# bind '"\e[1;5D": backward-word'
