{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./nvidia.nix
    ./docker.nix
    ./sunshine.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme2n1";
  boot.loader.grub.useOSProber = true;

  # Fix sound delay
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N enable_msi=1
  '';

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  networking.hostName = "main-pc"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
