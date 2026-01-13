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
    
    desktop_path=""
    for dir in "''${directories[@]}"; do
      if [ -d "$dir" ]; then
        found_path=$(find "$dir" -name "$browser" -print -quit 2>/dev/null || true)
        if [ "$verbose" = true ]; then
          echo "Searching path: $dir" >&2
        fi
        if [ -n "$found_path" ]; then
          desktop_path="$found_path"
          break
        fi
      fi
    done

    if [ -z "$desktop_path" ]; then
      echo "No desktop file found for $browser" >&2
      exit 1
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
