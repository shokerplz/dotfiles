{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./users.nix
    ./packages.nix
    ./docker.nix
    ./overlays.nix
  ];

  # Allows to run AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Allow myself to rebuild nixos from main-pc
  nix.settings.trusted-users = ["ikovalev"];

  # Garbage collection
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Sets timezone
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
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

  # Set default font for tty console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;

  # Set default domain for all hosts
  networking.domain = "home";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  fonts.fontconfig = {
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

  # Install nerdfonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.substituters = [
    "https://nix-cache.ikovalev.nl"
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nix-cache.ikovalev.nl:Krpx8e2jWFxP2mc+AqXkkMX0tGBFCskuRcWUcNZ4DtQ="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];

  # Allow sudo without password for wheel group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Use ssh keys of the host by default
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  # Do not check for sops files in nixstate. Needed to fix `Cannot find path set in sops.secrets.*.sopsFile`
  sops.validateSopsFiles = false;

  # Enable firewall
  networking.firewall.enable = true;

  # Enable WireGuard
  networking.wireguard.enable = true;

  # Disable RP Filter (Otherwise wireguard wouldn't work properly)
  networking.firewall.checkReversePath = false;
}
