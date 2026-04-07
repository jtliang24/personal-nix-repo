{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.gemini-cli-bin = pkgs.callPackage ../pkgs/gemini-cli-bin.nix { };
    };
}
