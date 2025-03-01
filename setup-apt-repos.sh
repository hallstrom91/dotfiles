#! /bin/bash

set -e
set -o pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "Updating system before setting up apt repos"
echo sudo apt update && sudo apt upgrade -y

# Chrome
echo -e "${GREEN}Adding${RESET} Google Chrome repo."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | tee /etc/apt/trusted.gpg.d/google.asc >/dev/null

# Spotify
echo -e "${GREEN}Adding${RESET} Spotify repo."
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list

# Wezterm
echo -e "${GREEN}Adding${RESET} Wezterm repo."
curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

# Insomnia
echo -e "${GREEN}Adding${RESET} Insomnia repo."
echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" |
  tee -a /etc/apt/sources.list.d/insomnia.list

# Docker
echo -e "${GREEN}Adding${RESET} Docker repo."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

# MongoDB
echo -e "${GREEN}Adding${RESET} MongoDB repo."
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc |
  gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
    --dearmor

# Microsoft-prod
echo -e "${GREEN}Adding${RESET} Microsoft-prod (dotnet) repo."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install all packages
echo -e "${YELLOW}Updating package lists.${RESET}"
apt update

echo -e "${GREEN}Package list updated successfully!${RESET}"

# echo -e "${GREEN}Installing packages...${RESET}"
# apt install -y google-chrome-stable \
#   spotify-client \
#   wezterm \
#   insomnia \
#   mongodb-org \
#   docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# echo -e "${GREEN}All packages installed successfully!${RESET}"
