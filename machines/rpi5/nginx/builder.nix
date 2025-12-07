{
  config,
  pkgs,
  nix-local-cache,
  ...
}: {
  services.nginx.virtualHosts."builder.ikovalev.nl" = {
    enableACME = true;
    forceSSL = true;
    listenAddresses = ["10.0.1.20"];
    root = "${nix-local-cache.packages.${pkgs.system}.frontend}";
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };
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
