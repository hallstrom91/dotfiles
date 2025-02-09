#!/bin/bash

PARTITION="/dev/sdc2"           # Encrypted external partition
MOUNT_POINT="/media/veracrypt1" # VeraCrypt mount point
SLOT=1                          # VeraCrypt slot

if mount | grep -q "$MOUNT_POINT"; then
  echo "Partition is already mounted at $MOUNT_POINT"
  exit 0
else
  echo -n "Enter VeraCrypt password: "
  read -s PASSWORD
  echo

  echo "$PASSWORD" | sudo veracrypt --text --mount "$PARTITION" "$MOUNT_POINT" --slot=$SLOT --non-interactive --stdin
fi

if mount | grep -q "$MOUNT_POINT"; then
  echo "Partition successfully mounted at $MOUNT_POINT"
else
  echo "Failed to mount partition"
  exit 1
fi
