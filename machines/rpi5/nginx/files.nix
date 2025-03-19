{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Virtual host for nextcloud
  services.nginx.virtualHosts."files.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = [ "10.0.1.20" ];
    extraConfig = ''
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      proxy_set_header Host $host;
      client_max_body_size 0;
    '';
    locations."/" = {
      proxyPass = "https://media-server.home:20443";
    };
  };
}
