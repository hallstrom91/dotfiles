#! /bin/bash

set -e
set -o pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "Updating system before setting up apt repos"
sudo apt update && sudo apt upgrade -y

# Chrome
echo -e "${GREEN}Adding${RESET} Google Chrome repo."
wget -q -O /etc/apt/keyrings/google-chrome.asc https://dl.google.com/linux/linux_signing_key.pub \
  || { echo -e "${RED}Failed to download Google Chrome GPG key. Aborting.${RESET}"; exit 1; }
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.asc] http://dl.google.com/linux/chrome/deb/ stable main" |
  tee /etc/apt/sources.list.d/google-chrome.list

# Spotify
echo -e "${GREEN}Adding${RESET} Spotify repo."
curl -fsSL https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor -o /etc/apt/keyrings/spotify.gpg \
  || { echo -e "${RED}Failed to download Spotify GPG key. Aborting.${RESET}"; exit 1; }
echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" |
  tee /etc/apt/sources.list.d/spotify.list

# Wezterm
echo -e "${GREEN}Adding${RESET} Wezterm repo."
curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg \
  || { echo -e "${RED}Failed to download Wezterm GPG key. Aborting.${RESET}"; exit 1; }
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
  sudo tee /etc/apt/sources.list.d/wezterm.list

# Insomnia
echo -e "${GREEN}Adding${RESET} Insomnia repo."
echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" |
  tee -a /etc/apt/sources.list.d/insomnia.list \
  || { echo -e "${RED}Failed to add Insomnia repo. Aborting.${RESET}"; exit 1; }

# Docker
echo -e "${GREEN}Adding${RESET} Docker repo."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  || { echo -e "${RED}Failed to download Docker GPG key. Aborting.${RESET}"; exit 1; }
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null

# MongoDB
echo -e "${GREEN}Adding${RESET} MongoDB repo."
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /etc/apt/keyrings/mongodb-server-8.0.gpg \
  || { echo -e "${RED}Failed to download MongoDB GPG key. Aborting.${RESET}"; exit 1; }
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" |
  tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Microsoft-prod
echo -e "${GREEN}Adding${RESET} Microsoft-prod (dotnet) repo."
wget -q -O packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
  || { echo -e "${RED}Failed to download Microsoft-prod package. Aborting.${RESET}"; exit 1; }
if dpkg -I packages-microsoft-prod.deb &>/dev/null; then
  dpkg -i packages-microsoft-prod.deb
else
  echo -e "${RED}Microsoft-prod package failed verification. Aborting.${RESET}"
  exit 1
fi
rm packages-microsoft-prod.deb

# Install all packages
echo -e "${YELLOW}Updating package lists.${RESET}"
apt update

echo -e "${GREEN}Package list updated successfully!${RESET}"


