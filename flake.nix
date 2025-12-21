{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nvf,
    }@inputs:
    let
      nvfLocal = import ./nvf.nix { inherit self nixpkgs nvf; };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        artix = if system == "x86_64-linux" then
          let artixPkgs = import nixpkgs {
            system = "x86_64-linux";
            config = { allowUnfree = true; };
          };
          in {
            ArtixGameLauncher = artixPkgs.callPackage ./Artix_Game_Launcher.nix { };
          }
        else {};
      in
      {
        packages = {
          kando = pkgs.callPackage ./kando.nix { };
          hello = pkgs.callPackage ./hello.nix { };
          neovimConfigured = nvfLocal.packages.${system}.neovimConfigured;
        } // artix;
      }
    )
    // {
      overlays.default = import ./overlay.nix;
    }
    ;
}
