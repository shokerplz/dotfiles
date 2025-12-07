{config, ...}: let
  gitSecretFile = ./git.yaml;
in {
  sops = {
    secrets = {
      git_key = {
        sopsFile = gitSecretFile;
      };
    };
  };
}
