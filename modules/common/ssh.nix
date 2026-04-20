{...}: {
  flake.nixosModules.commonSSH = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.commonSSH;
  in {
    options.dotfiles.commonSSH.startOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether sshd should start automatically when commonSSH is enabled.";
    };

    config = {
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
        };
      };

      systemd.services.sshd.wantedBy = lib.mkIf (!cfg.startOnBoot) (lib.mkForce []);
    };
  };
}
