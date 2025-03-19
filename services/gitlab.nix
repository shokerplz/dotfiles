{ config, pkgs, ... }:

let
  gitlabSecretFile = "secrets/gitlab.yaml";
in

{
  # Secrets needed for Gitlab
  sops.secrets =
    builtins.mapAttrs
      (_: _: {
        sopsFile = gitlabSecretFile;
        uid = 2000;
      })
      {
        databasePassword = { };
        initialRootPassword = { };
        "secrets.secret" = { };
        "secrets.otp" = { };
        "secrets.db" = { };
      };

  # User for Gitlab
  users.users.gitlab = {
    isNormalUser = false;
    description = "Gitlab user";
    uid = 2000;
  };

  # Gitlab Service
  services.gitlab = {
    enable = true;
    databasePasswordFile = config.sops.secrets.databasePassword.path;
    initialRootPasswordFile = config.sops.secrets.initialRootPassword.path;
    user = "${config.users.users.gitlab.name}";
    statePath = "/mnt/zfs-pool0/gitlab/state";
    smtp = {
      enable = true;
      domain = "ikovalev.nl";
    };
    backup = {
      path = "/mnt/zfs-pool0/gitlab/backup";
      keepTime = 48;
      startAt = "05:00";
    };
    extraEnv = {
      GITALY_COMMAND_SPAWN_MAX_PARALLEL = "2";
      MALLOC_CONF = "dirty_decay_ms:1000,muzzy_decay_ms:1000";
    };
    sidekiq.concurrency = 10;
    extraGitlabRb = ''
      gitaly['configuration'] = {
          concurrency: [
            {
              'rpc' => "/gitaly.SmartHTTPService/PostReceivePack",
              'max_per_repo' => 3,
            }, {
              'rpc' => "/gitaly.SSHService/SSHUploadPack",
              'max_per_repo' => 3,
            },
          ],
      }
    '';
    registry = {
      enable = true;
      externalPort = 443;
      externalAddress = "registry.ikovalev.nl";
    };
    secrets = {
      secretFile = config.sops.secrets."secrets.secret".path;
      otpFile = config.sops.secrets."secrets.otp".path;
      dbFile = config.sops.secrets."secrets.db".path;
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };
}
