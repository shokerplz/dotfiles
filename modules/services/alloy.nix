{...}: {
  flake.nixosModules.serviceAlloy = {config, ...}: {
    services.alloy = {
      enable = true;
      extraFlags = ["--server.http.listen-addr=127.0.0.1:3031"];
    };

    environment.etc."alloy/config.alloy".text = ''
      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "journal" {
        forward_to    = [loki.write.default.receiver]
        relabel_rules = loki.relabel.journal.rules
        max_age       = "12h"
        labels        = {
          job  = "systemd-journal",
          host = "${config.networking.hostName}",
        }
      }

      loki.write "default" {
        endpoint {
          url = "http://media-server.home:3100/loki/api/v1/push"
        }
      }
    '';

    systemd.services.alloy.serviceConfig.SupplementaryGroups = ["adm"];
  };
}
