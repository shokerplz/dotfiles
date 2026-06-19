{...}: {
  flake.nixosModules.reverseProxySiteKino = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.kino;
  in {
    options.dotfiles.services.reverseProxy.sites.kino.enable = lib.mkEnableOption "Kino reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      system.activationScripts.createWebsites = ''
        mkdir -p /var/www/websites/kino.ikovalev.nl/assets
        find /var/www/websites/kino.ikovalev.nl -type d -exec chmod 0755 {} \;
        find /var/www/websites/kino.ikovalev.nl -type f -exec chmod 0644 {} \;
        chown -R nginx:nginx /var/www/websites
      '';

      services.nginx.virtualHosts."kino.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/kino.ikovalev.nl-access.log;
          error_log /var/log/nginx/kino.ikovalev.nl-error.log error;
          proxy_headers_hash_max_size 4096;
          proxy_headers_hash_bucket_size  128;
          location / {
            root /var/www/websites/kino.ikovalev.nl;
            index index.html;
            try_files $uri $uri/ @seerr_unprefixed;
          }

          location @seerr_unprefixed {
            rewrite ^/(.*)$ /seerr/$1 permanent;
          }
        '';
        locations."/jellyfin/" = {
          proxyPass = "http://media-server.home:8096/jellyfin/";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/sonarr" = {
          proxyPass = "http://media-server.home:8989";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/readarr" = {
          proxyPass = "http://media-server.home:8787";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/radarr" = {
          proxyPass = "http://media-server.home:7878";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/torrent/" = {
          proxyPass = "http://media-server.home:5080/";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_http_version 1.1;
            proxy_set_header   Host               $proxy_host;
            proxy_cookie_path  /                  "/; Secure";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/bazarr" = {
          proxyPass = "http://media-server.home:6767";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/prowlarr" = {
          proxyPass = "http://media-server.home:9696";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/seerr" = {
          proxyPass = "http://media-server.home:5055/$1$is_args$args";
          extraConfig = ''
            rewrite ^/seerr/?(.*)$ /$1 break;
            proxy_pass_request_headers on;
            proxy_redirect ~^(/(?!seerr/).*)$ /seerr$1;
            proxy_set_header Accept-Encoding "";
            sub_filter_once off;
            sub_filter_types *;
            sub_filter '\/_next' '\/seerr\/_next';
            sub_filter '/_next' '/seerr/_next';
            sub_filter '/api/v1' '/seerr/api/v1';
            sub_filter '/login/plex/loading' '/seerr/login/plex/loading';
            sub_filter '/images/' '/seerr/images/';
            sub_filter '/android-' '/seerr/android-';
            sub_filter '/apple-' '/seerr/apple-';
            sub_filter '/favicon' '/seerr/favicon';
            sub_filter '/logo_' '/seerr/logo_';
            sub_filter '/site.webmanifest' '/seerr/site.webmanifest';
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/seerr/api/" = {
          proxyPass = "http://media-server.home:5055/api/";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/jellyseerr".extraConfig = ''
          rewrite ^/jellyseerr/?(.*)$ /seerr/$1 permanent;
        '';
        locations."/sw.js" = {
          proxyPass = "http://media-server.home:5055/sw.js";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
        locations."/avatarproxy" = {
          proxyPass = "http://media-server.home:5055/avatarproxy";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
      };
    };
  };
}
