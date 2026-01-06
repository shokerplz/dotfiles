# Hyprland-related services (hyprpaper, hypridle, udiskie)
{...}: {
  # Auto-mount USB drives and removable media
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto"; # Show tray icon when devices are mounted
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        # "/path/to/default/wallpaper.png"
      ];
      wallpaper = [
        # "monitor,/path/to/default/wallpaper.png"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # No lock commands - user explicitly doesn't want locking
        lock_cmd = "";
        before_sleep_cmd = "";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        # Dim screen after 2.5 minutes
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 5%";
          on-resume = "brightnessctl -r";
        }
        # Turn off screen after 5 minutes
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
