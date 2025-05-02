{ config, pkgs, ... }:

{
    home.username = "ikovalev";
    home.homeDirectory = "/home/ikovalev";

    home.stateVersion = "24.11";        # Do not change that!
                                        
    programs.alacritty = {
      enable = true;
      settings = {
        keyboard.bindings = [
          {
            key = "C";
            mods = "Control";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Control";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Control|Shift";
            chars = "\\u0003";
          }
          {
            key = "D";
            mods = "Control|Shift";
            chars = "\\u0004";
          }
          {
            key = "C";
            mods = "Control|Shift";
            action = "None";
          }
        ];
      };
  };
}

