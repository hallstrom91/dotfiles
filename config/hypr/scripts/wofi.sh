#!/usr/bin/env bash

case "${1:---drun}" in
--drun)
	# GUI Apps launcher
	p="$(printf '%s \n' "Launch Applications (drun)")"
	sel="$(wofi --show drun --prompt "$p")"
	if [[ -z "${sel:-}" ]]; then
		exit 0
	fi
	uwsm app -- "$(sed -E 's/(\.desktop) /\1:/' <<<"$sel")"
	;;
--run)
	# run (+x in path) scripts launcher
	p="$(printf '%s \n' "Find Executable in $PATH (run)")"
	cmd="$(wofi --show run --prompt "$p")"
	if [[ -z "${cmd:-}" ]]; then
		exit 0
	fi
	uwsm app -- kitty -e bash -lc "$cmd"
	;;
*)
	notify-send -u low -t 4000 "wofi.sh" "Invalid flag: ${1:-} \nValid flags: [--drun|--run]"
	exit 2
	;;
esac
