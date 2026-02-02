final: prev:
let
  system = prev.stdenv.hostPlatform.system;
in
{
  kando = prev.callPackage ./kando.nix { };
  hello = prev.callPackage ./hello.nix { };
  gemini-cli = prev.callPackage ./gemini-cli.nix { };
  github-copilot-cli = prev.callpackage ./github-copilot-cli.nix { };
  warp-terminal = prev.callPackage ./warp-terminal { };
}
// prev.lib.optionalAttrs (system == "x86_64-linux") {
  ArtixGameLauncher = prev.callPackage ./Artix_Game_Launcher.nix { };
  wavebox = prev.callPackage ./wavebox.nix { };
}
// prev.lib.optionalAttrs (prev.stdenv.isLinux) {
  xdg-browser-exec = prev.callPackage ./xdg-browser-exec.nix { };
}

