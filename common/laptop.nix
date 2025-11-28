{
  config,
  pkgs,
  ...
}: {
  powerManagement.enable = true;
  # Enabled IIO sensor (automatic rotation)
  hardware.sensor.iio.enable = true;

  services.power-profiles-daemon.enable = true;
}
