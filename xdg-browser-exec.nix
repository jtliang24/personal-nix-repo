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
    verbose=false
    args=()

    for arg in "$@"; do
      if [[ "$arg" == "-v" || "$arg" == "--verbose" ]]; then
        verbose=true
      else
        args+=("$arg")
      fi
    done

    IFS=':' read -r -a directories <<<"$XDG_DATA_DIRS"

    browser=$(xdg-settings get default-web-browser)
    if [ "$verbose" = true ]; then
      echo "Default browser: $browser" >&2
    fi
    
    if [[ ''${#directories[@]} -gt 10 ]]; then
      if [ "$verbose" = true ]; then
        echo "Truncating to last 10 directories"
      fi
      desktop_path=$( (find "''${directories[@]: -10}" -name "$browser" 2>/dev/null || true) | head -n1)
    else
      desktop_path=$( (find "''${directories[@]}" -name "$browser" 2>/dev/null || true) | head -n1)
    fi

    if [ "$verbose" = true ]; then
      echo "Desktop file path: $desktop_path" >&2
    fi

    bin_path=$(dex "$desktop_path" -d)

    trimmed_bin_path="''${bin_path:19}"

    if [ "$verbose" = true ]; then
      echo "Executing: $trimmed_bin_path ''${args[*]}" >&2
    fi

    exec "$trimmed_bin_path" "''${args[@]}"
  '';
}
