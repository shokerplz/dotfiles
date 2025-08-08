{
  config,
  pkgs,
  lib,
  ...
}: {
  # Virtual host for Home Assistant
  services.nginx.virtualHosts."home.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = ["10.0.1.20"];
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_redirect http:// https://;
      proxy_set_header    Upgrade     $http_upgrade;
      proxy_set_header    Connection  "upgrade";
    '';
    locations."/" = {
      proxyPass = "http://homeassistant.home:8123";
      proxyWebsockets = true;
    };
  };
}
