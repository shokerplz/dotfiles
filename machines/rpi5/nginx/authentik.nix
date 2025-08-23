{
  config,
  pkgs,
  lib,
  ...
}: {
  services.nginx.upstreams = {
    authentik = {
      extraConfig = ''
        keepalive 10;
      '';
      servers = {
        "127.0.0.1:9000" = {};
      };
    };
  };

  # Virtual host for Home Assistant
  services.nginx.virtualHosts."auth.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = ["10.0.1.20"];
    extraConfig = ''
      proxy_http_version 1.1;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      add_header Strict-Transport-Security "max-age=63072000" always;
    '';
    locations."/" = {
      proxyPass = "http://authentik";
      proxyWebsockets = true;
    };
  };
}
