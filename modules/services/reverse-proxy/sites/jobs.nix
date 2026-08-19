{...}: {
  flake.nixosModules.reverseProxySiteJobs = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
    siteCfg = cfg.sites.jobs;
  in {
    options.dotfiles.services.reverseProxy.sites.jobs.enable = lib.mkEnableOption "jobhunt reverse proxy site";

    config = lib.mkIf (cfg.enable && siteCfg.enable) {
      services.nginx.virtualHosts."jobs.ikovalev.nl" = {
        enableACME = true;
        forceSSL = true;
        acmeRoot = null;
        listenAddresses = ["10.0.1.20"];
        extraConfig = ''
          access_log /var/log/nginx/jobs.ikovalev.nl-access.log;
          error_log /var/log/nginx/jobs.ikovalev.nl-error.log error;
          allow 10.0.0.0/16;
          deny all;
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
        locations."/".proxyPass = "http://media-server.home:8765";
      };
    };
  };
}
