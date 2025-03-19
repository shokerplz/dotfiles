{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.daemon.settings = {
    log-driver = "local";
    log-opts = {
      max-size = "10m";
    };
  };

  # Allow docker containers to talk to each other
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true
    iptables -A nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true

  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true
    iptables -D nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true
  '';
}
