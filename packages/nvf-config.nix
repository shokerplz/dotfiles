{pkgs, ...}: {
  vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;

    extraPlugins = with pkgs.vimPlugins; {
      tiny-inline-diagnostics = {
        package = tiny-inline-diagnostic-nvim;
        setup = "require('tiny-inline-diagnostic').setup({options = {multilines = {enabled = true, always_show = true, trim_whitespaces = true}}})";
      };
    };

    undoFile.enable = true;

    spellcheck = {
      enable = true;
    };

    options = {
      tabstop = 2;
      shiftwidth = 2;
    };

    diagnostics = {
      config = {
        underline = true;
        virtual_lines = true;
      };
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
      trouble.enable = true;
    };

    languages = {
      enableTreesitter = true;

      nix = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };

      rust = {
        enable = true;
        crates = {
          enable = true;
        };
        lsp = {
          enable = true;
          opts = ''
            ['rust-analyzer'] = {
              cargo = {allFeature = true},
              checkOnSave = true,
              procMacro = {
                enable = true,
              },
            },
          '';
        };
        treesitter.enable = true;
      };
      go.enable = true;
      python.enable = true;
      terraform.enable = true;
      markdown.enable = true;
    };
  };
}
