#!/bin/bash

CONFIG_FILE="$HOME/.ssh/config"

echo " SSH-config setup started!"

# Ask for alias
read -p " Add alias for easy connection: " host_alias

# Check alias
if grep -q "Host $host_alias" "$CONFIG_FILE" 2>/dev/null; then
  echo " Alias '$host_alias' is already in your config. Process cancelled."
  exit 1
fi

# Add IP for SSH connection
read -p "󰩟 Add serveradress (IP or domain): " hostname

# Add username for connection
read -p " Add username (root?): " user

shopt -s nullglob
key_files=(~/.ssh/id_* ~/.ssh/*.pem ~/.ssh/*.key)

if [ ${#key_files[@]} -eq 0 ]; then
  echo " No key files found in ~/.ssh/. Exiting."
  exit 1
fi

# Find all private key files
shopt -s nullglob
key_files=(~/.ssh/id_* ~/.ssh/*.pem ~/.ssh/*.key)

if [ ${#key_files[@]} -eq 0 ]; then
  echo " No private key files found in ~/.ssh/. Exiting."
  exit 1
fi

# Display the list like `ls -1` with numbers
echo " Select your private key:"
for i in "${!key_files[@]}"; do
  printf "%2d) %s\n" $((i + 1)) "${key_files[$i]}"
done
printf "%2d) %s\n" $((${#key_files[@]} + 1)) "Enter path manually"

# Read user choice
while true; do
  read -p "Choose a number: " choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#key_files[@]})); then
    identity_file="${key_files[$((choice - 1))]}"
    break
  elif ((choice == ${#key_files[@]} + 1)); then
    read -e -p "Enter full path to private key: " identity_file
    break
  else
    echo "Invalid selection. Please try again."
  fi
done

mkdir -p ~/.ssh/
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

# Add new SSH Alias to config file
{
  echo ""
  echo "Host $host_alias"
  echo "  HostName $hostname"
  echo "  User $user"
  echo "  IdentityFile $identity_file"
} >>"$CONFIG_FILE"

echo " Alias '$host_alias' added to $CONFIG_FILE"
echo "󰸞 You can now connect with command: 'ssh $host_alias'"
