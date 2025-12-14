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

            tab = "swapm(app_switch, A-tab)";

            space = "M-space";
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
      };
    };
  };
}
