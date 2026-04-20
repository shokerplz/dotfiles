{...}: {
  flake.nixosModules.serviceSpeedtestExporter = {
    config,
    pkgs,
    ...
  }: let
    speedtestExporter = pkgs.callPackage ../../packages/speedtest-exporter.nix {};
  in {
    users.users.speedtest-exporter = {
      description = "Speedtest Exporter service user";
      isSystemUser = true;
      group = "speedtest-exporter";
    };
    users.groups.speedtest-exporter = {};

    systemd.services.speedtest-exporter = {
      description = "Speedtest Exporter";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = "speedtest-exporter";
        Group = "speedtest-exporter";
        Restart = "on-failure";
        RestartSec = "20s";
        Environment = [
          "SPEEDTEST_PORT=9798"
          "SPEEDTEST_CACHE_FOR=3600"
          "SPEEDTEST_TIMEOUT=90"
        ];
        ExecStart = "${speedtestExporter}/bin/speedtest-exporter";
        PrivateNetwork = false;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        NoNewPrivileges = true;
      };
    };
  };
}
