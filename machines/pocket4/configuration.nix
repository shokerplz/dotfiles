{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./overlays.nix
    ./power.nix
    ./ai.nix
    ./fix-screen-rotation-sleep.nix
    ../../services/node-exporter.nix
    ../../common/nfs-client.nix
    ../../common/docker.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = ["amd_iommu=off" "amdgpu.gttsize=65536" "ttm.pages_limit=67108864"];

  networking.hostName = "pocket4"; # Define your hostname.

  # Use systemd-resolve so DNS works fine with WireGuard VPN
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;
  networking.nameservers = ["127.0.0.53"];

  hardware.graphics = {
    ## radv: an open-source Vulkan driver from freedesktop
    enable32Bit = true;
  };

  hardware.gpd-fan.enable = true;

  hardware.amdgpu.opencl.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  users.users.ikovalev.extraGroups = [
    "video"
    "render"
    "libvirtd"
  ];

  # Allow openssh, but disable it by default
  services.openssh = {
    enable = true;
    ports = [22];
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = ["ikovalev"];
      PermitRootLogin = "no";
    };
  };
  systemd.services.sshd.wantedBy = lib.mkForce [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
