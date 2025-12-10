{ config, pkgs, ... }:

{
  services.nfs.server.enable = true;
  # Restrict exports to the local network
  services.nfs.server.exports = ''
    /mnt/ssd/nfs 10.0.0.0/16(rw,sync,no_subtree_check)
  '';

  # NFS firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 2049 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 2049 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
