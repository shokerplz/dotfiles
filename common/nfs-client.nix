{ config, pkgs, ... }:

{
  fileSystems."/mnt/nfs" = {
    device = "media-server:/mnt/ssd/nfs";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };
}
