#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configure git defaults and aliases

# Guards
[[ -n ${BASH_VERSION-} ]] || {
	printf '%s\n' "Run with bash" >&2
	exit 2
}

command -v git >/dev/null 2>&1 || {
	printf '%s\n' "Git not found" >&2
	exit 127
}

# : "${EDITOR-:vi}" #set 'vi' as default if no value
DF_GIT_DRYRUN=0

if [[ "${1-}" == "--dry-run" ]]; then
	DF_GIT_DRYRUN=1
fi

run() {
	if ((DF_GIT_DRYRUN)); then
		printf '[dry-run] '
		printf '%q ' "$@"
		printf '\n'
		return 0
	fi
	"$@"
}

find_editor() {
	command -v nvim >/dev/null 2>&1 && {
		printf '%s\n' nvim
		return 0
	}
	command -v vim >/dev/null 2>&1 && {
		printf '%s\n' vim
		return 0
	}
	printf '%s\n' "${EDITOR:-vi}"
}

git_config_set() {
	# usage: git_config_set <key> <value> [type]
	# type: bool|path|int| or empty
	local key="$1"
	local val="$2"
	local type="${3-}"

	case "$type" in
	bool) run git config --global --type=bool "$key" "$val" ;;
	int) run git config --global --type=int "$key" "$val" ;;
	path) run git config --global --type=path "$key" "$val" ;;
	"") run git config --global "$key" "$val" ;;
	*)
		printf 'error, unknown type: %s\n' "$type" >&2
		return 2
		;;
	esac
}

install_git_defaults() {
	local editor
	editor="$(find_editor)"

	# Base
	git_config_set init.defaultBranch main
	git_config_set core.autocrlf input
	git_config_set core.editor "$editor"
	git_config_set core.excludesfile "$HOME/.config/git/gitignore_global" path
	git_config_set commit.template "$HOME/.config/git/commit_template" path

	git_config_set tag.gpgsign true bool
	git_config_set pull.rebase true bool
	# git_config_set rebase.autosquash true bool
	# git_config_set fetch.prune true bool

	# add alias
	local -a aliases=(
		"st=status -sb"
		"co=checkout"
		"cob=checkout -b"
		"br=branch"
		"brd=branch -d"
		"brD=branch -D"
		"ci=commit"
		"ca=commit --amend"
		"hist=log --oneline --graph --decorate --all"
		"last=log -1 HEAD"
		"pu=!git push -u origin \$(git branch --show-current)"
		"pff=push --force-with-lease"
		"rb=rebase"
		"rbi=rebase i"
		"rbc=rebase --continue"
		"rba=rebase --abort"
		"rbs=rebase --skip"
		"d=diff"
		"ds=diff --staged"
		"lg=log --pretty=format:'%C(yellow)%h%Creset %ad | %Cgreen%s%Creset %C(blue)[%an]%Creset' --date=short"
		"la=!git config -l | grep alias | cut -c 7-"
	)

	local a
	for a in "${aliases[@]}"; do
		git_config_set "alias.${a%%=*}" "${a#*=}"
	done
}

install_git_defaults
printf '%s\n' "Done. Verify with: git config --show-origin -l"
