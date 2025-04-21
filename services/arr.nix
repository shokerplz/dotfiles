{ config, pkgs, inputs, ... }:

let
  arrBaseDir = "/mnt/zfs-pool0/kino";
  arrServices = ["bazarr" "prowlarr" "sonarr" "radarr"];
in

{
  imports = [
    ../modules/qbittorrent.nix
  ];

  system.activationScripts.createArrDirs =
    ''
      mkdir -p /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
      chgrp -R arr /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
      chgrp -R arr /mnt/zfs-pool0/kino/data
      chgrp -R arr /mnt/ssd/kino/nzbget/completed/
      find /mnt/zfs-pool0/kino/data -type d -exec chmod g+wx {} +
      find /mnt/ssd/kino/nzbget/completed -type d -exec chmod g+wx {} +
      find /mnt/ssd/kino/nzbget/ -type d -exec chmod 755 {} +
      chown -R nzbget:arr /mnt/ssd/kino/nzbget;
      chown sonarr /mnt/zfs-pool0/kino/sonarr/config
      chown radarr /mnt/zfs-pool0/kino/radarr/config
    '';

  # Create arr group
  users.groups.arr = {};

  # Arr services
  services.radarr  = { enable = true; group = "arr"; dataDir = "${arrBaseDir}/radarr/config"; };
  services.sonarr  = { enable = true; group = "arr"; dataDir = "${arrBaseDir}/sonarr/config"; };
  services.prowlarr= { enable = true; };
  services.bazarr = { enable = true; group = "arr"; };
  services.jellyseerr = { enable = true; };

  # Download clients
  services.nzbget = { enable = true; group = "arr"; };
  services.qbittorrent = { enable = true; group = "arr"; port = 5080; };


  # Arr stack firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
