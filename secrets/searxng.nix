{config, ...}: let
  searxngSecretFile = ./searxng.yaml;
in {
  sops.secrets.searxng_secret_key = {
    sopsFile = searxngSecretFile;
    key = "secret_key";
  };

  sops.templates.searxng_env = {
    content = ''
      SEARXNG_SECRET="${config.sops.placeholder.searxng_secret_key}"
    '';
  };
}
