{
  config,
  pkgs,
  nix-local-cache,
  ...
}: {
  imports = [
    ../../secrets/nix-cache.nix
  ];

  services.nginx = {
    enable = true;
    virtualHosts."cache" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 20080;
        }
      ];
      default = true;
      serverName = "cache nix-cache.ikovalev.nl";
      root = "/mnt/zfs-pool0/nix-cache/cache";
      extraConfig = ''
        autoindex on;
      '';
    };
  };

  systemd.services.nix-local-cache-server = {
    environment.GIT_SSH_COMMAND = "ssh -i ${config.sops.secrets.git_key.path} -o IdentitiesOnly=yes";
  };

  programs.ssh.knownHosts = {
    "github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      extraHostNames = ["github"]; # Optional aliases
    };

    "gitlab.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    };

    "git.ikovalev.nl" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNA+lEEaFORzkxVwC0FpwJpkGVUA32nwDXkkVZ7kHnr";
    };
  };

  services.nix-local-cache-server = {
    enable = true;
    package = nix-local-cache.packages.${pkgs.system}.server;
    port = 21080;
    workerThreads = 2;
    workingDir = "/mnt/zfs-pool0/nix-cache";
    secretKeyFile = config.sops.secrets.nix_cache_private_key.path;
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 20080 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 21080 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 20080 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 21080 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
