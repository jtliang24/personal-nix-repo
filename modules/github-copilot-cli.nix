{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.github-copilot-cli = pkgs.callPackage ../pkgs/github-copilot-cli.nix { };
    };
}
