{
  pkgs,
  ...
}:

{

  imports = [
    ./hardware-configuration.nix
    ./docker.nix
    ./packages.nix
    ./network.nix
    ./nginx/default.nix
    ../../services/grafana.nix
    ../../services/prometheus.nix
    ../../services/promtail.nix
    ../../services/speedtest-exporter.nix
    ../../services/cloudflare-ddns.nix
    ../../services/node-exporter.nix
  ];

  # Set hostname
  networking.hostName = "rpi5";

  # Bootloader stadard config
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = true;

  # Add the RPi kernel
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # Should never be changed!
  system.stateVersion = "24.11"; # Did you read the comment?
}
