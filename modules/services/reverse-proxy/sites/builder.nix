{inputs, ...}: {
  flake.nixosModules.reverseProxySiteBuilder = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.builder;
  in {
    options.dotfiles.services.reverseProxy.sites.builder.enable = lib.mkEnableOption "builder reverse proxy sites";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."builder.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        root = inputs.nix-local-cache.packages.${pkgs.stdenv.hostPlatform.system}.frontend;
        locations."/".tryFiles = "$uri $uri/ /index.html";
        locations."= /config.js".alias = pkgs.writeText "config.js" ''
          window.SERVER_CONFIG = {
            apiUrl: "https://api.builder.ikovalev.nl"
          };
        '';
      };

      services.nginx.virtualHosts."api.builder.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        locations."/" = {
          proxyPass = "http://media-server.home:21080";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
}
