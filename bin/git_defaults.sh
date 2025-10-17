#!/usr/bin/env bash
# Configure global git defaults and aliases.

# Guards
[[ -n ${BASH_VERSION-} ]] || {
	echo "Please run with bash" >&2
	exit 2
}

if ! declare -F run >/dev/null; then
	run() { "$@"; }
fi

if ! declare -F logger::info >/dev/null; then
	logger::info() { printf '[git-defaults] %s\n' "$*"; }
fi

# Helpers
git_config_set() {
	local key=$1 val=$2 type=${3:-}
	if [[ -n $type ]]; then
		run git config --global --type="$type" "$key" "$val"
	else
		run git config --global "$key" "$val"
	fi
}

find_editor() {
	local ed=${EDITOR-}
	if [[ -n $ed ]]; then
		printf '%s' "$ed"
		return 0
	fi
	if command -v nvim >/dev/null 2>&1; then
		printf "nvim"
		return 0
	fi
	if command -v vim >/dev/null 2>&1; then
		printf "vim"
		return 0
	fi
	printf "vi"
}

# Main
install_git_defaults() {
	command -v git >/dev/null 2>&1 || {
		echo "Git not found" >&2
		return 127
	}

	logger::info "Configuring global Git defaults:"

	# Base
	git_config_set init.defaultBranch main
	git_config_set core.autocrlf input
	git_config_set core.editor "$(find_editor)"
	git_config_set core.excludesfile "$HOME/.config/git/gitignore_global" path
	git_config_set commit.template "$HOME/.config/git/commit_template" path

	# git_config_set core.editor "$(command -v nvim >/dev/null && echo nvim || echo vim)"
	git_config_set tag.gpgsign true bool
	git_config_set pull.rebase true bool
	# git_config_set rebase.autosquash true bool
	# git_config_set fetch.prune true bool
	# git_config_set push.autoSetupRemote true bool

	# add alias
	local -a aliases=(
		"st=status -sb"
		"co=checkout"
		"cob=checkout -b"
		"br=branch"
		"brd=branch -d"
		"brD=branch -D"
		"ci=commit"
		"cm=commit -m"
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
		"lol=log --oneline --graph --decorate --all"
		"la=!git config -l | grep alias | cut -c 7-"
	)
	local a
	for a in "${aliases[@]}"; do
		git_config_set "alias.${a%%=*}" "${a#*=}"
	done
}

if [[ ${1-} == "--run" ]]; then
	install_git_defaults
fi

# git_config_set alias.st "status -sb"
# git_config_set alias.co "checkout"
# git_config_set alias.cob "checkout -b"
# git_config_set alias.br "branch"
# git_config_set alias.brd "branch -d"
# git_config_set alias.brD "branch -D"
# git_config_set alias.ci "commit"
# git_config_set alias.cm "commit -m"
# git_config_set alias.ca "commit --amend"
# git_config_set alias.hist "log --oneline --graph --decorate -all"
# git_config_set alias.last "log -1 HEAD"
# git_config_set alias.pu "!git push -u origin \$(git branch --show-current)"
# git_config_set alias.pff "push --force-with-lease"
# git_config_set alias.rb "rebase"
# git_config_set alias.rbi "rebase i"
# git_config_set alias.rbc "rebase --continue"
# git_config_set alias.rba "rebase --abort"
# git_config_set alias.rbs "rebase --skip"
# git_config_set alias.d "diff"
# git_config_set alias.ds "diff --staged"
# git_config_set alias.lg "log --pretty=format:'%C(yellow)%h%Creset %ad | %Cgreen%s%Creset %C(blue)[%an]%Creset' --date=short"
# git_config_set alias.lol "-oneline --graph --decorate --all"
# git_config_set alias-la "!git config -l | grep alias | cut -c 7-"
