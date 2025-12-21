# Personal Nix Packages Repository.

This is a personal repository of packages that are not in nixpkgs, or are outdated in nixpkgs.

Run with flake-enabled nix with:

```
nix run github:jtliang24/personal-nix-repo#{pkg_name}
```

or add as input to your own NixOS system flake.

### Current package list:

* ArtixGameLauncher
  * Launcher for Artix Entertainment Games
  * `x86-64_linux` systems only.
* Kando
  * version 2.0.0

* neovimConfigured
  * Neovim build configured via the `nvf` integration (see `nvf.nix`).
  * Exposed per-system; example run for this machine:
    - `nix run .#packages.x86_64-linux.neovimConfigured`

Notes:
- `ArtixGameLauncher` is provided only for `x86_64-linux` and relies on an unfree derivation. The flake scopes `allowUnfree` to that import so other package evaluations are not affected.
- The `neovimConfigured` package is produced by importing `nvf.nix` and evaluating the nvf neovim configuration.
