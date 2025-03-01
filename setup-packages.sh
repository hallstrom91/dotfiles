#! /bin/bash

set -e
set -o pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${YELLOW}Installing APT packages...${RESET}"
apt update && apt install -y \
  google-chrome-stable \
  spotify-client \
  wezterm \
  insomnia \
  mongodb-org \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  ripgrep \
  fd-find \
  xclip

echo -e "${GREEN}Installing NVM (Node Version Manager)...${RESET}"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

echo -e "${GREEN}Installing Kitty Terminal...${RESET}"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

echo -e "${GREEN}All extra packages and scripts installed successfully!${RESET}"
