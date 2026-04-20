{...}: {
  flake.nixosModules.commonDocker = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.commonDocker;
  in {
    options.dotfiles.commonDocker.startOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the Docker daemon should start automatically at boot.";
    };

    config = {
      virtualisation.docker.enable = true;
      virtualisation.docker.enableOnBoot = cfg.startOnBoot;
      virtualisation.oci-containers.backend = "docker";
      virtualisation.docker.daemon.settings = {
        log-driver = "local";
        log-opts = {
          max-size = "10m";
        };
      };

      # Allow docker containers to talk to each other.
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true
      '';
      networking.firewall.extraStopCommands = ''
        iptables -D nixos-fw -i docker0 -p tcp -s 172.16.0.0/12 -d 172.17.0.1 -j nixos-fw-accept || true
      '';
    };
  };
}
