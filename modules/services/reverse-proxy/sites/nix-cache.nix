{...}: {
  flake.nixosModules.reverseProxySiteNixCache = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.nixCache;
  in {
    options.dotfiles.services.reverseProxy.sites.nixCache.enable = lib.mkEnableOption "nix-cache reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
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
    };
  };
}
