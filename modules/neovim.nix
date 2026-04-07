{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      configModule = {
        config.vim = {
          startPlugins = with pkgs.vimPlugins; [
            lazygit-nvim
          ];

          extraPackages = with pkgs; [
            nodejs_25
            tree-sitter
          ];

          assistant = {
            copilot = {
              cmp.enable = true;
              enable = true;
              setupOpts = {
                suggestion.enable = true;
              };
            };
          };

          viAlias = false;
          vimAlias = false;

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };
          options = {
            autoindent = true;
            autoread = true;
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

            servers = {
              nil = {
                enable = true;
                settings.nil.nix.flake = {
                  autoArchive = true;
                };
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

          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

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
            html.enable = true;
            css.enable = true;
            json.enable = true;
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
              lazygit.enable = true;
            };
          };
        };
      };

      neovimConfigured = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [ configModule ];
      };
    in
    {
      packages.neovimConfigured = neovimConfigured.neovim;
    };
}
