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
