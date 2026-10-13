#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update jq curl gnused nodejs -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
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
  wavebox_version=$(curl -s "https://download.wavebox.app/stable/linux/latest.json" | jq --raw-output '.["urls"]["deb"] | match("https://download.wavebox.app/stable/linux/deb/amd64/wavebox_(.+)_amd64.deb").captures[0]["string"]' 2>/dev/null || true)
  if [[ -n "$wavebox_version" && "$wavebox_version" != "null" ]]; then
    if nix-update wavebox --flake --version "$wavebox_version"; then
      update_readme "wavebox" "$wavebox_version"
    else
      echo "Failed to update wavebox, reverting changes..."
      git checkout -- wavebox.nix
    fi
  else
    echo "Warning: Could not fetch wavebox version, skipping update."
  fi

  # Updating orchard-music
  orchard_payload=$(curl -sL -A "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0" "https://depot.sfg545.dev/releases/canary.json" | jq -r '.payload // empty' 2>/dev/null || true)
  orchard_version=$(echo "$orchard_payload" | base64 -d 2>/dev/null | jq -r '.version // empty' 2>/dev/null || true)
  current_version=$(nix eval --raw .#orchard-music.version 2>/dev/null || true)
  if [[ -n "$orchard_version" && "$orchard_version" != "null" ]]; then
    if [[ "$orchard_version" != "$current_version" ]]; then
      appimage_url="https://depot.sfg545.dev/downloads/canary/${orchard_version}/Orchard-Linux-x86_64.AppImage"
      echo "Fetching Orchard AppImage for version $orchard_version..."
      if curl -sLf -A "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0" "$appimage_url" -o /tmp/Orchard-Linux-x86_64.AppImage; then
        orchard_hash=$(nix-hash --type sha256 --flat --sri /tmp/Orchard-Linux-x86_64.AppImage)
        nix-store --add-fixed sha256 /tmp/Orchard-Linux-x86_64.AppImage
        rm -f /tmp/Orchard-Linux-x86_64.AppImage
        sed -i -E "s/version = \".*\";/version = \"$orchard_version\";/" orchard.nix
        sed -i -E "s|hash = \".*\";|hash = \"$orchard_hash\";|" orchard.nix
        update_readme "orchard-music" "$orchard_version"
      else
        echo "Failed to download Orchard AppImage for $orchard_version, skipping update."
      fi
    else
      echo "orchard-music is up to date ($current_version)."
    fi
  else
    echo "Warning: Could not fetch orchard-music version, skipping update."
  fi
fi

# # Updating Warp-terminal
# ./warp-terminal/update.sh
# warp_version=$(nix eval --raw .#warp-terminal.version)
# update_readme "warp-terminal" "$warp_version"
#
# ./antigravity-cli/update.sh
# agy_version=$(nix eval --raw .#antigravity-cli.version)
# update_readme "antigravity-cli" "$agy_version"

# Packages that can be updated with nix-update directly
simple_update_pkgs=(
  "github-copilot-cli"
  "gh-aw"
  "warp-terminal"
  "antigravity-cli"
)

for pkg in "${simple_update_pkgs[@]}"; do
  extra_args=()
  if [[ "$pkg" == "gh-aw" ]]; then
    extra_args+=("--use-github-releases" "--version" "stable")
  fi

  nix-update "$pkg" --flake "${extra_args[@]}" -u
  new_ver=$(nix eval --raw .#"${pkg}".version)
  update_readme "$pkg" "$new_ver"
done

# Updating Antigravity IDE
echo "Updating Antigravity IDE..."
./antigravity-ide/update.js
antigravity_version=$(nix eval --raw .#antigravity-ide.version)
update_readme "antigravity-ide" "$antigravity_version"
