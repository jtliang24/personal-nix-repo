# AI Instructions: Personal Nix Packages Repository

This document provides context and guidelines for AI agents working on this repository. This repository maintains Nix packages for software not in nixpkgs or with bleeding-edge updates, available as a flake overlay.

## Repository Structure

- **Root-level `.nix` files**: Individual package definitions (e.g., `gemini-cli.nix`, `wavebox.nix`).
- **`warp-terminal/` directory**: Complex package with separate `default.nix`, `update.sh`, and `versions.json`.
- **`flake.nix`**: Main entry point defining package set with platform-specific conditionals.
- **`overlay.nix`**: Nixpkgs overlay for integrating packages into other configurations.
- **`update.sh`**: Automated update script for package versions.

## Platform Architecture

Packages are conditionally exposed based on platform:

- **All platforms**: `hello`, `gemini-cli`, `github-copilot-cli`, `warp-terminal`, `neovimConfigured`.
- **x86_64-linux only**: `ArtixGameLauncher`, `wavebox` (defined in `x86-linux-pkgs`).
- **Linux only**: `xdg-browser-exec` (defined in `linux-pkgs`).

The flake uses `flake-utils.lib.eachDefaultSystem` with conditionals like:
```nix
if system == "x86_64-linux" then { ... } else { }
if builtins.match "^.+linux$" system != null then { ... } else { }
```

## Package Conventions

### Standard Package Structure
Follow the pattern in `gemini-cli.nix`:
1. **Inputs at top**: List all required dependencies from nixpkgs.
2. **Version management**: Explicit `version` attribute in derivation.
3. **Update script**: Include `passthru.updateScript = nix-update-script { };`.
4. **Meta attributes**: Include `description`, `homepage`, `license`, `platforms`, and `maintainers`.
5. **Unfree licenses**: Mark as `licenses.unfree` for proprietary software.
6. **Source provenance**: Use `sourceProvenance = with lib.sourceTypes; [ fromSource ]` or `[ binaryBytecode ]` as appropriate.

### AppImage Packages
For AppImage-based packages (e.g., `Artix_Game_Launcher.nix`):
- Use `appimageTools.extract` to unpack contents and `appimageTools.wrapType2` for the final derivation.
- Extract `.desktop` files and icons in `extraInstallCommands`.
- Set `platforms = [ "x86_64-linux" ]`.

### Complex Packages
For packages like `warp-terminal/`:
- `versions.json`: Stores version and hash info.
- `update.sh`: Custom script to fetch latest versions and update `versions.json`.
- `default.nix`: Reads from `versions.json` using `lib.importJSON ./versions.json`.

## Workflows

### Update Workflow
- **Global update**: Run `./update.sh`.
- **Single package**: `nix-update <package-name> --flake`.
- **Verify version**: `nix eval --raw .#<package-name>.version`.
- **Flake inputs**: `nix flake update`.

### Build and Test
- **Build**: `nix build .#<package-name>`.
- **Run**: `nix run .#<package-name>`.
- **Check all**: `nix flake check`.
- **Test overlay**: `nix build .#overlays.default`.

## When Adding New Packages

1. Create a `.nix` file at root (or subdirectory for complex packages).
2. Add to `flake.nix` under the appropriate platform section.
3. Add to `overlay.nix`.
4. Include `passthru.updateScript`.
5. Add entry to README.md table (version, description, platforms).
6. Update `simple_update_pkgs` in `update.sh` if using `nix-update`.
7. Mark `license = licenses.unfree` if applicable.

## Integration Details

- **nvf**: `neovimConfigured` uses the `nvf` flake input. Defined in `nvf.nix` and integrated via `nvfLocal.packages.${system}.neovimConfigured`.
- **License**: `flake.nix` sets `config.allowUnfree = true` by default.

## gh aw Workflow Maintenance

When compiling agentic workflow `.md` files to `.lock.yml`, **always** pin the action tag to match the installed version:

```bash
gh aw compile --action-tag v<installed-version> <workflow.md>
```

**Constraints for CI compatibility:**
- **Avoid default (dev mode)**: Generates relative paths that fail in CI.
- **Avoid `--action-mode script`**: Fails due to filesystem permission/location constraints in GitHub Actions.
- **Avoid `--action-tag main`**: Risk of version drift.

**Upgrade procedure:**
1. Update local `gh-aw` (e.g., `nix-update gh-aw --flake`).
2. Recompile lock files: `gh aw compile --action-tag v<new-version>`.
3. Pinned version and SHA are in `.github/aw/actions-lock.json`.