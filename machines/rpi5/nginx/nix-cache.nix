{
  config,
  pkgs,
  lib,
  ...
}: {
  services.nginx.virtualHosts."nix-cache.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = ["10.0.1.20"];
    locations."/" = {
      proxyPass = "http://media-server.home:20080";
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
