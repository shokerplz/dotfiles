{config, ...}: let
  authentikSecretFile = ./cloudflare.yaml;
in {
  sops = {
    secrets = {
      authentikSecretKey = {
        sopsFile = authentikSecretFile;
        mode = "440";
      };
      authentikEmailPassword = {
        sopsFile = authentikSecretFile;
        mode = "440";
      };
    };
    templates = {
      "authentik_env" = {
        content = ''
          AUTHENTIK_SECRET_KEY="${config.sops.placeholder.authentikSecretKey}"
          AUTHENTIK_EMAIL__PASSWORD="${config.sops.placeholder.authentikEmailPassword}"
        '';
      };
    };
  };
}
