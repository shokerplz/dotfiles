{ config, pkgs, ... }:

{
  imports = [
    ../modules/cloudflare-ddns.nix
  ];

  # Cloudflare DDNS service to announce my public ip
  config.services.cloudflare-ddns = {
    enable = true;
    credentialsFile = config.sops.templates."cloudflare-ddns_api_token".path;
    domains = [ "vpn.ikovalev.nl" ];
    proxied = "false";
  };

  config.nixpkgs.overlays = [
    (final: prev: {
      cloudflare-ddns = final.callPackage ../packages/cloudflare-ddns.nix { };
    })
  ];
}
