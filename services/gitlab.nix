{ config, pkgs, ... }:

let
  gitlabSecretFile = "/etc/nixos/secrets/gitlab.yaml";
in

{
  # Secrets needed for Gitlab
  sops.secrets =
    builtins.mapAttrs
      (_: _: {
        sopsFile = gitlabSecretFile;
        uid = config.users.users.gitlab.uid;
      })
      {
        databasePassword = { };
        initialRootPassword = { };
        "secrets/secret" = { };
        "secrets/otp" = { };
        "secrets/db" = { };
        "ssh/rsa" = { };
        "ssh/ecdsa" = { };
        "ssh/ed25519" = { };
      };

  # User for Gitlab
  users.users.gitlab = {
    isNormalUser = false;
    description = "Gitlab user";
  };

  # Generate cert for registry
  security.pki.certificates = [ "/etc/ssl/certs/registry.ikovalev.nl.crt" ];

  systemd.services."generate-registry-cert" = {
    script = ''
      mkdir -p /etc/ssl/certs
      mkdir -p /etc/ssl/private
      openssl req -x509 -newkey rsa:4096 -nodes \
        -days 3650 \
        -subj "/CN=registry.ikovalev.nl" \
        -keyout /etc/ssl/private/registry.ikovalev.nl.key \
        -out /etc/ssl/certs/registry.ikovalev.nl.crt
      chown gitlab:gitlab /etc/ssl/certs/registry.ikovalev.nl.crt
      chown gitlab:gitlab /etc/ssl/private/registry.ikovalev.nl.key
    '';
    path = [ pkgs.openssl ];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Gitlab Service
  services.gitlab = {
    enable = true;
    databasePasswordFile = config.sops.secrets.databasePassword.path;
    initialRootPasswordFile = config.sops.secrets.initialRootPassword.path;
    initialRootEmail = "gitlab@ikovalev.nl";
    user = "gitlab";
    statePath = "/mnt/zfs-pool0/gitlab/state";
    port = 443;
    host = "git.ikovalev.nl";
    https = true;
    smtp = {
      enable = true;
      domain = "ikovalev.nl";
    };
    backup = {
      path = "/mnt/zfs-pool0/gitlab/backup";
      keepTime = 48;
      startAt = "05:00";
    };
    workhorse.config = {
      listeners = [
        {
          network = "tcp";
          addr = "0.0.0.0:10080";
        }
      ];
    };
    extraEnv = {
      GITALY_COMMAND_SPAWN_MAX_PARALLEL = "2";
      MALLOC_CONF = "dirty_decay_ms:1000,muzzy_decay_ms:1000";
    };
    sidekiq.concurrency = 10;
    puma.workers = 0;
    extraShellConfig = {
      sshd = {
        listen = "[::]:10022";
        host_key_files = [
          config.sops.secrets."ssh/rsa".path
          config.sops.secrets."ssh/ecdsa".path
          config.sops.secrets."ssh/ed25519".path
        ];
      };
    };
    extraConfig = {
      gitaly = {
        configuration = {
          concurrency = [
            {
              rpc = "/gitaly.SmartHTTPService/PostReceivePack";
              max_per_repo = 3;
            }
            {
              rpc = "/gitaly.SSHService/SSHUploadPack";
              max_per_repo = 3;
            }
          ];
        };
      };
    };
    registry = {
      enable = true;
      externalPort = 10443;
      externalAddress = "registry.ikovalev.nl";
      certFile = "/etc/ssl/certs/registry.ikovalev.nl.crt";
      keyFile = "/etc/ssl/private/registry.ikovalev.nl.key";
    };
    secrets = {
      secretFile = config.sops.secrets."secrets/secret".path;
      otpFile = config.sops.secrets."secrets/otp".path;
      dbFile = config.sops.secrets."secrets/db".path;
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };

  # Gitlab SSHD service
  systemd.services.gitlab-sshd = {
    after = [
      "network.target"
      "gitlab.service"
    ];
    bindsTo = [ "gitlab.service" ];
    wantedBy = [ "gitlab.target" ];
    partOf = [ "gitlab.target" ];

    serviceConfig = {
      Type = "simple";
      User = config.services.gitlab.user;
      Group = config.services.gitlab.group;
      Restart = "on-failure";
      WorkingDirectory = config.systemd.services.gitlab.serviceConfig.WorkingDirectory;
      ExecStart = "${config.services.gitlab.packages.gitlab-shell}/bin/gitlab-sshd -config-dir /run/gitlab/";
    };
  };

  # Gitlab firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 10080 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 10443 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 10022 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 10080 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 10443 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 10022 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
