{...}: {
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["3434:0e20"]; # Only Keychron k2
        settings = {
          main = {
            leftmeta = "layer(command)";
            leftalt = "layer(option)";
          };

          "command:C" = {
            c = "C-insert";
            v = "S-insert";
            x = "S-delete";

            left = "home";
            right = "end";
            up = "C-home";
            down = "C-end";

            backspace = "C-u";

            # Command+Space → Ctrl+Space for language switching
            space = "M-space";

            # Pass through for Hyprland window switching
            tab = "M-tab";

            # Pass through for Hyprland workspaces (Super+Number)
            "1" = "M-1";
            "2" = "M-2";
            "3" = "M-3";
            "4" = "M-4";
            "5" = "M-5";
            "6" = "M-6";
            "7" = "M-7";
            "8" = "M-8";
            "9" = "M-9";
          };

          "option:A" = {
            left = "C-left";
            right = "C-right";
            backspace = "A-backspace";
          };

          "app_switch:A" = {
            tab = "A-tab";
            "S-tab" = "A-S-tab";
          };
        };

        # Composite layers MUST come AFTER constituent layers
        # NixOS settings dict is alphabetically sorted, so we use extraConfig
        extraConfig = ''
          [command+shift]
          v = M-S-v
          tab = M-S-tab
          1 = M-S-1
          2 = M-S-2
          3 = M-S-3
          4 = M-S-4
          5 = M-S-5
          6 = M-S-6
          7 = M-S-7
          8 = M-S-8
          9 = M-S-9
        '';
      };
    };
  };
}
