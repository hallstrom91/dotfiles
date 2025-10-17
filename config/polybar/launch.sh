#!/usr/bin/env bash

# terminate running bar instances
# avoid duplicates
polybar-msg cmd quit
# kilall -q polybar

echo "---" | tee -a /tmp/polybar1.log /tmpt/polybar2.log

# test 3
polybar maintopbar 2>&1 | tee -a /tmp/polybar-maintopbar.log &
disown

polybar mainbotbar 2>&1 | tee -a /tmp/polybar-mainbotbar.log &
disown

polybar secbotbar 2>&1 | tee -a /tmp/polybar-secbotbar.log &
disown

# test 2 - standalone
# polybar pdws 2>&1 | tee -a /tmp/polybar-pdws.log &
# disown
#
# polybar pdtd 2>&1 | tee -a /tmp/polybar-pdtd.log &
# disown
#
# polybar pdl 2>&1 | tee -a /tmp/polybar-pdl.log &
# disown

# test 1
# polybar top 2>&1 | tee -a /tmp/polybar1.log &
# disown
#
# # polybar bottom 2>&1 | tee -a /tmp/polybar2.log &
# # disown
#
# polybar bottomApps 2>&1 | tee -a /tmp/polybar2.log &
# disown
#
# polybar utilsDisks 2>&1 | tee -a /tmp/polybar3.log &
# disown
#
# polybar utilsEth 2>&1 | tee -a /tmp/polybar3.log &
# disown

echo "Polybars launched..."
