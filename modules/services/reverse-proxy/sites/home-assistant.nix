{...}: {
  flake.nixosModules.reverseProxySiteHomeAssistant = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.homeAssistant;
  in {
    options.dotfiles.services.reverseProxy.sites.homeAssistant.enable = lib.mkEnableOption "Home Assistant reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."home.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/home.ikovalev.nl-access.log;
          error_log /var/log/nginx/home.ikovalev.nl-error.log error;
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
    };
  };
}
