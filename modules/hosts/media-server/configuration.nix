{self, ...}: {
  flake.nixosModules.mediaServerConfiguration = {
    pkgs-current,
    pkgs-unstable,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.commonSSH
      self.nixosModules.locationHome
      self.nixosModules.serviceNixLocalCache
      self.nixosModules.serviceNodeExporter
      self.nixosModules.serviceAlloy
      self.nixosModules.serviceLoki
      self.nixosModules.serviceJellyfin
      self.nixosModules.serviceArr
      self.nixosModules.serviceSamba
      self.nixosModules.serviceNFS
      self.nixosModules.serviceNextcloud
      self.nixosModules.serviceGitlab
      self.nixosModules.serviceGitlabRunner
      self.nixosModules.serviceN8N
      self.nixosModules.serviceSearxNG
      ./_hardware-configuration.nix
      ./_packages.nix
    ];

    nixpkgs.pkgs = pkgs-current;

    hardware.graphics.enable = true;

    boot = {
      supportedFilesystems = ["zfs"];
      zfs.forceImportRoot = false;
      zfs.extraPools = ["pool0"];
      binfmt.emulatedSystems = ["aarch64-linux"];
      loader.systemd-boot.enable = true;
    };

    nix.settings.extra-platforms = ["aarch64-linux"];

    # ZFS requires a stable host ID for pool import.
    networking.hostId = "8b2e179e";
    networking.hostName = "media-server";

    # Keep the machine awake when used closed-lid as a server.
    services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
    systemd.sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 32768;
      }
    ];

    # Pin postgresql version explicitly. By default it depends on system.stateVersion
    services.postgresql.package = pkgs-current.postgresql_17;

    system.stateVersion = "24.11";
  };
}
