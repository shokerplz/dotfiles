# Hyprland desktop environment configuration
# Modular setup for window manager, status bar, launchers, and services
{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./noctalia.nix
  ];

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    wl-clipboard
    wtype
    nautilus
    loupe # Image viewer (GNOME, Wayland-native)
    mpv # Video player
    celluloid # GTK frontend for mpv
    evince # PDF/document viewer
    file-roller # Archive manager
    gnome-calculator
    gnome-text-editor
    gnome-calendar
    # Audio control
    pavucontrol
    # Bluetooth
    blueberry
    # Network management
    networkmanagerapplet # For nm-connection-editor
    # File picker dialogs
    zenity
    # Display configuration
    nwg-displays
    wlr-randr
    # Debugging
    wev
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };
}
