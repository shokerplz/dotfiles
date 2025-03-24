{ ... }:

let
  versions = import ./versions.nix;
in
{

  # Create directories for nextcloud
  system.activationScripts.createDirNextCloud = ''
    mkdir -p /mnt/zfs-pool0/nextcloud/data
    mkdir -p /mnt/zfs-pool0/nextcloud/config
    chown -R 1000:1000 /mnt/zfs-pool0/nextcloud/
  '';

  # NextCloud service
  virtualisation.oci-containers = {
    containers = {
      nextcloud = {
        image = "lscr.io/linuxserver/nextcloud:${versions.nextcloud}";
        hostname = "nextcloud";
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [
          "/mnt/zfs-pool0/nextcloud/data:/data"
          "/mnt/zfs-pool0/nextcloud/config:/config"
        ];
        ports = [ "20443:443/tcp" ];
      };
    };
  };

  # NextCloud firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 20443 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 20443 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
