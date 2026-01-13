{
  config,
  pkgs,
  ...
}: {
  powerManagement.enable = true;
  # Enabled IIO sensor (automatic rotation)
  hardware.sensor.iio.enable = true;

  # Disable WiFi power saving for stable connections
  networking.networkmanager.wifi.powersave = false;
}
