#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq curl gnused -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
#shellcheck shell=bash

update_readme() {
  local pkg="$1"
  local version="$2"
  # Update the version in README.md table
  # Matches: | **pkg** | <old_version> |
  sed -E -i "s/(\| \*\*${pkg}\*\* +\| +)[^ ]+( +\|)/\1${version}\2/" README.md
}

if [[ "$(uname -s)" == "Linux" ]]; then
  # Updating wavebox
  wavebox_version=$(curl -s "https://download.wavebox.app/stable/linux/latest.json" | jq --raw-output '.["urls"]["deb"] | match("https://download.wavebox.app/stable/linux/deb/amd64/wavebox_(.+)_amd64.deb").captures[0]["string"]')
  nix-update wavebox --flake --version "$wavebox_version"
  update_readme "wavebox" "$wavebox_version"
fi

# Updating Warp-terminal
./warp-terminal/update.sh
warp_version=$(nix eval --raw .#warp-terminal.version)
update_readme "warp-terminal" "$warp_version"

# Packages that can be updated with nix-update directly
simple_update_pkgs=(
  "kando"
  "gemini-cli"
)

for pkg in "${simple_update_pkgs[@]}"; do
  nix-update "$pkg" --flake
  new_ver=$(nix eval --raw .#${pkg}.version)
  update_readme "$pkg" "$new_ver"
done
