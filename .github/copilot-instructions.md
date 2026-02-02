# Personal Nix Packages Repository

This repository maintains Nix packages for software not in nixpkgs or with bleeding-edge updates. Packages are available as a flake overlay.

## Repository Structure

- **Root-level `.nix` files**: Individual package definitions (e.g., `gemini-cli.nix`, `wavebox.nix`)
- **`warp-terminal/` directory**: Complex package with separate `default.nix`, `update.sh`, and `versions.json`
- **`flake.nix`**: Main entry point defining package set with platform-specific conditionals
- **`overlay.nix`**: Nixpkgs overlay for integrating packages into other configurations
- **`update.sh`**: Automated update script for package versions

## Platform Architecture

Packages are conditionally exposed based on platform:

- **All platforms**: `kando`, `hello`, `gemini-cli`, `github-copilot-cli`, `warp-terminal`, `neovimConfigured`
- **x86_64-linux only**: `ArtixGameLauncher`, `wavebox` (defined in `x86-linux-pkgs`)
- **Linux only**: `xdg-browser-exec` (defined in `linux-pkgs`)

The flake uses `flake-utils.lib.eachDefaultSystem` with conditionals like:
```nix
if system == "x86_64-linux" then { ... } else { }
if builtins.match "^.+linux$" system != null then { ... } else { }
```

## Package Conventions

### Standard Package Structure

Most packages follow this pattern (see `gemini-cli.nix`):

1. **Inputs at top**: List all required dependencies from nixpkgs
2. **Version management**: Explicit `version` attribute in derivation
3. **Update script**: Include `passthru.updateScript = nix-update-script { };` for automated updates
4. **Meta attributes**: Always include `description`, `homepage`, `license`, `platforms`, `maintainers`
5. **Unfree licenses**: Mark as `licenses.unfree` for proprietary software (warp-terminal, wavebox, etc.)
6. **Source provenance**: Use `sourceProvenance = with lib.sourceTypes; [ fromSource ]` or `[ binaryBytecode ]` as appropriate

### AppImage Packages

For AppImage-based packages (e.g., `Artix_Game_Launcher.nix`):

- Use `appimageTools.extract` to unpack contents
- Use `appimageTools.wrapType2` for the final derivation
- Extract `.desktop` files and icons in `extraInstallCommands`
- Set `platforms = [ "x86_64-linux" ]` as most AppImages are x86_64-only

### Complex Packages

Packages with multiple files (like `warp-terminal/`) use:

- `versions.json`: Stores version and hash info for multiple platforms
- `update.sh`: Custom script to fetch latest versions and update `versions.json`
- `default.nix`: Reads from `versions.json` using `lib.importJSON ./versions.json`
- `passthru.updateScript = ./update.sh` for automation

## Update Workflow

### Manual Updates

```bash
# Update all packages automatically
./update.sh

# Update specific package manually
nix-update <package-name> --flake

# Update flake inputs
nix flake update
```

The `update.sh` script:
1. Fetches latest versions from upstream sources
2. Runs `nix-update` for simple packages
3. Updates version numbers in README.md table automatically
4. For warp-terminal, calls `./warp-terminal/update.sh` separately

### Automated Updates

GitHub Actions runs nightly at 8:13 UTC (`update.yml`):
1. Updates flake inputs
2. Runs `./update.sh`
3. Builds select packages for Cachix cache
4. Creates and auto-merges a PR with updates

## Building and Testing

```bash
# Build a specific package
nix build .#<package-name>

# Run a package without installing
nix run .#<package-name>

# Build all packages (where platform-appropriate)
nix flake check

# Test the overlay
nix build .#overlays.default
```

## License Configuration

Many packages are **unfree** (github-copilot-cli, warp-terminal, wavebox, ArtixGameLauncher). The flake.nix sets `config.allowUnfree = true` by default. Users importing this flake must also enable unfree packages in their configuration.

## When Adding New Packages

1. Create a `.nix` file at repository root (or subdirectory for complex packages)
2. Add to `flake.nix` under the appropriate platform section in `packages = { ... }`
3. Add to `overlay.nix` if the package should be available as an overlay
4. Include `passthru.updateScript` if the package can be auto-updated
5. Add entry to README.md table with version, description, and platforms
6. Consider adding to `simple_update_pkgs` array in `update.sh` if using `nix-update`
7. For unfree packages, set `license = licenses.unfree` and document in README

## nvf Integration

The `neovimConfigured` package uses the `nvf` flake input (notashelf/nvf) for building a configured Neovim distribution. This is defined in `nvf.nix` and integrated via `nvfLocal.packages.${system}.neovimConfigured` in flake.nix.
