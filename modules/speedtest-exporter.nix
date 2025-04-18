{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.speedtest-exporter;
in
{
  ###### Interface
  options.services.speedtest-exporter = {
    enable = mkEnableOption (mdDoc "Prometheus Speedtest Exporter service");

    package = mkOption {
      type = types.package;
      default = pkgs.speedtest-exporter;
      defaultText = literalExpression "pkgs.speedtest-exporter";
      description = mdDoc "The speedtest-exporter package to use.";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc "IP address for the exporter to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 9798;
      description = mdDoc "Port for the exporter to listen on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Whether to open the firewall for the exporter's port.";
    };

    cacheSeconds = mkOption {
      type = types.int;
      default = 3600; # Default to 1 hour cache in module, 0 is default in app
      description = mdDoc ''
        Cache the speedtest results for this many seconds.
        A value of 0 disables caching (runs speedtest on every scrape).
        Defaults to 3600 (1 hour) in this module for reasonable usage.
      '';
    };

    serverID = mkOption {
      type = types.nullOr types.str; # Should be string containing integer ID
      default = null;
      description = mdDoc ''
        Specify a specific Speedtest server ID to use.
        If null (default), the exporter lets the speedtest CLI choose the best server.
      '';
      example = "12345";
    };

    timeout = mkOption {
      type = types.int;
      default = 90;
      description = mdDoc "Timeout in seconds for the underlying speedtest CLI execution.";
    };

    user = mkOption {
      type = types.str;
      default = "speedtest-exporter";
      description = mdDoc "User account under which the service runs.";
    };

    group = mkOption {
      type = types.str;
      default = "speedtest-exporter";
      description = mdDoc "Group under which the service runs.";
    };

    acceptOoklaTerms = mkOption {
      type = types.bool;
      default = false; # Force user acknowledgment
      description = mdDoc ''
        Acknowledge and accept the Ookla Speedtest CLI terms and conditions,
        license agreement (EULA: https://www.speedtest.net/about/eula), and
        privacy policy (https://www.speedtest.net/about/privacy).
        The exporter requires the flags --accept-license and --accept-gdpr to be passed
        to the underlying speedtest binary (which the Python script does).
        You MUST set this option to true to enable the service.
      '';
    };
  };

  ###### Implementation
  config = mkIf cfg.enable {

    # --- Assertions ---
    assertions = [
      {
        # User MUST accept the terms
        assertion = cfg.acceptOoklaTerms;
        message = "You must accept the Ookla Speedtest terms by setting services.speedtest-exporter.acceptOoklaTerms = true in your configuration.";
      }
      {
        # Check serverID format if set (basic check)
        assertion = cfg.serverID == null || builtins.match "[0-9]+" cfg.serverID != null;
        message = "services.speedtest-exporter.serverID must be a string containing only digits, if set.";
      }
    ];

    # --- User and Group ---
    users.users.${cfg.user} = {
      description = "Speedtest Exporter service user";
      isSystemUser = true;
      group = cfg.group;
      # No home directory needed unless the app writes files unexpectedly
    };
    users.groups.${cfg.group} = { };

    # --- Systemd Service ---
    systemd.services.speedtest-exporter = {
      description = "Speedtest Exporter";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "20s";

        # Environment variables read by exporter.py
        Environment = [
          "SPEEDTEST_PORT=${toString cfg.port}"
          "SPEEDTEST_CACHE_FOR=${toString cfg.cacheSeconds}"
          "SPEEDTEST_TIMEOUT=${toString cfg.timeout}"
        ] ++ lib.optional (cfg.serverID != null) "SPEEDTEST_SERVER=${cfg.serverID}";

        # Waitress in exporter.py binds to 0.0.0.0:${SPEEDTEST_PORT}
        ExecStart = "${cfg.package}/bin/speedtest-exporter";

        # Security Hardening
        # Needs network access to run speedtest and serve metrics!
        PrivateNetwork = false;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        NoNewPrivileges = true;
        # RestrictAddressFamilies might be too strict if speedtest needs both
      };
    };

    # --- Firewall ---
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };

}
