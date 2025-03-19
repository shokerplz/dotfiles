{
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    ./users.nix
    ./packages.nix
    ./docker.nix
  ];

  # Allows to run AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Sets timezon
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
      monospace = [ "Ubuntu Mono" ];
    };
  };

  # Install nerdfonts
  fonts.packages = with pkgs; [ nerd-fonts.hack ];

  # Allow sudo without password for wheel group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Use ssh keys of the host by default
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Do not check for sops files in nixstate. Needed to fix `Cannot find path set in sops.secrets.*.sopsFile`
  sops.validateSopsFiles = false;

  # Enable firewall
  networking.firewall.enable = true;

}
