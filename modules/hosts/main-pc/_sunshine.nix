{pkgs-current, ...}: let
  # VRR on the streamed monitor makes Sunshine's screen capture uneven (stream stutters).
  noVrr = {
    do = "hyprctl keyword misc:vrr 0";
    undo = "hyprctl keyword misc:vrr 2";
  };
in {
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
            noVrr
            {
              do = "noctalia-shell ipc call notifications enableDND";
              undo = "noctalia-shell ipc call notifications disableDND";
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
            noVrr
          ];
          cmd = "shadps4 -g /home/ikovalev/ShadPS4/CUSA03173/eboot.bin";
          output = "/dev/null";
        }
        {
          name = "Demon's Souls";
          image-path = "/home/ikovalev/.config/sunshine/covers/demons-souls.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
            noVrr
          ];
          # KytyPS5 launcher (60 FPS lock, GPU_BOOST); quitting the app in Moonlight ends it cleanly (SIGTERM).
          cmd = "/data/ProjectData/KytyPS5/play-demons-souls";
          output = "/tmp/demons-souls-sunshine.log";
        }
        {
          name = "Ocarina of Time";
          image-path = "/home/ikovalev/.config/sunshine/covers/ocarina-of-time.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
            noVrr
          ];
          # Lichii launcher (GPU_BOOST, window on DP-2); quitting the app in Moonlight ends it cleanly (SIGTERM).
          cmd = "/data/ProjectData/Lichii/play-ocarina";
          output = "/tmp/ocarina-sunshine.log";
        }
        {
          name = "Mario Kart World";
          image-path = "/home/ikovalev/.config/sunshine/covers/mario-kart-world.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
            noVrr
          ];
          # Lichii launcher (GPU_BOOST, window on DP-2); quitting the app in Moonlight ends it cleanly (SIGTERM).
          cmd = "/data/ProjectData/Lichii/play-mario-kart-world";
          output = "/tmp/mario-kart-world-sunshine.log";
        }
        {
          name = "Tears of the Kingdom";
          image-path = "/home/ikovalev/.config/sunshine/covers/tears-of-the-kingdom.png";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          prep-cmd = [
            {
              do = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 1920x1080@120";
              undo = "${pkgs-current.wlr-randr}/bin/wlr-randr --output DP-2 --mode 2560x1440@143.998993Hz";
            }
            noVrr
          ];
          # Lichii launcher (GPU_BOOST, window on DP-2); quitting the app in Moonlight ends it cleanly (SIGTERM).
          cmd = "/data/ProjectData/Lichii/play-totk";
          output = "/tmp/tears-of-the-kingdom-sunshine.log";
        }
      ];
    };
  };
}
