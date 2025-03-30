{
  config,
  ...
}:

let
  cloudflareSecretFile = "/etc/nixos/secrets/cloudflare.yaml";
in

{
  sops = {
    secrets = {
      cloudflare_api_token = {
        sopsFile = cloudflareSecretFile;
        uid = 1000;
        group = "acme";
        mode = "440";
      };
    };
    templates = {
      "cloudflare-ddns_api_token" = {
        content = ''
          CLOUDFLARE_API_TOKEN="${config.sops.placeholder.cloudflare_api_token}"
        '';
        owner = "cloudflare-ddns";
      };
    };
  };
}
