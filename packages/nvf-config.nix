{pkgs, ...}: {
  vim = {
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    statusline.lualine.enable = true;
    telescope.enable = true;

    extraPlugins = with pkgs.vimPlugins; {
      tiny-inline-diagnostics = {
        package = tiny-inline-diagnostic-nvim;
        setup = "require('tiny-inline-diagnostic').setup({options = {multilines = {enabled = true, always_show = true, trim_whitespaces = true}}})";
      };
      nvim-lastplace = {
        package = nvim-lastplace;
        setup = "require('nvim-lastplace').setup({lastplace_ignore_buftype = {'quickfix', 'nofile', 'help'}, lastplace_ignore_filetype = {'gitcommit', 'gitrebase', 'svn', 'hgcommit'}, lastplace_open_folds = true})";
      };
    };

    clipboard = {
      enable = true;
      #      providers.wl-copy.enable = true;
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

    autocomplete = {
      nvim-cmp = {
        enable = true;
        setupOpts.completion.completeopt = "menu,menuone,noselect";
        sources = {
          buffer = "[Buffer]";
          path = "[Path]";
        };
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
        extensions.crates-nvim.enable = true;
        format.enable = true;
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
      go = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      python = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      terraform = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      markdown = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
      };
      json = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      yaml = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
      html = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
      };
      css = {
        enable = true;
        format.enable = true;
        treesitter.enable = true;
      };
      ts = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };
    };
  };
}
