#!/usr/bin/env bash

IC_OK=""
IC_UPD=""
IC_ERR=""

updates_out="$(checkupdates 2>/dev/null || true)"

count=0
if [[ -n "${updates_out}" ]]; then
	count="$(printf '%s\n' "${updates_out}" | wc -l | tr -d ' ')"
fi

max_lines=20
if [[ "${count}" -gt 0 ]]; then
	tooltip="$(printf '%s\n' "${updates_out}" | head -n "${max_lines}")"
	if [[ "${count}" -gt "${max_lines}" ]]; then
		tooltip="${tooltip}"$'\n'"... (${count} total)"
	fi
	text="${IC_UPD} ${count}"
	class="updates"
else
	tooltip="Up to date"
	text="${IC_OK}"
	class="uptodate"
fi

escape_json() {
	local s="$1"
	s="${s//\\//\\\\}"
	s="${s//\"/\\\"}"
	s="${s//$'\n'/\\n}"
	printf '%s' "$s"
}

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
	"$(escape_json "$text")" \
	"$(escape_json "$class")" \
	"$(escape_json "${tooltip}")"
