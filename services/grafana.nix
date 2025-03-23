{
  config,
  pkgs,
  ...
}:

{

  # Grafana service #UNTESTED
  services.grafana = {
    enable = true;
    dataDir = "/var/data/grafana";
    provision = {
      enable = true;
      datasources = {
        settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://rpi5.home:9090";
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://media-server.home:3100";
            }
          ];
        };
      };
    };
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "mon.ikovalev.nl";
        enforce_domain = true;
      };
    };
  };

  # Fix permissions if directory already exists
  systemd.services.grafana.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils-full.outPath}/bin/chown -R grafana:grafana ${config.services.grafana.dataDir}"
  ];

  # Grafana firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 3000 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 3000 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
