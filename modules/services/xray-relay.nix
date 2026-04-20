{
  ...
}: {
  flake.nixosModules.serviceXrayRelay = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.xrayRelay;
  in {
    options.dotfiles.services.xrayRelay = {
      enable = lib.mkEnableOption "Xray two-hop relay node";

      role = lib.mkOption {
        type = with lib.types; nullOr (enum [
          "entry"
          "exit"
        ]);
        default = null;
        example = "entry";
        description = "Whether this machine is the relay entry or exit node.";
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.role != null;
          message = "dotfiles.services.xrayRelay.role must be set when the relay module is enabled.";
        }
      ];

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.haproxy = {
        enable = true;
        config = ''
          log stdout format raw local0
          maxconn 4096

          defaults
              log global
              mode tcp
              option dontlognull
              timeout connect 5s
              timeout client  300s
              timeout server  300s

          frontend tls_in
              bind *:443
              tcp-request inspect-delay 5s
              tcp-request content accept if { req.ssl_hello_type 1 }
              use_backend xray_reality if { req.ssl_sni -i ok.ru }
              default_backend okru_tls

          frontend http_in
              mode http
              bind *:80
              http-request redirect code 301 location https://ok.ru/

          backend xray_reality
              server xray 127.0.0.1:7443 send-proxy-v2

          backend okru_tls
              server okru ok.ru:443
        '';
      };

      services.xray = {
        enable = true;
        settingsFile =
          if cfg.role == "entry"
          then config.sops.templates.xray-role-entry-config.path
          else if cfg.role == "exit"
          then config.sops.templates.xray-role-exit-config.path
          else throw "Unsupported xray relay role: ${toString cfg.role}";
      };
    };
  };
}
