{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.commonDefault = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      ./_users.nix
      ./_packages.nix
      self.nixosModules.commonDocker
      inputs.sops-nix.nixosModules.sops
    ];

    # Allow myself to rebuild nixos from main-pc + garbage collect
    nix = {
      settings.trusted-users = ["ikovalev"];

      optimise.automatic = true;
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "nl_NL.UTF-8";
      LC_NUMERIC = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_TIME = "nl_NL.UTF-8";
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    networking = {
      networkmanager.enable = lib.mkDefault true;
      # Disable RP filter so WireGuard can work properly
      firewall.checkReversePath = false;
    };

    fonts = {
      fontconfig = {
        defaultFonts = {
          serif = [
            "Liberation Serif"
            "Vazirmatn"
          ];
          sansSerif = [
            "Ubuntu"
            "Vazirmatn"
          ];
          monospace = ["Ubuntu Mono"];
        };
      };
      packages = with pkgs; [
        nerd-fonts.hack
        nerd-fonts.jetbrains-mono
      ];
    };

    nix.settings.substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    sops.validateSopsFiles = true;

    networking.firewall.enable = true;

    networking.wireguard.enable = true;
  };
}
