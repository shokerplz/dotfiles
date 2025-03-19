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
}
