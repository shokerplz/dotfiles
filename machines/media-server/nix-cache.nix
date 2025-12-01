{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."cache" = {
      listen = [ { addr = "0.0.0.0"; port = 20080; } ];
      root = "/mnt/zfs-pool0/nix-cache/cache";
      extraConfig = ''
        autoindex on;
      '';
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 20080 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 20080 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
