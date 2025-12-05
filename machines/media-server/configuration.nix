{
  nixpkgs-unstable,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./packages.nix
    ./hardware-configuration.nix
    ./nix-cache.nix
    ../../services/promtail.nix
    ../../services/node-exporter.nix
    ../../services/loki.nix
    ../../services/nextcloud.nix
    ../../services/gitlab.nix
    ../../services/jellyfin.nix
    ../../services/arr.nix
    ../../services/samba.nix
    ../../services/n8n.nix
  ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "30 3 * * * root ${lib.getExe (pkgs.callPackage ../../packages/cache-builder.nix {})}"
    ];
  };

  # This is needed for hardware video encoding
  hardware.graphics.enable = true;

  # Mount ZFS data pool on boot
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = ["pool0"];

  # Allow to build aarch64
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  nix = {
    settings = {
      extra-platforms = ["aarch64-linux"];
    };
  };

  # This is needed for ZFS to work properly! DO NOT REMOVE!
  networking.hostId = "8b2e179e";

  networking.hostName = "media-server";

  # Allows laptop to work with closed lid
  services.logind.lidSwitchExternalPower = "ignore";
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32768;
    }
  ];

  boot.loader.systemd-boot.enable = true;

  # Should never be changed!
  system.stateVersion = "24.11"; # Did you read the comment?
}
