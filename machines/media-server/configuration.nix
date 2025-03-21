{
  ...
}:

{

  imports = [
    ./packages.nix
    ../../hardware-configuration.nix
    ../../services/promtail.nix
    ../../services/node-exporter.nix
    ../../services/kino.nix
    ../../services/loki.nix
    ../../services/nextcloud.nix
    ../../services/gitlab.nix
  ];

  # Mount ZFS data pool on boot
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "pool0" ];

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

  boot.loader.systemd-boot.enable = true;

  # Should never be changed!
  system.stateVersion = "24.11"; # Did you read the comment?

}
