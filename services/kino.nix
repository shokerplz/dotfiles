{ config, pkgs, ... }:

let
  versions = import ./versions.nix;
in
{

  # Create all necessary directories for Jellyfin and arr stack. Create docker network
  system.activationScripts.createDirAndNetwork =
    let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
    in
    ''
      mkdir -p /mnt/zfs-pool0/kino/data/movies
      mkdir -p /mnt/zfs-pool0/kino/data/shows
      mkdir -p /mnt/zfs-pool0/kino/data/books
      mkdir -p /mnt/ssd/kino/nzbget/intermediate
      mkdir -p /mnt/ssd/kino/nzbget/completed/movies
      mkdir -p /mnt/ssd/kino/nzbget/completed/shows
      mkdir -p /mnt/ssd/kino/nzbget/completed/books
      mkdir -p /mnt/ssd/kino/nzbget/queue
      mkdir -p /mnt/ssd/kino/nzbget/tmp
      mkdir -p /mnt/ssd/kino/nzbget/nzb
      mkdir -p /mnt/zfs-pool0/kino/qbittorrent/config
      mkdir -p /mnt/zfs-pool0/kino/nzbget/config
      mkdir -p /mnt/zfs-pool0/kino/jellyseerr/config
      #chown -R 1000:1000 /mnt/zfs-pool0/kino/
      #chown -R 1000:1000 /mnt/ssd/kino/

      ${dockerBin} network inspect kino >/dev/null 2>&1 || ${dockerBin} network create kino
    '';

  # Jellyfin and arr stack services
  #virtualisation.oci-containers = {
  #  containers = {
  #    jellyseerr = {
  #      image = "docker.io/fallenbagel/jellyseerr:${versions.jellyseerr}";
  #      hostname = "jellyseerr";
  #      extraOptions = [ "--network=kino" ];
  #      environment = {
  #        TZ = "UTC";
  #      };
  #      user = "1000:1000";
  #      ports = [ "5055:5055" ];
  #      volumes = [
  #        "/mnt/zfs-pool0/kino/jellyseerr/config:/app/config"
  #        "/mnt/zfs-pool0/kino/data:/data/downloads"
  #      ];
  #    };
  #  };
  #};


}
