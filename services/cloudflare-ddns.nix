{ config, pkgs, ... }:

{
  # Cloudflare DDNS service to announce my public ip
  config.services.cloudflare-ddns = {
    enable = true;
    credentialsFile = config.sops.templates."cloudflare-ddns_api_token".path;
    domains = [ "vpn.ikovalev.nl" ];
    proxied = "false";
  };
}
