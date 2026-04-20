{...}: {
  flake.nixosModules.commonNFSClient = {
    fileSystems."/mnt/nfs" = {
      device = "media-server:/mnt/ssd/nfs";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };
}
