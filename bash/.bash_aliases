# alias for script loading
alias mountwsx="~/.bin/mountwsx.sh"
alias dismountwsx="~/.bin/dismountwsx.sh"
alias untar="~/.bin/untar.sh"

# dev related
alias cryptokey="node -e 'console.log(require('crypto').randomBytes(32).toString('hex'))'"
alias rundotnet="dotnet run --project Main"
alias listsecrets="dotnet user-secrets list --project Main"
alias vim='nvim'

# system
alias reload="source ~/.bashrc"
alias gpgkill="gpgconf --kill gpg-agent"
alias gpgstart="gpgconf --launch gpg-agent"
alias myaliases='grep "^alias " ~/.bash_aliases'

# git
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'
