{
  config,
  pkgs,
  ...
}: let
  gitlabSecretFile = ../secrets/gitlab.yaml;
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
        url = "https://git.ikovalev.nl";
        executor = "docker";
        dockerImage = "alpine:latest";
        dockerPrivileged = false;
      };
    };
  };

  # Ensure the runner can talk to the docker daemon
  users.users.gitlab-runner.extraGroups = ["docker"];
}
