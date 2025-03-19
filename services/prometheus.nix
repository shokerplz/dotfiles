{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Create necessary directories
  system.activationScripts.createPrometheusDirectory = ''
    mkdir -p /var/data/prometheus
    chown 1000:1000 /var/data/prometheus
  '';

  # Prometheus config
  environment.etc."prometheus/config.yml".text = lib.generators.toYAML { } {
    global = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      scrape_protocols = [
        "OpenMetricsText1.0.0"
        "OpenMetricsText0.0.1"
        "PrometheusText0.0.4"
      ];
      evaluation_interval = "15s";
    };

    runtime = {
      gogc = 75;
    };

    alerting = {
      alertmanagers = [
        {
          follow_redirects = true;
          enable_http2 = true;
          scheme = "http";
          timeout = "10s";
          api_version = "v2";
          static_configs = [ { targets = [ ]; } ];
        }
      ];
    };

    scrape_configs = [
      {
        job_name = "prometheus";
        honor_timestamps = true;
        track_timestamps_staleness = false;
        scrape_interval = "15s";
        scrape_timeout = "10s";
        scrape_protocols = [
          "OpenMetricsText1.0.0"
          "OpenMetricsText0.0.1"
          "PrometheusText0.0.4"
        ];
        metrics_path = "/metrics";
        scheme = "http";
        enable_compression = true;
        follow_redirects = true;
        enable_http2 = true;
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

  # Prometheus service
  virtualisation.oci-containers = {
    containers = {
      prometheus-server = {
        image = "prom/prometheus:latest";
        autoStart = true;
        ports = [ "9090:9090/tcp" ];
        user = "1000:1000";
        extraOptions = [
          "--add-host=rpi5.home:10.0.1.20"
          "--network=monitoring"
        ];
        cmd = [
          "--storage.tsdb.retention.size=20GB"
          "--storage.tsdb.retention.time=1y"
          "--config.file=/etc/prometheus/prometheus.yml"
        ];
        volumes = [
          "/etc/prometheus/config.yml:/etc/prometheus/prometheus.yml"
          "/var/data/prometheus:/prometheus"
        ];
      };
    };
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
