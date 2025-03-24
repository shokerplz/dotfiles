{ ... }:

{

  # Prometheus service
  services.prometheus = {
    enable = true;
    port = 9090;
    stateDir = "prometheus";

    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      evaluation_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        honor_timestamps = true;
        scrape_interval = "15s";
        scrape_timeout = "10s";
        scrape_protocols = [
          "OpenMetricsText1.0.0"
          "OpenMetricsText0.0.1"
          "PrometheusText0.0.4"
        ];
        metrics_path = "/metrics";
        scheme = "http";
        static_configs = [ { targets = [ "localhost:9090" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "rpi5.home:9100"
              "media-server.home:9100"
              "gl-mt6000.home:9100"
            ];
          }
        ];
      }
      {
        job_name = "speedtest";
        scrape_interval = "1h";
        scrape_timeout = "1m";
        static_configs = [ { targets = [ "speedtest-exporter:9798" ]; } ];
      }
    ];
  };

  # Prometheus firewall
  networking.firewall.extraCommands = ''
    # Prometheus ports
    iptables -A nixos-fw -p tcp --dport 9090 -s 192.168.1.0/24 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 9090 -s 10.0.0.0/16 -j nixos-fw-accept

    iptables -A nixos-fw -p tcp --dport 9100 -s 172.16.0.0/12 -d 10.0.1.20 -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 9090 -s 192.168.1.0/24 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 9090 -s 10.0.0.0/16 -j nixos-fw-accept || true

    iptables -D nixos-fw -p tcp --dport 9100 -s 172.16.0.0/12 -d 10.0.1.20 -j nixos-fw-accept || true
  '';
}
