{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages = lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        wavebox = pkgs.callPackage ../pkgs/wavebox.nix { };
      };
    };
}
