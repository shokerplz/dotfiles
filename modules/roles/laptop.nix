{...}: {
  flake.nixosModules.roleLaptop = {
    powerManagement.enable = true;

    # Enable IIO sensor support for automatic rotation on laptops.
    hardware.sensor.iio.enable = true;

    # Keep Wi-Fi powersave disabled for more stable connections.
    networking.networkmanager.wifi.powersave = false;
  };
}
