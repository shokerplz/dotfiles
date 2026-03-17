{
  config,
  pkgs,
  lib,
  nixpkgs-unstable,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./amd.nix
    ./power.nix
    ./docker.nix
    ./sunshine.nix
    ./overlays.nix
    ./gaming-performance.nix
    ./win-pc-conn.nix
    ../../services/node-exporter.nix
    ../../common/nfs-client.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # Reduce bootloader wait time (hold key to see menu)

  # Boot optimizations
  systemd.services.NetworkManager-wait-online.enable = false; # Not needed for desktop
  systemd.network.wait-online.enable = false; # Disable systemd-networkd wait too

  # Start docker lazily via socket activation (starts on first docker command)
  virtualisation.docker.enableOnBoot = lib.mkForce false; # Override common config

  # Defer VirtualBox network setup - not needed until VMs are started
  systemd.services."vboxnet0" = {
    wantedBy = lib.mkForce []; # Don't start at boot
    after = ["graphical.target"];
  };
  systemd.services."network-addresses-vboxnet0" = {
    wantedBy = lib.mkForce []; # Don't start at boot
  };

  # Defer libvirt - use socket activation
  virtualisation.libvirtd.onBoot = "ignore";

  # installs the udev rules and the Solaar (tool for logitech devices)
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true; # starts a tray icon

  # Fix sound delay
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N enable_msi=1
  '';

  boot.kernelParams = [
    "pcie_port_pm=off"
    "pcie_aspm.policy=performance"
  ];

  # Allow to build aarch64
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  nix = {
    settings = {
      extra-platforms = ["aarch64-linux"];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 48 * 1024;
    }
  ];

  networking.hostName = "main-pc"; # Define your hostname.

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["ikovalev"];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = ["kvm-amd"];
  users.extraGroups."qemu-libvirtd".members = ["ikovalev"];
  users.extraGroups.libvirtd.members = ["ikovalev"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
