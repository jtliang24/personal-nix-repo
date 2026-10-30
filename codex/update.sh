#!/usr/bin/env bash
set -eu -o pipefail

if [[ "$0" == /nix/store/* ]]; then
  repo_root="$PWD"
  script_dir="$PWD/codex"
else
  script_dir=$(dirname "$(readlink --canonicalize-existing "${BASH_SOURCE[0]}")")
  repo_root=$(cd "$script_dir/.." && pwd)
fi

echo "Updating codex build commit..."
bash "$script_dir/update-build-commit.sh"

echo "Fetching latest version tag..."
headers=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi
release=$(curl "${headers[@]}" --silent --fail --location \
  "https://api.github.com/repos/openai/codex/releases/latest")
tag=$(jq --exit-status --raw-output '.tag_name' <<<"$release")
version="${tag#rust-v}"

echo "Updating codex to version $version..."
(cd "$repo_root" && nix-update codex --flake --version "$version")

echo "Updating librusty_v8..."
bash "$script_dir/update-librusty.sh"

echo "Codex update complete!"
