#!/bin/bash

echo "󰢱  GPG Key Import Wizard"

# 1. Ask for directory
read -e -p "  Enter path to your GPG key directory: " key_dir
if [[ ! -d "$key_dir" ]]; then
  echo "  Directory not found: $key_dir"
  exit 1
fi

# 2. Find all key files
shopt -s nullglob
#key_files=("$key_dir"/*.asc "$key_dir"/*.gpg)
mapfile -t key_files < <(find "$key_dir" -type f \( -iname "*.asc" -o -iname "*.gpg" \))

if [ ${#key_files[@]} -eq 0 ]; then
  echo "  No .asc or .gpg files found in $key_dir"
  exit 1
fi

# 3. List keys like ls -1
echo "  Select a key to import:"
for i in "${!key_files[@]}"; do
  printf "%2d) %s\n" $((i + 1)) "${key_files[$i]}"
done
read -p "  Enter number: " choice

if [[ ! "$choice" =~ ^[0-9]+$ ]] || ((choice < 1 || choice > ${#key_files[@]})); then
  echo "  Invalid selection"
  exit 1
fi

selected_key="${key_files[$((choice - 1))]}"

# 4. Import key
echo "  Importing key: $selected_key"
gpg --import "$selected_key"

# 5. Extract fingerprint
fingerprint=$(gpg --with-colons --import-options show-only --import "$selected_key" | awk -F: '/^fpr:/ {print $10; exit}')
if [[ -z "$fingerprint" ]]; then
  echo "  Could not extract fingerprint."
  exit 1
fi

# 6. Set trust level
echo ""
echo "󰌶  Set trust level for this key:"
echo "  1 =   I don't know"
echo "  2 =   I do NOT trust"
echo "  3 = 󰒡  I trust marginally"
echo "  4 = 󰗡  I trust fully"
echo "  5 = 󰡴  I trust ultimately"
read -p "  Enter trust level (1-5): " trust_level

if [[ ! "$trust_level" =~ ^[1-5]$ ]]; then
  echo "  Invalid trust level."
  exit 1
fi

# 7. Apply trust
echo "$fingerprint:$trust_level:" | gpg --import-ownertrust
echo "  Trust level $trust_level set for fingerprint: $fingerprint"

# 8. Display key info
echo ""
echo "󰈙  Key info:"
gpg --list-keys --keyid-format LONG --fingerprint | grep -A3 "$fingerprint"
