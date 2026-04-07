{
  pkgs ? import <nixpkgs> { },
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  gemini-cli = pkgs.callPackage ./gemini-cli.nix { };
  gemini-cli-bin = pkgs.callPackage ./gemini-cli-bin.nix { };
  github-copilot-cli = pkgs.callPackage ./github-copilot-cli.nix { };
  warp-terminal = pkgs.callPackage ./warp-terminal { };
  gh-aw = pkgs.callPackage ./gh-aw.nix { };
}
// pkgs.lib.optionalAttrs (system == "x86_64-linux") {
  ArtixGameLauncher = pkgs.callPackage ./Artix_Game_Launcher.nix { };
  wavebox = pkgs.callPackage ./wavebox.nix { };
}
// pkgs.lib.optionalAttrs (pkgs.stdenv.isLinux) {
}
