{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;

  # Bluetooth support (service only starts if hardware present)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # WiFi via iwd (used by iwgtk)
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
      };
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper

    # Notification Daemon
    dunst
    libnotify

    # App launchers
    wofi

    # Status bar
    waybar

    # Terminal
    kitty

    # Screenshots & Screen Recording
    grim
    slurp
    grimblast # Hyprland screenshot helper
    gpu-screen-recorder # GPU-accelerated recording

    # Clipboard
    wl-clipboard
    cliphist
    wtype # For auto-paste simulation

    # File manager
    nautilus

    # Auth
    hyprpolkitagent

    # Audio control
    pavucontrol

    # Bluetooth
    blueberry

    # Network management
    iwgtk # WiFi management GUI for iwd
    networkmanagerapplet # For nm-connection-editor

    # File picker dialogs
    zenity

    # Display configuration
    nwg-displays
    wlr-randr # CLI tool nwg-displays uses

    # Control Center widget
    eww
    pamixer # CLI volume control
    playerctl # Media player control
    jq # JSON parsing for scripts
    pulseaudio # For pactl command
    brightnessctl # Brightness control (for laptops)

    # Debugging
    wev
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };
}
