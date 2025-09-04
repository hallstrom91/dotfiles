#!/usr/bin/env bash

sleep 3 # Wait on X11-session to load

XMODMAP_FILE="$HOME/.config/xmodmap/Xmodmap"

if [[ -f "$XMODMAP_FILE" ]]; then
  /usr/bin/xmodmap "$XMODMAP_FILE"
else
  echo "󰈅 Xmodmap file not found: $XMODMAP_FILE"
fi
