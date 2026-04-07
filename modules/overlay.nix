{ ... }:
{
  flake.overlays.default =
    final: prev:
    let
      system = prev.stdenv.hostPlatform.system;
    in
    {
      gemini-cli = prev.callPackage ../pkgs/gemini-cli.nix { };
      gemini-cli-bin = prev.callPackage ../pkgs/gemini-cli-bin.nix { };
      github-copilot-cli = prev.callPackage ../pkgs/github-copilot-cli.nix { };
      warp-terminal = prev.callPackage ../pkgs/warp-terminal { };
      gh-aw = prev.callPackage ../pkgs/gh-aw.nix { };
    }
    // prev.lib.optionalAttrs (system == "x86_64-linux") {
      ArtixGameLauncher = prev.callPackage ../pkgs/Artix_Game_Launcher.nix { };
      wavebox = prev.callPackage ../pkgs/wavebox.nix { };
    }
    // prev.lib.optionalAttrs (prev.stdenv.isLinux) {
    };
}
