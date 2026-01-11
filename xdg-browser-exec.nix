{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "xdg-browser-exec";
  runtimeInputs = with pkgs; [
    xdg-utils
    findutils
    coreutils
    dex
  ];
  text = ''
    IFS=':' read -r -a directories <<<"$XDG_DATA_DIRS"

    browser=$(xdg-settings get default-web-browser)
    desktop_path=$( (find "''${directories[@]: -10}" -name "$browser" 2>/dev/null || true) | head -n1)
    bin_path=$(dex "$desktop_path" -d)

    trimmed_bin_path="''${bin_path:19}"

    exec "$trimmed_bin_path" "$@"
  '';
}
