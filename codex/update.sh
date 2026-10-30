#!/usr/bin/env bash

set -eu -o pipefail

# Navigate to the directory containing this script
if [[ "$0" == /nix/store/* ]]; then
  [ -d codex ] && cd codex
else
  cd "$(dirname "$0")"
fi

# Fetch latest release JSON from GitHub API
echo "Fetching latest release from GitHub API..."
headers=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
release_json=$(curl -s "${headers[@]}" "https://api.github.com/repos/openai/codex/releases/latest")

# Extract the version (strip 'rust-v' or 'v' prefix if present)
version=$(echo "$release_json" | jq -r '.tag_name' | sed -E 's/^(rust-)?v//')
if [[ "$version" == "null" || -z "$version" ]]; then
  echo "Error: Failed to fetch version from GitHub API." >&2
  echo "Response was: $release_json" >&2
  exit 1
fi
echo "Latest version: $version"

# Update version in default.nix
sed -i -E 's/version = "[^"]*"/version = "'"$version"'"/' default.nix

# Define mapping between system_dict targets and release asset names
targets=("x86_64-unknown-linux-musl" "aarch64-unknown-linux-musl" "aarch64-apple-darwin")

for target in "${targets[@]}"; do
  asset_name="codex-package-${target}.tar.gz"
  hash=$(echo "$release_json" | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .digest')

  if [[ -z "$hash" || "$hash" == "null" ]]; then
    echo "Error: Could not find digest for asset: $asset_name" >&2
    exit 1
  fi

  echo "Updating hash for $target to $hash"
  sed -i -E '/target = "'"$target"'";/{n; s|hash = "[^"]*"|hash = "'"$hash"'"|}' default.nix
done

echo "Update complete!"
