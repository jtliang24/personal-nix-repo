{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "default-browser";
  runtimeInputs = with pkgs; [
    xdg-utils
    findutils
    coreutils
    dex
  ];
  text = ''
    IFS=':' read -r -a directories <<<"$XDG_DATA_DIRS"

    browser=$(xdg-settings get default-web-browser)

    path=$( (find "''${directories[@]: -10}" -name "$browser" 2>/dev/null || true) | head -n1)

    dex "$path"
  '';
}
