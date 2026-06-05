#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz

set -eu -o pipefail

# Navigate to the directory containing this script
if [[ "$(dirname "$0")" != /nix/store/* ]]; then
  cd "$(dirname "$0")"
else
  cd antigravity-cli
fi


# Fetch latest release JSON from GitHub API
echo "Fetching latest release from GitHub API..."
release_json=$(curl -s "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest")

# Extract the version (strip 'v' prefix if present)
version=$(echo "$release_json" | jq -r '.tag_name' | sed 's/^v//')
echo "Latest version: $version"

# Update version in default.nix
sed -i -E 's/version = "[^"]*"/version = "'"$version"'"/' default.nix

# Define mapping between system_dict keys/names and release asset names
systems=("linux_x64" "linux_arm64" "mac_x64" "mac_arm64")

for sys_name in "${systems[@]}"; do
  # Find asset with name matching "agy_cli_${sys_name}.tar.gz"
  asset_name="agy_cli_${sys_name}.tar.gz"
  hash=$(echo "$release_json" | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .digest')
  
  if [[ -z "$hash" || "$hash" == "null" ]]; then
    echo "Error: Could not find digest for asset: $asset_name" >&2
    exit 1
  fi
  
  echo "Updating hash for $sys_name to $hash"
  sed -i -E '/name = "'"$sys_name"'";/{n; s|hash = "[^"]*"|hash = "'"$hash"'"|}' default.nix
done

echo "Update complete!"
