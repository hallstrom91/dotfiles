#!/bin/bash
set -e

MOUNT_POINT="/media/veracrypt1" # VeraCrypt mount point
SLOT=1                          # VeraCrypt slot


if mount | grep -q "$MOUNT_POINT"; then
  echo "Partition is mounted at $MOUNT_POINT. Proceeding to unmount..."


  if veracrypt -t -l | grep -q "$MOUNT_POINT"; then

    sudo veracrypt --text --dismount "$MOUNT_POINT" --slot=$SLOT --non-interactive &&
      echo "Partition successfully unmounted from $MOUNT_POINT" ||
      echo "Failed to unmount partition from $MOUNT_POINT"
  else
    echo "Error: $MOUNT_POINT is not a VeraCrypt volume!"
    exit 1
  fi
else
  echo "Partition is not mounted at $MOUNT_POINT"
fi
