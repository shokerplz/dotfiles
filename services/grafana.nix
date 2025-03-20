{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Create necessary directories
  system.activationScripts.createGrafanaDirectory = ''
    mkdir -p /var/data/grafana
    chown 1000:1000 /var/data/grafana
  '';

  # Grafana service
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      grafana = {
        image = "grafana/grafana-oss";
        volumes = [ "/var/data/grafana:/var/lib/grafana" ];
        extraOptions = [ "--network=monitoring" ];
        user = "1000:1000";
        ports = [ "3000:3000/tcp" ];
      };
    };
  };

  # Grafana firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 3000 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 3000 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
