{ config, pkgs, ... }:

{
  home.username = "ikovalev";
  home.homeDirectory = "/home/ikovalev";

  home.stateVersion = "24.11"; # Do not change that!

  programs.home-manager.enable = true; # Home manager manages itself

  programs.alacritty = {
    enable = true;
    settings = {
      keyboard.bindings = [
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control";
          chars = "\\u0003";
        }
      ];
    };
  };

  programs.neovim.enable = true;

  programs.ssh = {
    enable = true;
  };

  programs.keychain = {
    enable = true;
    agents = [ "ssh" ];
    keys = [ "~/.ssh/do_key" ];
    extraFlags = [ "--quiet" ];
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      TERMINAL = "alacritty";
      XCURSOR_THEME = "Adwaita alacritty";
      EDITOR = "nvim";
    };
  };

  home.packages = with pkgs; [
    # Additional packages here
  ];

}
