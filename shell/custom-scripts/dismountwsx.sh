#!/bin/bash
set -e

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

MOUNT_POINTS=(
  "/media/veracrypt3"
  "/media/veracrypt2"
  "/media/veracrypt1"
)

echo "Unmounting all VeraCrypt volumes..."

for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
  if mount | grep -q "$MOUNT_POINT"; then
    echo "Unmounting $MOUNT_POINT ..."

    if veracrypt -t -l | grep -q "$MOUNT_POINT"; then
      sudo veracrypt --text --dismount "$MOUNT_POINT" --non-interactive &&
        echo -e "${GREEN}Successfully${RESET} dismounted $MOUNT_POINT" ||
        echo -e "${RED}Failed${RESET} to dismount $MOUNT_POINT"
    else
      echo -e "$MOUNT_POINT is not a VeraCrypt volume! ${RED}ERROR${RESET}"
      exit 1
    fi
  else
    echo -e "$MOUNT_POINT is ${YELLOW}NOT${RESET} mounted."
    exit 1
  fi
done

echo -e "All VeraCrypt volumes ${GREEN}successfully${RESET} dismounted!"
