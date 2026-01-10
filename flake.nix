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
        linux_pkgs =
          if system == "x86_64-linux" then
            let
              x86_64-linuxpkgs = import nixpkgs {
                system = "x86_64-linux";
                config = {
                  allowUnfree = true;
                };
              };
            in
            {
              ArtixGameLauncher = x86_64-linuxpkgs.callPackage ./Artix_Game_Launcher.nix { };
              wavebox = x86_64-linuxpkgs.callPackage ./wavebox.nix { };
            }
          else
            { };
      in
      {
        packages = {
          kando = pkgs.callPackage ./kando.nix { };
          hello = pkgs.callPackage ./hello.nix { };
          default-browser = pkgs.callPackage ./default-browser.nix { };
          neovimConfigured = nvfLocal.packages.${system}.neovimConfigured;
        }
        // linux_pkgs;
      }
    )
    // {
      overlays.default = import ./overlay.nix;
    };
}
