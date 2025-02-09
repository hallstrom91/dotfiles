#! /bin/bash

MOUNT_POINT="/media/veracrypt1" # veracrypt mount point
SLOT=1 #veracrypt slot 

# Kontrollera om partitionen är monterad
if mount | grep "$MOUNT_POINT" > /dev/null; then
    echo "Partition is mounted at $MOUNT_POINT. Proceeding to unmount..."
    
    # Avmontera partitionen
    sudo veracrypt --text --dismount "$MOUNT_POINT" --slot=$SLOT --non-interactive
    
    if [ $? -eq 0 ]; then
        echo "Partition was successfully unmounted from $MOUNT_POINT"
    else
        echo "Failed to unmount partition from $MOUNT_POINT"
    fi
else
    echo "Partition is not mounted at $MOUNT_POINT"
fi
