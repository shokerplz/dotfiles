{
  config,
  pkgs,
  ...
}:

{

  services.loki = {
    enable = true;
    dataDir = "/mnt/zfs-pool0/loki";
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
      };

      common = {
        instance_addr = "0.0.0.0";
        path_prefix = "/mnt/zfs-pool0/loki";
        replication_factor = 1;
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
        storage = {
          filesystem = {
            chunks_directory = "/mnt/zfs-pool0/loki/chunks";
            rules_directory = "/mnt/zfs-pool0/loki/rules";
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
    };
  };

  # Fix permissions if directory already exists
  systemd.services.loki.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils-full.outPath}/bin/mkdir -p ${config.services.loki.dataDir}"
    "+${pkgs.coreutils-full.outPath}/bin/chown -R loki:loki ${config.services.loki.dataDir}"
  ];

  # Loki firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 3100 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 3100 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
