{ config, ... }:
let
  homemanagerSecretFile = ./homemanager.yaml;
in
{
  sops = {
    secrets = {
      openrouter_key = {
        sopsFile = homemanagerSecretFile;
        owner = "claude-router";
        group = "claude-router";
        mode = "0440";
      };
    };
  };
}
