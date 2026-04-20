{...}: {
  flake.nixosModules.serviceCloudflareDDNS = {
    config,
    ...
  }: {
    imports = [
      ../../secrets/cloudflare.nix
    ];

    services.cloudflare-ddns = {
      enable = true;
      credentialsFile = config.sops.templates.cloudflare-ddns_api_token.path;
      domains = [
        "vpn.ikovalev.nl"
      ];
      proxied = "false";
    };
  };
}
