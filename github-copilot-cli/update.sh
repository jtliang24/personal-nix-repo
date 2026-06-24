#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cacert curl jq nix moreutils -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz
#shellcheck shell=bash
set -eu -o pipefail

if [[ "$(dirname "$0")" != /nix/store/* ]]; then
  cd "$(dirname "$0")"
else
  cd github-copilot-cli
fi

err() {
  echo "$*" >&2
  exit 1
}

# Fetch the latest version from NPM registry
latest_version=$(curl -s https://registry.npmjs.org/@github/copilot | jq -r '.["dist-tags"].latest')
if [[ -z "$latest_version" || "$latest_version" == "null" ]]; then
  err "Failed to fetch latest version of @github/copilot from npm"
fi

current_version=$(jq -r '.version' <"./versions.json")

# If version hasn't changed, we can exit early unless force-updating
if [[ "${latest_version}" == "${current_version}" ]]; then
  echo "github-copilot-cli is up to date (${current_version})"
  exit 0
fi

echo "Updating github-copilot-cli from ${current_version} to ${latest_version}"

sri_get() {
  local url="$1"
  local output sri
  output=$(nix-build -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz --expr \
    "with import <nixpkgs> {};
         fetchurl {
           url = \"$url\";
         }" 2>&1 || true)
  sri=$(echo "$output" | awk '/^\s+got:\s+/{ print $2 }')
  [[ -z "$sri" ]] && err "$output"
  echo "$sri"
}

# Temporarily copy the old versions.json so we can read from it while modifying
# Or just write to a temporary JSON file and replace versions.json at the end.
temp_json=$(mktemp)
echo '{"version": "'"${latest_version}"'", "platforms": {}}' > "$temp_json"

# We can read the platforms from the old versions.json to know their suffixes
for platform in $(jq -r '.platforms | keys[]' <"./versions.json"); do
  suffix=$(jq -r ".platforms.\"${platform}\".suffix" <"./versions.json")
  url="https://github.com/github/copilot-cli/releases/download/v${latest_version}/github-copilot-${latest_version}-${suffix}.tgz"
  echo "Prefetching ${platform} (${suffix})..."
  hash=$(sri_get "${url}")
  
  # Add to temp json
  jq --arg plat "${platform}" --arg suf "${suffix}" --arg h "${hash}" \
    '.platforms[$plat] = {suffix: $suf, hash: $h}' \
    < "$temp_json" | sponge "$temp_json"
done

mv "$temp_json" ./versions.json
echo "Successfully updated versions.json to ${latest_version}"
