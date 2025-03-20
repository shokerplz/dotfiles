{ config, ... }:

{

  # CF DDNS service
  virtualisation.oci-containers = {
    containers = {
      cloudflare-ddns = {
        image = "favonia/cloudflare-ddns:1.15.1";
        autoStart = true;
        user = "1000:1000";
        environment = {
          DOMAINS = "vpn.ikovalev.nl";
          PROXIED = "false";
          CLOUDFLARE_API_TOKEN_FILE = "/etc/secrets/cf_api_token";
        };
        extraOptions = [ "--network=host" ];
        volumes = [
          "${config.sops.secrets.cloudflare_api_token.path}:/etc/secrets/cf_api_token"
        ];
      };
    };
  };
}
