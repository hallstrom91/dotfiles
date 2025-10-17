#!/usr/bin/env bash

# sleep 3 # Wait on X11-session to load

if [[ ${XDG_SESSION_TYPE:-} != x11 ]]; then
	echo "Skip: not X11 (XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-unknown})"
	exit 0
fi

XMODMAP_FILE="$HOME/.config/xmodmap/Xmodmap"

if [[ -f "$XMODMAP_FILE" ]]; then
	exec /usr/bin/xmodmap "$XMODMAP_FILE"
else
	echo " Failed: Xmodmap file not found: $XMODMAP_FILE"
	exit 1
fi

# if [[ -f "$XMODMAP_FILE" ]]; then
# 	/usr/bin/xmodmap "$XMODMAP_FILE"
# else
# 	echo " Failed: Xmodmap file not found: $XMODMAP_FILE"
# fi
