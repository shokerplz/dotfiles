{pkgs, ...}: {
  colorschemes.gruvbox = {
    enable = true;
    settings = {
      transparent_mode = false;
      terminal_colors = true;
    };
  };

  plugins = {
    lualine.enable = true;
    telescope.enable = true;
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
        ];
      };
    };
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    treesitter.enable = true;
    trouble.enable = true;
    web-devicons.enable = true;
    crates.enable = true;
    lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          settings = {
            cargo = {
              allFeatures = true;
            };
            checkOnSave = true;
            procMacro = {
              enable = true;
            };
          };
        };
        gopls.enable = true;
        pyright.enable = true;
        terraformls.enable = true;
        marksman.enable = true;
      };
    };
    lsp-format.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    tiny-inline-diagnostic-nvim
  ];

  extraConfigLua = ''
    require('tiny-inline-diagnostic').setup({options = {multilines = {enabled = true, always_show = true, trim_whitespaces = true}}})
  '';

  clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };

  opts = {
    undofile = true;
    spell = true;
    tabstop = 2;
    shiftwidth = 2;
  };

  diagnostic.settings = {
    underline = true;
    virtual_lines.only_current_line = true;
  };
}
