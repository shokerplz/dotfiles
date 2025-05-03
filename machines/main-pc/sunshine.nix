{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.sunshine = {
    autoStart = true;
    enable = true;
    capSysAdmin = true;
    settings = {
      output_name = "1";
    };
    openFirewall = true;
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
        DISPLAY = ":0";
        GNOME_SETUP_DISPLAY = ":1";
        #        USER = "${config.services.displayManager.autoLogin.user}";
        #        USERNAME = "${config.services.displayManager.autoLogin.user}";
        WAYLAND_DISPLAY = "wayland-0";
        XDG_CURRENT_DESKTOP = "GNOME";
      };
      apps = [
        {
          name = "1080p Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs.gnome-randr}/bin/gnome-randr modify --mode 1920x1080@60.000 DP-2";
              undo = "${pkgs.gnome-randr}/bin/gnome-randr modify --mode 2560x1440@143.999 DP-2";
            }
          ];
        }
        {
          name = "1440p Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "BloodBorne";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs.gnome-randr}/bin/gnome-randr modify --mode 1920x1080@60.000 DP-2";
              undo = "${pkgs.gnome-randr}/bin/gnome-randr modify --mode 2560x1440@143.999 DP-2";
            }
          ];
          cmd = "/home/ikovalev/BB_Launcher -n";
          output = "/home/ikovalev/shadps4-sunshine-out.txt";
        }
      ];
    };
  };
}
