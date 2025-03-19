{ config, pkgs, ... }:

{
  # Enabled IIO sensor (automatic rotation)
  hardware.sensor.iio.enable = true;

  # Auto CPU freq
  services.power-profiles-daemon.enable = false;
  programs.auto-cpufreq.enable = true;

  # Default auto cpufreq settings
  programs.auto-cpufreq.settings = {
    charger = {
      governor = "performance";
      turbo = "auto";
    };
    battery = {
      governor = "powersave";
      turbo = "auto";
    };
  };
}
