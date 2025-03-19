{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Virtual host for monitoring (Grafana + Prometheus + Loki)
  services.nginx.virtualHosts."mon.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = [ "10.0.1.20" ];
    extraConfig = ''
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      proxy_set_header Host $host;
    '';
    locations."/" = {
      proxyPass = "http://localhost:3000";
    };
    locations."/api/live/" = {
      proxyPass = "http://localhost:3000";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}
