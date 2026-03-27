# Hyprland-related services (hyprpaper, hypridle, udiskie)
{...}: {
  # Auto-mount USB drives and removable media
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto"; # Show tray icon when devices are mounted
  };
}
