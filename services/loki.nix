{
  config,
  pkgs,
  lib,
  ...
}:

let
  versions = import ./versions.nix;
in

{
  # Loki config
  environment.etc."loki/config.yaml".text = lib.generators.toYAML { } {
    auth_enabled = false;
    server = {
      http_listen_port = 3100;
      grpc_listen_port = 9096;
    };

    common = {
      instance_addr = "0.0.0.0";
      path_prefix = "/var/data/loki";
      replication_factor = 1;
      ring = {
        kvstore = {
          store = "inmemory";
        };
      };
      storage = {
        filesystem = {
          chunks_directory = "/var/data/loki/chunks";
          rules_directory = "/var/data/loki/rules";
        };
      };
    };

    limits_config = {
      volume_enabled = true;
    };

    pattern_ingester = {
      enabled = true;
    };

    schema_config = {
      configs = [
        {
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
    };

    ruler = {
      alertmanager_url = "http://localhost:9093";
    };
  };

  # Create directory for loki
  system.activationScripts.createDirLoki = ''
    mkdir -p /mnt/zfs-pool0/loki
    chown -R 1000:1000 /mnt/zfs-pool0/loki/
  '';

  # Loki service
  virtualisation.oci-containers = {
    containers = {
      loki = {
        image = "grafana/loki:${versions.loki}";
        hostname = "loki";
        extraOptions = [
          "--ulimit=memlock=-1:-1"
          "--ulimit=nofile=65536:65536"
        ];
        cmd = [ "-config.file=/etc/loki/config.yaml" ];
        user = "1000:1000";
        volumes = [
          "/etc/loki/config.yaml:/etc/loki/config.yaml"
          "/mnt/zfs-pool0/loki:/var/data/loki"
        ];
        ports = [ "3100:3100/tcp" ];
      };
    };
  };

  # Loki firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 3100 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 3100 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
