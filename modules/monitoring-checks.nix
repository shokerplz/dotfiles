{...}: {
  perSystem = {pkgs-current, ...}: let
    monitoring = (import ./services/monitoring.nix {}).flake.nixosModules.serviceMonitoring {
      config = {};
    };
    generatedRules = pkgs-current.writeText "gitlab.rules" (
      pkgs-current.lib.concatStringsSep "\n" monitoring.services.prometheus.rules
    );
  in {
    checks.monitoring =
      pkgs-current.runCommand "service-monitoring-checks"
      {
        MONITORING_GENERATED_RULES = generatedRules;
        nativeBuildInputs = with pkgs-current; [
          (python3.withPackages (ps: [ps.pyyaml]))
          prometheus.cli
          prometheus-alertmanager
          prometheus-blackbox-exporter
        ];
      }
      ''
        export PYTHONDONTWRITEBYTECODE=1
        mkdir -p work/modules/services
        cp -r ${./services/monitoring} work/modules/services/monitoring
        cp -r ${./services/grafana-dashboards} work/modules/services/grafana-dashboards
        chmod -R u+w work
        cd work
        promtool check rules modules/services/monitoring/rules.yaml
        promtool check rules "$MONITORING_GENERATED_RULES"
        amtool check-config modules/services/monitoring/alertmanager.yaml
        blackbox_exporter --config.file=modules/services/monitoring/blackbox.yaml --config.check
        touch "$out"
      '';
  };
}
