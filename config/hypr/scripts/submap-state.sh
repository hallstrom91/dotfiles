#!/usr/bin/env bash

mode="${1:-}"

case "$mode" in
--clipboard)
	notify-send -t 3000 "Cliphist Submap Active" "Binds:\n[T]ext\n[I]mage\n[A]ll\n[X]wipe\n"
	;;
--resize)
	notify-send -t 3000 "Resize Submap Active" "Binds:\n[H]left\n[J]down\n[K]up\n[L]right\n"
	;;
--window)
	notify-send -t 3000 "Window Submap Active" "Binds:\n[V]float\n[P]psuedo\n[J]split\n"
	;;
--screenshot)
	notify-send -t 2000 "Screenshot Submap Active" "Binds:\n[F]full\n[W]window\n"
	;;
*)
	notify-send -t 3000 "submap-state.sh" "Valid flags:\n [--clipboard|--resize|--window|--screenshot]"
	exit 1
	;;
esac
