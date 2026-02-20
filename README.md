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

## Usage

You can run any package directly using `nix run` without installing it:

```bash
nix run github:jtliang24/personal-nix-repo#<package_name>
```

For example:

```bash
nix run github:jtliang24/personal-nix-repo#gemini-cli
```

## Available Packages

| Package                | Version                      | Description                                                            | Platforms      |
| :--------------------- | :--------------------------- | :--------------------------------------------------------------------- | :------------- |
| **ArtixGameLauncher**  | 2.20                         | Official Artix Games Launcher (AppImage wrapper).                      | `x86_64-linux` |
| **gemini-cli**         | 0.29.5                       | AI agent bringing Gemini directly into your terminal.                  | All            |
| **gemini-cli-bin**     | 0.29.5                       | Binary version of Gemini CLI (faster installation).                    | Linux, Darwin  |
| **github-copilot-cli** | 0.0.412                      | Github Copilot coding agent directly in your terminal.                 | All            |
| **kando**              | 2.2.0                        | Cross-platform pie menu for efficient workflows.                       | Linux, Darwin  |
| **neovimConfigured**   | -                            | Neovim distribution configured via `nvf` with LSP and UI enhancements. | All            |
| **warp-terminal**      | 0.2026.02.18.08.22.stable_02 | Rust-based terminal reimagined for the 21st century.                   | Linux, Darwin  |
| **wavebox**            | 10.145.17-2                  | The Wavebox productivity browser.                                      | `x86_64-linux` |
| **xdg-browser-exec**   | -                            | Script to launch the default XDG web browser with verbose logging.     | Linux          |
| **hello**              | 2.12.1                       | GNU Hello, a simple test package.                                      | All            |

> [!IMPORTANT]
> `ArtixGameLauncher`, `wavebox`, `github-copilot-cli`, and `warp-terminal` are
> unfree packages. Ensure `allowUnfree = true;` is set in your Nixpkgs
> configuration.

Note that the software packaged here may be subject to their own respective
licenses (e.g., Google's Gemini CLI, Warp Terminal, Wavebox).
