#!/usr/bin/env bash

git_config_set() {
	local key=$1 val=$2 type=${3:-}
	if [[ -n $type ]]; then
		run git config --global --type="$type" "$key" "$val"
	else
		run git config --global "$key" "$val"
	fi
}

install_git_defaults() {
	# log - "Configuring global Git defaults."
	git_config_set init.defaultBranch main
	git_config_set core.autocrlf input
	git_config_set core.editor "$(command -v nvim >/dev/null && echo nvim || echo vim)"
	git_config_set core.excludesfile "$HOME/.config/git/gitignore_global" path
	git_config_set commit.template "$HOME/.config/git/commit_template" path
	git_config_set tag.gpgsign true bool
	git_config_set pull.rebase true bool

	# add alias
	git_config_set alias.st "status -sb"
	git_config_set alias.co "checkout"
	git_config_set alias.cob "checkout -b"
	git_config_set alias.br "branch"
	git_config_set alias.brd "branch -d"
	git_config_set alias.brD "branch -D"
	git_config_set alias.ci "commit"
	git_config_set alias.cm "commit -m"
	git_config_set alias.ca "commit --amend"
	git_config_set alias.hist "log --oneline --graph --decorate -all"
	git_config_set alias.last "log -1 HEAD"
	git_config_set alias.pu "!git push -u origin \$(git branch --show-current)"
	git_config_set alias.pff "push --force-with-lease"
	git_config_set alias.rb "rebase"
	git_config_set alias.rbi "rebase i"
	git_config_set alias.rbc "rebase --continue"
	git_config_set alias.rba "rebase --abort"
	git_config_set alias.rbs "rebase --skip"
	git_config_set alias.d "diff"
	git_config_set alias.ds "diff --staged"
	git_config_set alias.lg "log --pretty=format:'%C(yellow)%h%Creset %ad | %Cgreen%s%Creset %C(blue)[%an]%Creset' --date=short"
	git_config_set alias.lol "-oneline --graph --decorate --all"
	git_config_set alias-la "!git config -l | grep alias | cut -c 7-"
}
