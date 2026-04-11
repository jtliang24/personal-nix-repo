# Personal Nix Packages Repository

This repository contains a collection of Nix packages that are either not found
in `nixpkgs` or are maintained here with bleeding-edge nightly updates.

## Installation

To use these packages in your own NixOS or Home Manager configuration, add this
repository to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    personal-nix-repo.url = "github:jtliang24/personal-nix-repo";
  };

  outputs = { self, nixpkgs, personal-nix-repo, ... }: {
    # Access packages via personal-nix-repo.packages.${system}.<name>
  };
}
```

## Using the Overlay

You can also use the overlay to integrate these packages directly into your
`pkgs` set. This is particularly useful for NixOS or Home Manager
configurations.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    personal-nix-repo.url = "github:jtliang24/personal-nix-repo";
  };

  outputs = { self, nixpkgs, personal-nix-repo, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ personal-nix-repo.overlays.default ];
          environment.systemPackages = [ pkgs.gemini-cli ];
        })
      ];
    };
  };
}
```

## Direct Usage

You can run any package directly using `nix run` without installing it:

```bash
nix run github:jtliang24/personal-nix-repo#<package_name>
```

For example:

```bash
nix run github:jtliang24/personal-nix-repo#wgemini-cli
```

## Available Packages

| Package                | Version                      | Description                                                               | Platforms      |
| :--------------------- | :--------------------------- | :------------------------------------------------------------------------ | :------------- |
| **ArtixGameLauncher**  | 2.20                         | Artix Games Launcher (appimage launcher), packaged for non-NixOS systems. | `x86_64-linux` |
| **gemini-cli**         | 0.37.1                       | AI agent bringing Gemini directly into your terminal.                     | All            |
| **gemini-cli-bin**     | 0.37.1                       | Binary version of Gemini CLI (faster installation).                       | Linux, Darwin  |
| **gh-aw**              | 0.68.1                       | GitHub CLI extension for Actions Workflow management.                     | All            |
| **github-copilot-cli** | 1.0.24                       | Github Copilot coding agent directly in your terminal.                    | All            |
| **neovimConfigured**   | -                            | Personal Neovim configuration using `nvf` with LSP and UI enhancements.   | All            |
| **warp-terminal**      | 0.2026.04.08.08.36.stable_02 | Rust-based terminal reimagined for the 21st century.                      | Linux, Darwin  |
| **wavebox**            | 10.147.44-2                  | The Wavebox productivity browser.                                         | `x86_64-linux` |

> [!IMPORTANT]
> `ArtixGameLauncher`, `wavebox`, `github-copilot-cli`, and `warp-terminal` are
> unfree packages. Ensure `allowUnfree = true;` is set in your Nixpkgs
> configuration.

Note that the software packaged here may be subject to their own respective
licenses (e.g., Google's Gemini CLI, Warp Terminal, Wavebox).
