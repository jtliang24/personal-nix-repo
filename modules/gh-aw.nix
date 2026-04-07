{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.gh-aw = pkgs.callPackage ../pkgs/gh-aw.nix { };
    };
}
