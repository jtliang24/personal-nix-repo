#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq curl

wavebox_version=$(curl "https://download.wavebox.app/stable/linux/latest.json" | jq --raw-output '.["urls"]["deb"] | match("https://download.wavebox.app/stable/linux/deb/amd64/wavebox_(.+)_amd64.deb").captures[0]["string"]')
nix-update wavebox --flake --version "$wavebox_version"

simple_update_pkgs=(
  "kando"
  "gemini-cli"
)

for pkg in "${simple_update_pkgs[@]}"; do
  nix-update "$pkg" --flake
done
