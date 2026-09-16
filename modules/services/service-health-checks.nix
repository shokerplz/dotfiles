{ ... }: {
  flake.nixosModules.serviceHealthChecks =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      arrNames = builtins.filter (name: config.services.${name}.enable) [
        "sonarr"
        "radarr"
        "prowlarr"
      ];
      keyNames = builtins.filter (name: builtins.hasAttr "${name}ApiKey" config.sops.secrets) arrNames;
      credentials =
        (map (name: "${name}-config:${config.services.${name}.dataDir}/config.xml") arrNames)
        ++ (map (name: "${name}-key:${config.sops.secrets."${name}ApiKey".path}") keyNames);
      settings = pkgs.writeText "service-health-checks.json" (
        builtins.toJSON {
          arr = map (name: {
            service = name;
            apiKeyCredential = if builtins.elem name keyNames then "${name}-key" else null;
          }) arrNames;
          gitlab = if config.services.gitlab.enable then "http://127.0.0.1:10080" else null;
        }
      );
      outputDirectory = "/var/lib/prometheus-node-exporter/textfile";
    in
    {
      systemd.tmpfiles.rules = [
        "d ${outputDirectory} 0755 service-health-checks service-health-checks -"
      ];
      services.prometheus.exporters.node.extraFlags = [
        "--collector.textfile.directory=${outputDirectory}"
      ];

      users.groups.service-health-checks = { };
      users.users.service-health-checks = {
        isSystemUser = true;
        group = "service-health-checks";
      };

      systemd.services.service-health-checks = {
        description = "Poll local application health and test configured download clients";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "service-health-checks";
          Group = "service-health-checks";
          ExecStart = "${pkgs.python3}/bin/python3 ${./monitoring/health_checks.py} ${settings} ${outputDirectory}/service-health.prom";
          LoadCredential = credentials;
          # Empty defaults let Python emit explicit failures when source files vanish.
          SetCredential = map (credential: "${builtins.head (lib.splitString ":" credential)}:") credentials;
          TimeoutStartSec = "85s";
          TimeoutStopSec = "3s";
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          ReadWritePaths = [ outputDirectory ];
          CapabilityBoundingSet = "";
          UMask = "0077";
        };
      };
      systemd.timers.service-health-checks = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2m";
          OnUnitInactiveSec = "5m";
          RandomizedDelaySec = "15s";
        };
      };
    };
}
