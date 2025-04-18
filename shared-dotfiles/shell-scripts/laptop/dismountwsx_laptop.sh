#!/bin/bash
set -e

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

MOUNT_POINTS=(
  "/media/veracrypt2"
  "/media/veracrypt1"
)

SIGNAL_FILE="/tmp/mount_success.signal"
echo -e "${YELLOW}Dismounting all volumes...${RESET}"

ALL_SUCCESS=true
ANY_BUSY=false

for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
    if mount | grep -q "$MOUNT_POINT"; then
        echo -e "󰒓 Unmounting $MOUNT_POINT ..."

        if veracrypt -t -l | grep -q "$MOUNT_POINT"; then
            if sudo veracrypt --text --dismount "$MOUNT_POINT" --non-interactive; then
                echo -e "󰸞 ${GREEN}Successfully${RESET} dismounted $MOUNT_POINT"
            else
                echo -e " ${RED}Failed${RESET} to dismount $MOUNT_POINT (possibly in use)"
                ALL_SUCCESS=false
                ANY_BUSY=true
            fi
        else
            echo -e " $MOUNT_POINT is not a VeraCrypt volume! ${RED}ERROR${RESET}"
            ALL_SUCCESS=false
        fi
    else
        echo -e "󱈸 $MOUNT_POINT is ${YELLOW}already dismounted${RESET}."
    fi
done

if [[ -f "$SIGNAL_FILE" ]]; then
    echo -e "󱑽 Removing signal file: $SIGNAL_FILE"
    rm -f "$SIGNAL_FILE"
fi

if [[ "$ALL_SUCCESS" == true ]]; then
    echo -e "󰸞 All VeraCrypt volumes ${GREEN}successfully${RESET} dismounted!"
else
    if [[ "$ANY_BUSY" == true ]]; then
        echo -e " ${YELLOW}Some volumes could not be dismounted because they are in use.${RESET}"
        echo -e "󱈸 You can use \`lsof +D /media/veracryptX\` to see what's blocking them."
    fi
    exit 1
fi

# echo "Unmounting all VeraCrypt volumes..."
#
# for MOUNT_POINT in "${MOUNT_POINTS[@]}"; do
#   if mount | grep -q "$MOUNT_POINT"; then
#     echo "Unmounting $MOUNT_POINT ..."
#
#     if veracrypt -t -l | grep -q "$MOUNT_POINT"; then
#       sudo veracrypt --text --dismount "$MOUNT_POINT" --non-interactive &&
#         echo -e "${GREEN}Successfully${RESET} dismounted $MOUNT_POINT" ||
#         echo -e "${RED}Failed${RESET} to dismount $MOUNT_POINT"
#     else
#       echo -e "$MOUNT_POINT is not a VeraCrypt volume! ${RED}ERROR${RESET}"
#       exit 1
#     fi
#   else
#     echo -e "$MOUNT_POINT is ${YELLOW}NOT${RESET} mounted."
#     exit 1
#   fi
# done
#
# echo -e "All VeraCrypt volumes ${GREEN}successfully${RESET} dismounted!"


