#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

PARTITIONS=(
  "/dev/sdc1" # external
  "/dev/sdc2" # external
)

MOUNT_POINTS=(
  "/media/veracrypt2"
  "/media/veracrypt1"
)

ALL_MOUNTED=true
for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
  if ! mount | grep -q "$MOUNT_POINT"; then
    ALL_MOUNTED=false
    break
  fi
done

if [[ "$ALL_MOUNTED" == true ]]; then
  echo -e "󰸞 ${YELLOW}All partitions are already mounted.${RESET}"
  exit 0
fi

echo -n "Enter decryption password: "
read -s PASSWORD
echo

for i in "${!PARTITIONS[@]}"; do
  PARTITION="${PARTITIONS[$i]}"
  MOUNT_POINT="${MOUNT_POINTS[$i]}"

  if mount | grep -q "$MOUNT_POINT"; then
    echo -e "󱈸 ${YELLOW}Partition $PARTITION is already mounted at $MOUNT_POINT.${RESET}"
  else
    echo -e "󰒓 ${GREEN}Mounting $PARTITION to $MOUNT_POINT ...${RESET}"
    echo "$PASSWORD" | sudo veracrypt --text --mount "$PARTITION" "$MOUNT_POINT" --non-interactive --stdin --fs-options="uid=1000,gid=1000,umask=0002,dmask=0002,fmask=0002"

    if mount | grep -q "$MOUNT_POINT"; then
      echo -e "󰸞 $PARTITION: ${GREEN}DONE${RESET}"
    else
      echo -e " $PARTITION: ${RED}FAILED${RESET}"
      exit 1
    fi
  fi
done
