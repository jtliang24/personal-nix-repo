final: prev:
let
  system = prev.stdenv.hostPlatform.system;
in
{
  gemini-cli = prev.callPackage ./gemini-cli.nix { };
  gemini-cli-bin = prev.callPackage ./gemini-cli-bin.nix { };
  github-copilot-cli = prev.callPackage ./github-copilot-cli.nix { };
  warp-terminal = prev.callPackage ./warp-terminal { };
  gh-aw = prev.callPackage ./gh-aw.nix { };
}
// prev.lib.optionalAttrs (system == "x86_64-linux") {
  ArtixGameLauncher = prev.callPackage ./Artix_Game_Launcher.nix { };
  wavebox = prev.callPackage ./wavebox.nix { };
}
// prev.lib.optionalAttrs (prev.stdenv.isLinux) {
  wayle = prev.callPackage ./wayle.nix { };
}
