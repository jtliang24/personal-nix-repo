{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.warp-terminal = pkgs.callPackage ../pkgs/warp-terminal { };
    };
}
