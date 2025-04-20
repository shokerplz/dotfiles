{ config, pkgs, ... }:

let
  arrBaseDir = "/mnt/zfs-pool0/kino";
  arrServices = ["radarr" "sonarr" "prowlarr" "bazarr"];
  mkArrService = name: {
    enable = true;
    group = "arr";
    dataDir = "${arrBaseDir}/${name}/config"
  }
in

{

  system.activationScripts.createJellyfinDir =
    ''
      mkdir -p /mnt/zfs-pool0/kino/{${builtinst.concatStringsSep "," arrServices}}/config
      chown -R arr /mnt/zfs-pool0/kino/{${builtinst.concatStringsSep "," arrServices}}/config
    '';

  # Create arr group
  users.groups.arr = {};

  # Create Arr services
  services = builtins.listToAttrs (map
    (name: { inherit name; value = mkArrService name; })
    arrServices);

  # Arr stack firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
