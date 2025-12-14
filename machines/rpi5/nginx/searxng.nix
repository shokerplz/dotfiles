{...}: {
  # Virtual host for search.ikovalev.nl (SearXNG)
  services.nginx.virtualHosts."search.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = ["10.0.1.20"];
    extraConfig = ''
      access_log /var/log/nginx/search.ikovalev.nl-access.log;
      error_log /var/log/nginx/search.ikovalev.nl-error.log error;
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      proxy_set_header Host $host;
    '';
    locations."/" = {
      proxyPass = "http://media-server.home:8888";
      extraConfig = ''
        proxy_pass_request_headers on;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_buffering off;
      '';
    };
  };
}
