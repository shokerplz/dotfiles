{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Virtual host for Kino (Jellyfin + arr stack)
  services.nginx.virtualHosts."kino.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = [ "10.0.1.20" ];
    extraConfig = ''
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      location / {
        root /var/www/websites/kino.ikovalev.nl;
        index index.html;
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
    locations."/jellyseerr" = {
      proxyPass = "http://media-server.home:5055/$1$is_args$args";
      extraConfig = ''
        set $app 'jellyseerr';
        rewrite ^/jellyseerr/?(.*)$ /$1 break;
        proxy_redirect ^ /$app;
        proxy_redirect /setup /$app/setup;
        proxy_redirect /login /$app/login;
        proxy_set_header Accept-Encoding "";
        sub_filter_once off;
        sub_filter_types *;
        sub_filter '</head>' '<script language="javascript">(()=>{var t="$app";let e=history.pushState;history.pushState=function a(){arguments[2]&&!arguments[2].startsWith("/"+t)&&(arguments[2]="/"+t+arguments[2]);let s=e.apply(this,arguments);return window.dispatchEvent(new Event("pushstate")),s};let a=history.replaceState;history.replaceState=function e(){arguments[2]&&!arguments[2].startsWith("/"+t)&&(arguments[2]="/"+t+arguments[2]);let s=a.apply(this,arguments);return window.dispatchEvent(new Event("replacestate")),s},window.addEventListener("popstate",()=>{console.log("popstate")})})();</script></head>';
        sub_filter 'href="/"' 'href="/$app"';
        sub_filter 'href="/login"' 'href="/$app/login"';
        sub_filter 'href:"/"' 'href:"/$app"';
        sub_filter '\/_next' '\/$app\/_next';
        sub_filter '/_next' '/$app/_next';
        sub_filter '/api/v1' '/$app/api/v1';
        sub_filter '/login/plex/loading' '/$app/login/plex/loading';
        sub_filter '/images/' '/$app/images/';
        sub_filter '/android-' '/$app/android-';
        sub_filter '/apple-' '/$app/apple-';
        sub_filter '/favicon' '/$app/favicon';
        sub_filter '/logo_' '/$app/logo_';
        sub_filter '/site.webmanifest' '/$app/site.webmanifest';
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
      '';
    };
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
}
