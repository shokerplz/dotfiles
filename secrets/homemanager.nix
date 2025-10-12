{config, ...}: let
  homemanagerSecretFile = ./homemanager.yaml;
in {
  sops = {
    secrets = {
      openrouter_key = {
        sopsFile = homemanagerSecretFile;
      };
    };
  };
}
