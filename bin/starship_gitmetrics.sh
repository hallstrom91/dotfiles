#!/usr/bin/env bash

# Exit if not git-repo.
is_repo() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

is_repo_dirty() {
	! git diff --no-ext-diff --quiet ||
		! git diff --no-ext-diff --cached --quiet ||
		[[ -z "$(git ls-files -0 --exclude-standard 2>/dev/null)" ]]
}

if [[ "${1-}" == "--when" ]]; then
	is_repo || exit 1
	is_repo_dirty || exit 1
	exit 0
fi

# output-mode
# staged+unstaged output
git_numstat() {
	local added=0 deleted=0 a d
	while IFS=$'\t' read -r a d _; do
		[[ "$a" == "-" || "$d" == "-" ]] && continue
		added=$((added + a))
		deleted=$((deleted + d))
	done
	printf '%s %s\n' "$added" "$deleted"
}

read -r a1 d1 < <(git diff --numstat --no-ext-diff | git_numstat)
read -r a2 d2 < <(git diff --numstat --no-ext-diff --cached | git_numstat)

added=$((a1 + a2))
deleted=$((d1 + d2))

output=""
((added > 0)) && output+="+${added}"

# if ((added > 0)); then
# 	output+="+${added}"
# fi

if ((deleted > 0)); then
	[[ -n "$output" ]] && output+=" | "
	output+="-${deleted}"
fi

# if only untracked
if [[ -n "$(git ls-files -o --exclude-standard 2>/dev/null)" ]]; then
	[[ -n "$output" ]] && output+=" | "
	output+="?*"
fi

# if [[ -z "$output" ]]; then
# 	output="~"
# fi

printf '%s' "$output"
