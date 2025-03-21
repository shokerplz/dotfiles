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
  };
}
