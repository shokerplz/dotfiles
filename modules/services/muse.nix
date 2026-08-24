{...}: {
  flake.nixosModules.serviceMuse = {...}: let
    museDir = "/mnt/zfs-pool0/music/muse";
  in {
    systemd.tmpfiles.rules = [
      "d ${museDir} 0755 root root -"
    ];

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 4535 -s 10.0.0.0/16 -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 4535 -s 10.0.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
