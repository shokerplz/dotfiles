{...}: {
  flake.nixosModules.reverseProxySiteN8N = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.n8n;
  in {
    options.dotfiles.services.reverseProxy.sites.n8n.enable = lib.mkEnableOption "n8n reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."n8n.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/n8n.ikovalev.nl-access.log;
          error_log /var/log/nginx/n8n.ikovalev.nl-error.log error;
          allow 10.0.0.0/16;
          deny all;
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
        '';
        locations."/" = {
          proxyPass = "http://media-server.home:5678";
          proxyWebsockets = true;
        };
      };
    };
  };
}
