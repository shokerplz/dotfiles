{...}: {
  flake.nixosModules.reverseProxySiteGit = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.git;
  in {
    options.dotfiles.services.reverseProxy.sites.git.enable = lib.mkEnableOption "GitLab reverse proxy sites";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."git.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.98"];
        extraConfig = ''
          access_log /var/log/nginx/git.ikovalev.nl-access.log;
          error_log /var/log/nginx/git.ikovalev.nl-error.log error;
          proxy_headers_hash_max_size 4096;
          proxy_headers_hash_bucket_size  128;
          proxy_set_header Host $host;
          client_max_body_size 0;
        '';
        locations."/".proxyPass = "http://media-server.home:10080";
      };

      services.nginx.virtualHosts."registry.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.98"];
        extraConfig = ''
          access_log /var/log/nginx/registry.ikovalev.nl-access.log;
          error_log /var/log/nginx/registry.ikovalev.nl-error.log error;
          proxy_headers_hash_max_size 4096;
          proxy_headers_hash_bucket_size  128;
          proxy_set_header Host $host;
          client_max_body_size 0;
        '';
        locations."/".proxyPass = "https://media-server.home:10443";
      };

      services.nginx.streamConfig = lib.mkAfter ''
        server {
          listen        10.0.1.98:22;
          proxy_timeout 600s;
          proxy_pass    media-server.home:10022;
        }
      '';
    };
  };
}
