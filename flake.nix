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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        x86-linux-pkgs =
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
        linux-pkgs =
          if builtins.match "^.+linux$" system != null then
            let
              linuxpkgs = import nixpkgs {
                inherit system;
              };
            in
            {
              xdg-browser-exec = linuxpkgs.callPackage ./xdg-browser-exec.nix { };
            }
          else
            { };
      in
      {
        packages = {
          kando = pkgs.callPackage ./kando.nix { };
          hello = pkgs.callPackage ./hello.nix { };
          gemini-cli = pkgs.callPackage ./gemini-cli.nix { };
          github-copilot-cli = pkgs.callPackage ./github-copilot-cli.nix { };
          warp-terminal = pkgs.callPackage ./warp-terminal { };
          inherit (nvfLocal.packages.${system}) neovimConfigured;
        }
        // x86-linux-pkgs
        // linux-pkgs;
      }
    )
    // {
      overlays.default = import ./overlay.nix;
    };
}
