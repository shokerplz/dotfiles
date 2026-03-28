{
  config,
  nixpkgs-unstable,
  ...
}: let
  domain = "hst.ikovalev.nl";
  configFile = config.sops.templates."hysteria_config.yaml".path;
in {
  imports = [
    ../secrets/hysteria.nix
  ];

  users.users.hysteria = {
    isSystemUser = true;
    group = "hysteria";
    home = "/var/lib/hysteria";
    createHome = true;
  };

  users.groups.hysteria = {};

  security.acme.certs.${domain} = {
    group = "hysteria";
    reloadServices = ["hysteria.service"];
  };

  systemd.services.hysteria = {
    description = "Hysteria 2 server";
    wantedBy = ["multi-user.target"];
    wants = [
      "network-online.target"
      "acme-${domain}.service"
    ];
    after = [
      "network-online.target"
      "acme-${domain}.service"
    ];

    serviceConfig = {
      User = "hysteria";
      Group = "hysteria";
      ExecStart = "${nixpkgs-unstable.hysteria}/bin/hysteria server -c ${configFile}";
      Restart = "on-failure";
      RestartSec = "5s";
      StateDirectory = "hysteria";
      WorkingDirectory = "/var/lib/hysteria";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  networking.firewall.interfaces.end0.allowedUDPPortRanges = [
    {
      from = 30000;
      to = 50000;
    }
  ];

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i end0 -p udp --dport 30000:50000 -j DNAT --to-destination :30003
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -i end0 -p udp --dport 30000:50000 -j DNAT --to-destination :30003 || true
  '';
}
