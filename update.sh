#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq curl -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
#shellcheck shell=bash

# Updating wavebox
wavebox_version=$(curl "https://download.wavebox.app/stable/linux/latest.json" | jq --raw-output '.["urls"]["deb"] | match("https://download.wavebox.app/stable/linux/deb/amd64/wavebox_(.+)_amd64.deb").captures[0]["string"]')
nix-update wavebox --flake --version "$wavebox_version"

# Updating Warp-terminal
./warp-terminal/update.sh

# Packages that can be updated with nix-update directly
simple_update_pkgs=(
  "kando"
  "gemini-cli"
)

for pkg in "${simple_update_pkgs[@]}"; do
  nix-update "$pkg" --flake
done
