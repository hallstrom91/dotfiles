# alias for script loading
alias mountwsx="~/.bin/mountwsx.sh"
alias dismountwsx="~/.bin/dismountwsx.sh"
alias untar="~/.bin/untar.sh"

# dev related
alias cryptokey="node -e 'console.log(require('crypto').randomBytes(32).toString('hex'))'"
alias dotnetrun="dotnet run --project Main"
alias dotnetrunshitpc="DOTNET_THREADPOOL_MINTHREADS=2 dotnet run --project Main"
alias reactrun="NODE_OPTIONS='--max-old-space-size=2048' npm start"
alias listsecrets="dotnet user-secrets list --project Main"
alias vim='nvim'

# system
alias reload="source ~/.bashrc"
alias gpgkill="gpgconf --kill gpg-agent"
alias gpgstart="gpgconf --launch gpg-agent"
alias listaliases='grep "^alias " ~/.bash_aliases'

# git
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'
