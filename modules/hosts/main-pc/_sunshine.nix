{pkgs-current, ...}: {
  services.sunshine = {
    autoStart = true;
    enable = true;
    capSysAdmin = true;
    settings = {
      output_name = "0";
    };
    openFirewall = true;
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
        DISPLAY = ":0";
        WAYLAND_DISPLAY = "wayland-1";
        XDG_CURRENT_DESKTOP = "Hyprland";
      };
      apps = [
        {
          name = "1080p Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.gnome-randr}/bin/gnome-randr modify --mode 1920x1080@60.000 DP-2";
              undo = "${pkgs-current.gnome-randr}/bin/gnome-randr modify --mode 2560x1440@143.999 DP-2";
            }
          ];
        }
        {
          name = "1440p Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "Steam Big Picture";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              undo = "setsid steam steam://close/bigpicture";
            }
          ];
          detached = [ "setsid steam steam://open/bigpicture" ];
        }
        {
          name = "BloodBorne";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
          ];
          cmd = "shadps4 -g /home/ikovalev/ShadPS4/CUSA03173/eboot.bin";
          output = "/home/ikovalev/shadps4-sunshine-out.txt";
        }
      ];
    };
  };
}
