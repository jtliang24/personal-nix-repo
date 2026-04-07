# Personal Nix Packages Repository

This repository maintains Nix packages for software not in nixpkgs or with bleeding-edge updates. Packages are available as a flake overlay.

## Repository Structure (Dendritic Pattern)

This repository follows the [dendritic pattern](https://github.com/mightyiam/dendritic): every non-entry-point `.nix` file under `modules/` is a [flake-parts](https://flake.parts) module, auto-imported via [import-tree](https://github.com/vic/import-tree).

- **`flake.nix`**: Entry point — uses `flake-parts` + `import-tree` to auto-import all modules
- **`modules/`**: Flake-parts modules (auto-imported). Each file implements a single feature (one package, the overlay, etc.)
- **`pkgs/`**: `callPackage`-compatible package derivations referenced by modules
- **`update.sh`**: Automated update script for package versions

### Key directories

| Directory | Purpose | Auto-imported? |
|-----------|---------|---------------|
| `modules/` | Flake-parts modules (one feature per file) | Yes (via `import-tree`) |
| `pkgs/` | Package derivation files (`callPackage`-compatible) | No |

## Platform Architecture

Packages are conditionally exposed based on platform using `lib.optionalAttrs` in each module's `perSystem`:

- **All platforms**: `gemini-cli`, `gemini-cli-bin`, `github-copilot-cli`, `gh-aw`, `warp-terminal`, `neovimConfigured`
- **x86_64-linux only**: `ArtixGameLauncher`, `wavebox`

The overlay (`modules/overlay.nix`) mirrors the same platform gating with `optionalAttrs`.

## Package Conventions

### Standard Package Structure

Most packages follow this pattern (see `pkgs/gemini-cli.nix`):

1. **Inputs at top**: List all required dependencies from nixpkgs
2. **Version management**: Explicit `version` attribute in derivation
3. **Update script**: Include `passthru.updateScript = nix-update-script { };` for automated updates
4. **Meta attributes**: Always include `description`, `homepage`, `license`, `platforms`, `maintainers`
5. **Unfree licenses**: Mark as `licenses.unfree` for proprietary software (warp-terminal, wavebox, etc.)
6. **Source provenance**: Use `sourceProvenance = with lib.sourceTypes; [ fromSource ]` or `[ binaryBytecode ]` as appropriate

### AppImage Packages

For AppImage-based packages (e.g., `pkgs/Artix_Game_Launcher.nix`):

- Use `appimageTools.extract` to unpack contents
- Use `appimageTools.wrapType2` for the final derivation
- Extract `.desktop` files and icons in `extraInstallCommands`
- Set `platforms = [ "x86_64-linux" ]` as most AppImages are x86_64-only

### Complex Packages

Packages with multiple files (like `pkgs/warp-terminal/`) use:

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
4. For warp-terminal, calls `./pkgs/warp-terminal/update.sh` separately

### Single-package workflow

```bash
# Update a single package (also updates README version)
nix-update <package-name> --flake
nix eval --raw .#<package-name>.version
```

### Automated Updates

GitHub Actions runs nightly at 8:13 UTC (`update.yml`):
1. Updates flake inputs
2. Runs `./update.sh`
3. Builds select packages for Cachix cache
4. Creates and auto-merges a PR with updates

## Build and test commands

```bash
# Build a specific package (focused check)
nix build .#<package-name>

# Run a package without installing
nix run .#<package-name>

# Build all packages and checks (where platform-appropriate)
nix flake check

# Test the overlay
nix build .#overlays.default
```

## License Configuration

Many packages are **unfree** (github-copilot-cli, warp-terminal, wavebox, ArtixGameLauncher). The flake.nix sets `config.allowUnfree = true` by default. Users importing this flake must also enable unfree packages in their configuration.

## When Adding New Packages

1. Create a `callPackage`-compatible `.nix` file in `pkgs/` (or subdirectory for complex packages)
2. Create a flake-parts module in `modules/` that exposes the package via `perSystem.packages`
3. Add to `modules/overlay.nix` if the package should be available as an overlay
4. For platform-specific packages, use `lib.optionalAttrs` in the module's `perSystem`
5. Include `passthru.updateScript` if the package can be auto-updated
6. Add entry to README.md table with version, description, and platforms
7. Consider adding to `simple_update_pkgs` array in `update.sh` if using `nix-update`
8. For unfree packages, set `license = licenses.unfree` and document in README

## nvf Integration

The `neovimConfigured` package uses the `nvf` flake input (notashelf/nvf) for building a configured Neovim distribution. This is defined in `modules/neovim.nix` as a flake-parts module that accesses `inputs.nvf` directly.

## gh aw Workflow Maintenance

When compiling agentic workflow `.md` files to `.lock.yml`, **always** pin the action tag:

```bash
gh aw compile --action-tag v<installed-version> <workflow.md>
```

Where `<installed-version>` matches `gh aw --version`. This pins `github/gh-aw/actions/setup`
to a specific commit SHA, preventing version drift between the compiled lock file and the runtime.

**Do not use these modes — they all fail in CI:**
- **Default (dev mode)**: generates `uses: ./actions/setup` — fails because the repo isn't checked out at that path
- **`--action-mode script`**: checks out gh-aw to `/tmp/gh-aw/actions-source` — fails because `actions/checkout` cannot write outside the workspace
- **`--action-tag main`**: works temporarily but is unpinned; if the runtime version moves ahead, prompt files (e.g. `xpia.md`) may be missing

**When upgrading gh aw:**
1. Update the local gh aw extension (e.g. `nix-update gh-aw --flake` + rebuild)
2. Recompile all lock files: `gh aw compile --action-tag v<new-version>`
3. Commit the updated `.lock.yml` files

The currently pinned version and SHA are recorded in `.github/aw/actions-lock.json`.
