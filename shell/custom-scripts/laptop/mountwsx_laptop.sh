#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

PARTITIONS=(
  "/dev/sda1" # external partition
  "/dev/sda2" # external partition
)

MOUNT_POINTS=(
  "/media/veracrypt2" #partition sda1
  "/media/veracrypt1" #partition  sda2
)

ALL_MOUNTED=true
for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
  if ! mount | grep -q "$MOUNT_POINT"; then
    ALL_MOUNTED=false
    break
  fi
done

if [[ "$ALL_MOUNTED" == true ]]; then
  echo -e "${YELLOW}All partitions are already mounted.${RESET}"
  exit 0
fi

echo -n "Enter decryption password: "
read -s PASSWORD
echo

for i in "${!PARTITIONS[@]}"; do
  PARTITION="${PARTITIONS[$i]}"
  MOUNT_POINT="${MOUNT_POINTS[$i]}"

  if mount | grep -q "$MOUNT_POINT"; then
    echo -e "${YELLOW}Partition $PARTITION is already mounted at $MOUNT_POINT.${RESET}"
  else
    echo -e "${GREEN}Mounting $PARTITION to $MOUNT_POINT ...${RESET}"
    echo "$PASSWORD" | sudo veracrypt --text --mount "$PARTITION" "$MOUNT_POINT" --non-interactive --stdin

    if mount | grep -q "$MOUNT_POINT"; then
      echo -e "$PARTITION: ${GREEN}DONE${RESET}"
    else
      echo -e "$PARTITION: ${RED}FAILED${RESET}"
      exit 1
    fi
  fi
done
