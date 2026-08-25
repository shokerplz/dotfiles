{...}: {
  flake.nixosModules.reverseProxySiteMusic = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.music;
  in {
    options.dotfiles.services.reverseProxy.sites.music.enable = lib.mkEnableOption "Music reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."music.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/music.ikovalev.nl-access.log;
          error_log /var/log/nginx/music.ikovalev.nl-error.log error;
          proxy_headers_hash_max_size 4096;
          proxy_headers_hash_bucket_size  128;
        '';
        locations."/" = {
          # muse: web player + Subsonic API (docker compose, ~/muse on media-server)
          proxyPass = "http://media-server.home:4535";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_read_timeout 300s;
            proxy_connect_timeout 300s;
            proxy_send_timeout 300s;
            proxy_buffering off;
          '';
        };
      };
    };
  };
}
