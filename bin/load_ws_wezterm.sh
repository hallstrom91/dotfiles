#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

MOUNT_SCRIPT="$HOME/.bin/mountwsx.sh"
WORKDIR="/media/veracrypt2"
MOUNT_POINTS=(
  "/media/veracrypt1"
  "/media/veracrypt2"
)

SIGNAL_FILE="/tmp/mount_success.signal"

rm -f "$SIGNAL_FILE"

check_mounts() {
  for mp in "${MOUNT_POINTS[@]}"; do
    if ! findmnt -rno TARGET "$mp" &>/dev/null; then
      return 1
    fi
  done
  return 0
}


already_mounted=false
if check_mounts; then
  already_mounted=true
fi

# check if mounted
if [[ "$already_mounted" == false ]]; then
  echo -e "󰍁 ${BLUE}Running mount script...${RESET}"
  if ! bash "$MOUNT_SCRIPT"; then
    echo -e " ${RED}Mount script failed${RESET}"
    exec bash
  fi
fi


# Wait on mount
for i in {1..10}; do
  if check_mounts; then
    break
  fi
  sleep 2
done

if ! check_mounts; then
  echo -e " ${RED}Mount timeout after 20s${RESET}"
  exec bash
fi

# navigate
if cd "$WORKDIR"; then
  echo -e "󰁔 ${GREEN}Navigated to${RESET}: ${BLUE}$WORKDIR${RESET}"
if [[ "$already_mounted" == false ]]; then
    touch "$SIGNAL_FILE"
  fi
  # touch "$SIGNAL_FILE"
else
  echo -e " ${RED}Failed to navigate${RESET}: ${YELLOW}$WORKDIR not found${RESET}"
fi

exec bash
