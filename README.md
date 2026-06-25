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
          environment.systemPackages = [ pkgs.antigravity-cli ];
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
nix run github:jtliang24/personal-nix-repo#antigravity-cli
```

## Available Packages

| Package                   | Version                      | Description                                                                                                 | Platforms      |
| :------------------------ | :--------------------------- | :---------------------------------------------------------------------------------------------------------- | :------------- |
| **antigravity-cli**       | 1.0.12                        | Official CLI for Antigravity.                                                                               | Linux, Darwin  |
| **antigravity-ide**       | 2.1.1                        | Agentic development platform, evolving the IDE into the agent-first era.                                    | Linux, Darwin  |
| **ArtixGameLauncher**     | 2.20                         | Artix Games Launcher (appimage launcher), packaged for non-NixOS systems.                                   | `x86_64-linux` |
| **gh-aw**                 | 0.80.9                       | GitHub CLI extension for Actions Workflow management.                                                       | All            |
| **github-copilot-cli**    | 1.0.65                       | Github Copilot coding agent directly in your terminal.                                                      | All            |
| **neovimConfigured**      | -                            | Personal Neovim configuration using `nvf` (lightweight version).                                            | All            |
| **neovimConfigured-full** | -                            | Personal Neovim configuration using `nvf` (full version with LSPs, CodeCompanion, and Markdown extensions). | All            |
| **warp-terminal**         | 0.2026.06.17.09.49.stable_02 | Rust-based terminal reimagined for the 21st century.                                                        | Linux, Darwin  |
| **wavebox**               | 149.2.103-2                   | The Wavebox productivity browser.                                                                           | `x86_64-linux` |

> [!IMPORTANT]
> `antigravity-cli`, `antigravity-ide`, `ArtixGameLauncher`, `wavebox`,
> `github-copilot-cli`, and `warp-terminal` are unfree packages. Ensure
> `allowUnfree = true;` is set in your Nixpkgs configuration.

Note that the software packaged here may be subject to their own respective
licenses (e.g., Antigravity CLI, Warp Terminal, Wavebox).
