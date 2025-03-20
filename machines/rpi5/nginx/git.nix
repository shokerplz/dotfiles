{config, pkgs, ...}:

{
  # Virtual host for Gitlab
  services.nginx.virtualHosts."git.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = [ "10.0.1.98" ];
    extraConfig = ''
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      proxy_set_header Host $host;
      client_max_body_size 0;
    '';
    locations."/" = {
      proxyPass = "http://media-server.home:10080";
    };
  };

  # Virtual host for Gitlab Registry
  services.nginx.virtualHosts."registry.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    acmeRoot = null;
    listenAddresses = [ "10.0.1.98" ];
    extraConfig = ''
      proxy_headers_hash_max_size 4096;
      proxy_headers_hash_bucket_size  128;
      proxy_set_header Host $host;
      client_max_body_size 0;
    '';
    locations."/" = {
      proxyPass = "https://media-server.home:10443";
    };
  };

  # Stream config for Gitlab SSH
  services.nginx.streamConfig = ''
    server {
      listen        10.0.1.98:22;
      proxy_timeout 600s;
      proxy_pass    media-server.home:10022;
    }
  '';
}