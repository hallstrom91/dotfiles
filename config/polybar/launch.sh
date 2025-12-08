#!/usr/bin/env bash

# terminate running bar instances : avoid duplicates
# ipc enabled ?
polybar-msg cmd quit

# no ipc enabled ? use:
# killall -q polybar

polybar main 2>&1 | tee -a /tmp/polybar-bubbles-main.log &
disown
polybar mainbottom 2>&1 | tee -a /tmp/polybar-bubbles-mainbottom.log &
disown
polybar secondary 2>&1 | tee -a /tmp/polybar-bubbles-secondary.log &
disown
