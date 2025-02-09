#!/bin/bash

# Run mount script
"$HOME/.bin/mountwsx.sh" || {
  echo "Error: Failed to start runwsx.sh"
  exit 1
}

# Wait max 20s on mount
TIMEOUT=20
COUNTER=0
while ! mount | grep -q "/media/veracrypt1"; do
  echo "Waiting for mount..."
  sleep 2
  ((COUNTER += 2))

  if [[ $COUNTER -ge $TIMEOUT ]]; then
    echo "Error: Mount operation timed out after $TIMEOUT seconds."
    exit 1
  fi
done

# Navigate to workspace after sucessful mount
cd /media/veracrypt1/ws || {
  echo "Error: Failed to navigate to workspace"
  exit 1
}
echo "Navigated to: /media/veracrypt1/ws"

[[ $- == *i* ]] || exec bash
