declare -A paths
paths=(
  [vimconf]="$HOME/.config/nvim"
  [wezconf]="$HOME/.config/wezterm"
  [kittyconf]="$HOME/.config/kitty"
  [wsx]="/media/veracrypt1/ws"
  [webdev]="/media/veracrypt1/ws/webdev"
  [wsxreactjs]="/media/veracrypt1/ws/webdev/reactjs"
  [wsxnextjs]="/media/veracrypt1/ws/webdev/nextjs"
  [wsxnodejs]="/media/veracrypt1/ws/webdev/nodejs"
  [wsxstorybook]="/media/veracrypt1/ws/webdev/storybook"
  [hitract]="/media/veracrypt1/ws/hitract"
  [dotnet]="/media/veracrypt1/ws/dotnet"
  [downloads]="$HOME/Downloads"
  [documents]="$HOME/Documents"
)

cd() {
  if [[ -z "$1" ]]; then
    builtin cd ~ || return
  elif [[ -n "${paths[$1]}" ]]; then
    builtin cd "${paths[$1]}" || return
  elif [[ -d "$1" ]]; then
    builtin cd "$1" || return
  else
    echo "cd: No such file or directory: $1" >&2
    return 1
  fi
}

_cd_custom() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local keys

  # get custom paths
  mapfile -t keys < <(printf "%s\n" "${!paths[@]}")

  if [[ "$PWD" != "$HOME" && "$PWD" != "/" ]]; then

    mapfile -t COMPREPLY < <(compgen -o filenames -d -- "$cur" | grep -vE '/\.[^/]*$')
  elif [[ "$cur" == /* ]]; then

    mapfile -t COMPREPLY < <(compgen -o filenames -d -- "$cur" | grep -vE '/\.[^/]*$')
  elif [[ "$COMP_CWORD" -eq 1 ]]; then

    mapfile -t COMPREPLY < <(compgen -W "${keys[*]}" -- "$cur")
  else

    mapfile -t COMPREPLY < <(compgen -o filenames -d -- "$cur" | grep -vE '/\.[^/]*$')
  fi
}

complete -F _cd_custom cd
