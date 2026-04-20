{...}: {
  flake.nixosModules.reverseProxySiteFiles = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.files;
  in {
    options.dotfiles.services.reverseProxy.sites.files.enable = lib.mkEnableOption "Nextcloud reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."files.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/files.ikovalev.nl-access.log;
          error_log /var/log/nginx/files.ikovalev.nl-error.log error;
          proxy_headers_hash_max_size 4096;
          proxy_headers_hash_bucket_size  128;
          proxy_set_header Host $host;
          client_max_body_size 0;
        '';
        locations."/".proxyPass = "https://media-server.home:20443";
      };
    };
  };
}
