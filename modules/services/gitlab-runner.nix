{...}: {
  flake.nixosModules.serviceGitlabRunner = {
    config,
    ...
  }: let
    gitlabSecretFile = ../../secrets/gitlab.yaml;
  in {
    sops.secrets."gitlab-runner/token" = {
      sopsFile = gitlabSecretFile;
      restartUnits = ["gitlab-runner.service"];
    };

    services.gitlab-runner = {
      enable = true;
      services = {
        default-runner = {
          authenticationTokenConfigFile = config.sops.secrets."gitlab-runner/token".path;
          executor = "docker";
          dockerImage = "alpine:latest";
          dockerPrivileged = false;
        };
      };
    };

    users.users.gitlab-runner = {
      isSystemUser = true;
      group = "gitlab-runner";
      extraGroups = ["docker"];
    };

    users.groups.gitlab-runner = {};
  };
}
