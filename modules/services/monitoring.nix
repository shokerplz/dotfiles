{ ... }: {
  flake.nixosModules.serviceMonitoring =
    {
      config,
      ...
    }:
    let
      targets = builtins.fromJSON (builtins.readFile ./monitoring/targets.json);
    in
    {
      sops.secrets.alertmanager_telegram_bot_token = {
        sopsFile = ../../secrets/monitoring.yaml;
      };

      services.prometheus = {
        ruleFiles = [ ./monitoring/rules.yaml ];
        alertmanagers = [ { static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ]; } ];
        alertmanager = {
          enable = true;
          listenAddress = "127.0.0.1";
          extraFlags = [ "--cluster.listen-address=" ];
          configText = builtins.readFile ./monitoring/alertmanager.yaml;
        };
        exporters.blackbox = {
          enable = true;
          listenAddress = "127.0.0.1";
          configFile = ./monitoring/blackbox.yaml;
        };
        scrapeConfigs = [
          {
            job_name = "blackbox";
            scrape_interval = "30s";
            scrape_timeout = "10s";
            metrics_path = "/probe";
            static_configs = map (target: {
              targets = [ target.target ];
              labels =
                (builtins.removeAttrs target [
                  "target"
                  "module"
                ])
                // {
                  __param_module = target.module;
                  collector = "blackbox";
                };
            }) targets;
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "127.0.0.1:9115";
              }
            ];
          }
          {
            job_name = "blackbox-exporter";
            static_configs = [
              {
                targets = [ "127.0.0.1:9115" ];
                labels.host = "rpi5";
              }
            ];
          }
          {
            job_name = "alertmanager";
            static_configs = [
              {
                targets = [ "127.0.0.1:9093" ];
                labels.host = "rpi5";
              }
            ];
          }
        ];
      };

      systemd.services.alertmanager.serviceConfig.LoadCredential = [
        "telegram-token:${config.sops.secrets.alertmanager_telegram_bot_token.path}"
      ];

      # NixOS concatenates this list into one YAML file, so emit one document.
      services.prometheus.rules = [
        (builtins.toJSON {
          groups = [
            {
              name = "gitlab-components";
              rules =
                map
                  (unit: {
                    alert = "GitLabComponentUnavailable";
                    expr = ''(node_systemd_unit_state{job="node",host="media-server",name="${unit}.service",state="active"} == 0 or absent(node_systemd_unit_state{job="node",host="media-server",name="${unit}.service",state="active"})) and on(host) (up{job="node",host="media-server"} == 1)'';
                    "for" = "5m";
                    labels = {
                      severity = "warning";
                      scope = "component";
                      host = "media-server";
                      service = "gitlab";
                      component = unit;
                    };
                    annotations = {
                      summary = "GitLab component ${unit} is unavailable";
                      description = "The expected systemd unit is inactive or missing while host metrics are available. Inspect the GitLab dashboard and logs.";
                    };
                  })
                  [
                    "gitlab"
                    "gitaly"
                    "redis-gitlab"
                    "gitlab-postgresql"
                    "gitlab-sidekiq"
                    "gitlab-workhorse"
                    "gitlab-sshd"
                    "gitlab-runner"
                  ];
            }
          ];
        })
      ];
    };
}
