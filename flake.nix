{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Define ArtixGameLauncher only for x86_64-linux
      artixPkgs = import nixpkgs { system = "x86_64-linux"; };
      ArtixGameLauncher = artixPkgs.callPackage ./Artix_Game_Launcher.nix { };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          kando = pkgs.callPackage ./kando.nix { };
          hello = pkgs.callPackage ./hello.nix { };
        };
      }
    )
    // {
      # Add ArtixGameLauncher separately
      packages."x86_64-linux".ArtixGameLauncher = ArtixGameLauncher;
    }
    // {
      overlays.default = import ./overlay.nix;
    };
}
