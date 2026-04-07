{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.gemini-cli = pkgs.callPackage ../pkgs/gemini-cli.nix { };
    };
}
