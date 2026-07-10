{pkgs-current, ...}: {
  environment.systemPackages = [
    (pkgs-current.lib.hiPrio (pkgs-current.makeDesktopItem {
      name = "dev.lizardbyte.app.Sunshine";
      desktopName = "Sunshine";
      comment = "Start Sunshine game streaming";
      exec = "systemctl --user start sunshine";
      icon = "dev.lizardbyte.app.Sunshine";
      categories = [
        "Network"
        "RemoteAccess"
      ];
    }))
  ];

  boot.kernelModules = ["uhid"];

  services.udev.extraRules = ''
    KERNEL=="uhid", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", TAG+="uaccess"
  '';

  users.users.ikovalev.extraGroups = ["uinput"];

  services.sunshine = {
    autoStart = false;
    enable = true;
    capSysAdmin = true;
    settings = {
      output_name = "0";
      gamepad = "ds5";
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
          image-path = "${pkgs-current.sunshine}/assets/desktop.png";
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
          image-path = "${pkgs-current.sunshine}/assets/desktop.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "Steam Big Picture";
          image-path = "${pkgs-current.sunshine}/assets/steam.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
            {
              do = "noctalia-shell ipc call notifications enableDND";
              undo = "noctalia-shell ipc call notifications disableDND";
            }
            {
              undo = "setsid steam steam://close/bigpicture";
            }
          ];
          detached = ["setsid steam steam://open/bigpicture"];
        }
        {
          name = "BloodBorne";
          image-path = "/home/ikovalev/.config/sunshine/covers/igdb_7334.png";
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
