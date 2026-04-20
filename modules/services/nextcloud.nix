{...}: let
  nextcloudVersion = "31.0.2";
in {
  flake.nixosModules.serviceNextcloud = {
    virtualisation.oci-containers.containers = {
      nextcloud = {
        image = "lscr.io/linuxserver/nextcloud:${nextcloudVersion}";
        hostname = "nextcloud";
        environment = {
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [
          "/mnt/zfs-pool0/nextcloud/data:/data"
          "/mnt/zfs-pool0/nextcloud/config:/config"
        ];
        ports = ["20443:443/tcp"];
      };

      # Nextcloud recommends a dedicated Collabora service for Office.
      nextcloud-office = {
        image = "collabora/code";
        environment = {
          aliasgroup1 = "https://files.ikovalev.nl:443";
        };
        ports = ["29980:9980/tcp"];
        extraOptions = ["--cap-add=MKNOD"];
      };
    };

    system.activationScripts.createDirNextCloud = ''
      mkdir -p /mnt/zfs-pool0/nextcloud/data
      mkdir -p /mnt/zfs-pool0/nextcloud/config
      chown -R 1000:1000 /mnt/zfs-pool0/nextcloud/
    '';

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 20443 -s 10.0.0.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 29980 -s 10.0.0.0/16 -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 20443 -s 10.0.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 29980 -s 10.0.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
