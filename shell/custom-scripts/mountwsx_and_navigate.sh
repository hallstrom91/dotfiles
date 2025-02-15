#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Run mount script
"$HOME/.bin/mountwsx.sh" || {
  echo -e "Failed to start decryption script: ${RED}Error${RESET}"
  exit 1
}

TIMEOUT=20
COUNTER=0
MOUNT_POINTS=(
  "/media/veracrypt1"
  "/media/veracrypt2"
  "/media/veracrypt3"
)

while true; do
  ALL_MOUNTED=true

  for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
    if ! mount | grep -q "$MOUNT_POINT"; then
      ALL_MOUNTED=false
      break
    fi
  done

  if [[ "$ALL_MOUNTED" == true ]]; then
    echo -e "All partitions mounted: ${GREEN}SUCCESS${RESET}"
    break
  fi

  sleep 2
  ((COUNTER += 2))

  if [[ $COUNTER -ge $TIMEOUT ]]; then
    echo -e "Mount operation timed out after $TIMEOUT seconds. ${YELLOW}FAILED...${RESET}"
    exit 1
  fi
done

cd /media/veracrypt1/ws || {
  echo -e "${RED}Failed to navigate to workspace${RESET}: ${YELLOW}Partition not mounted..${RESET}"
  exit 1
}
echo -e "${GREEN}Navigated to${RESET}: /media/veracrypt1/ws "

[[ $- == *i* ]] || exec bash
