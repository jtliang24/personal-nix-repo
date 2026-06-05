{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    # Repository Updates (used in update.sh)
    nix-update # Automatically updates package version and hashes
    jq # JSON parser for version lookup in updates
    curl # Fetching API/release information

    # Scripts and Workflows
    shellcheck # Bash script linter for update.sh
  ];

  shellHook = "echo 'Activated nix development shell'";
}
