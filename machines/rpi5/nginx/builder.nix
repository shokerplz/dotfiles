{
  config,
  pkgs,
  nix-local-cache,
  ...
}: {
  services.nix-local-cache-frontend = {
    enable = true;
    domain = "builder.ikovalev.nl";
    apiUrl = "https://api.builder.ikovalev.nl";
  };

  # Enable ACME/SSL for the domain (since the module only sets up the virtualHost, 
  # we need to ensure global Nginx/ACME settings apply or configure them here if the module doesn't)
  # The module sets `virtualHosts.${domain}`, so we can extend it here.
  services.nginx.virtualHosts."builder.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    listenAddresses = ["10.0.1.20"];
  };

  services.nginx.virtualHosts."api.builder.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    listenAddresses = ["10.0.1.20"];
    locations."/" = {
      proxyPass = "http://media-server.home:21080";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
