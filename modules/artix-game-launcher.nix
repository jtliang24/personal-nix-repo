{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages = lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        ArtixGameLauncher = pkgs.callPackage ../pkgs/Artix_Game_Launcher.nix { };
      };
    };
}
