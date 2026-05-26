#!/usr/bin/env nix-shell
#!/nix-shell -i bash -p nix-update jq curl nodejs prefetch-npm-deps gnused -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
#shellcheck shell=bash
set -eu -o pipefail

cd "$(dirname "$0")"

latest_version=$(curl -s "https://api.github.com/repos/minbrowser/min/releases/latest" | jq -r ".tag_name" | sed 's/^v//')
current_version=$(nix eval --raw ..#min-browser.version || echo "0.0.0")

if [[ "$latest_version" != "$current_version" ]]; then
  echo "Updating min-browser from $current_version to $latest_version..."

  # Update package version and src hash in default.nix
  nix-update min-browser --flake --version "$latest_version"

  # Download package.json to generate the lockfile
  curl -s "https://raw.githubusercontent.com/minbrowser/min/v${latest_version}/package.json" -o package.json

  # Generate package-lock.json
  npm install --package-lock-only --ignore-scripts
  rm package.json

  # Prefetch dependencies and calculate new hash
  new_hash=$(FORCE_GIT_DEPS=true prefetch-npm-deps package-lock.json)

  # Update npmDepsHash in default.nix
  sed -i -E "s|npmDepsHash = \"sha256-[a-zA-Z0-9+/=]+\";|npmDepsHash = \"\${new_hash}\";|" default.nix
else
  echo "min-browser is already up to date ($current_version)"
fi
