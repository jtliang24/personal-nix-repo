{
  self,
  nixpkgs,
  ...
}@inputs:
let
  # An abstraction over systems to easily provide the same package
  # for multiple systems. This is preferable to abstraction libraries.
  forEachSystem = nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];
in
{
  packages = forEachSystem (
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # A module to be evaluated via lib.evalModules inside nvf's module system.
      # All options supported by nvf will go under config.vim to create the final
      # wrapped package. You may also add some new *options* under options.* to
      # expand the module system.
      configModule = {
        # You may browse available options for nvf on the online manual. Please see
        # <https://notashelf.github.io/nvf/options.html>
        config.vim = {
          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };
          options = {
            autoindent = true;
            tabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            foldlevel = 99;
            undofile = true;
          };

          diagnostics = {
            enable = true;
            config = {
              underline = true;
              signs.text = inputs.nixpkgs.lib.generators.mkLuaInline ''
                {
                  [vim.diagnostic.severity.ERROR] = "󰅚",
                  [vim.diagnostic.severity.WARN] = "󰀪",
                }
              '';
            };
          };

          lsp = {
            # Enable LSP functionality globally. This is required for modules found
            # in `vim.languages` to enable relevant LSPs.
            enable = true;

            formatOnSave = true;
            lightbulb = {
              enable = false;
              setupOpts = {
                sign.enabled = false;
                float.enabled = true;
              };
            };
            trouble.enable = true;

            # You may define your own LSP configurations using `vim.lsp.servers` in
            # nvf without ever needing lspconfig to do it. This will use the native
            # API provided by Neovim > 0.11
            servers = {
              nil = {
                enable = true;
                settings.nil.nix.flake.autoArchive = true;
              };
            };
          };

          mini = {
            starter.enable = true;
            #tabline.enable = true;
          };

          binds.whichKey.enable = true;

          tabline.nvimBufferline.enable = true;

          filetree = {
            neo-tree.enable = true;
          };

          treesitter = {
            enable = true;
            context.enable = true;
            indent.enable = true;
          };

          # Language support and automatic configuration of companion plugins.
          # Note that enabling, e.g., languages.<lang>.diagnostics will automatically
          # enable top-level options such as enableLSP or enableExtraDiagnostics as
          # they are needed.
          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            # Nix language and diagnostics.
            nix = {
              enable = true;
              format = {
                enable = true;
                type = [ "nixfmt" ];
              };
              lsp.enable = true;
              treesitter.enable = true;
            };
            markdown = {
              enable = true;
              extensions = {
                markview-nvim.enable = true;
              };
            };
            bash.enable = true;
            lua.enable = true;
            python.enable = true;
          };

          visuals = {
            nvim-scrollbar.enable = true;
            nvim-web-devicons.enable = true;
            nvim-cursorline.enable = true;
            cinnamon-nvim.enable = true;

            indent-blankline.enable = true;
          };

          statusline.lualine = {
            enable = true;
          };

          autopairs.nvim-autopairs.enable = true;

          autocomplete.nvim-cmp.enable = true;

          notify.nvim-notify.enable = true;

          snippets.luasnip.enable = true;

          git = {
            enable = true;
            #gitsigns.enable = true;
          };

          ui = {
            nvim-ufo.enable = true;
            illuminate.enable = true;
            colorizer.enable = true;
          };

          utility = {
            snacks-nvim = {
              enable = true;
              setupOpts = {
                statuscolumn = {
                  enabled = true;
                  left = [
                    "sign"
                    "git"
                  ];
                  right = [
                    "fold"
                  ];
                  folds.open = true;
                };
              };
            };
            undotree.enable = true;
          };

          terminal = {
            toggleterm = {
              enable = true;
            };
          };
        };
      };

      # Evaluate any and all modules to create the wrapped Neovim package.
      neovimConfigured = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;

        modules = [
          # Configuration module to be imported. You may define multiple modules
          # or even import them from other files (e.g., ./modules/lsp.nix) to
          # better modularize your configuration.
          configModule
        ];
      };
    in
    {
      # Packages to be exposed under packages.<system>. Those can accessed
      # directly from package outputs in other flakes if this flake is added
      # as an input. You may run those packages with 'nix run .#<package>'
      default = self.packages.${system}.neovimConfigured;
      neovimConfigured = neovimConfigured.neovim;
    }
  );
}
