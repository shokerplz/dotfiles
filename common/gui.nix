{ conifg, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig."90-disable-suspend" = {
        # ---- ALSA monitor rules (device + node) -------------------------
        "monitor.alsa.rules" = [
          # 1. device‑wide: keep every ALSA card alive forever
          {
            "matches" = [
              { "device.name" = "~alsa_card.*"; }
            ];
            "actions" = {
              "update-props" = {
                "api.alsa.use-acp" = true;
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }

          # 2. node‑side extras (optional but nice)
          {
            "matches" = [
              { "node.name" = "~alsa_output.*"; }
              { "node.name" = "~alsa_input.*"; }
            ];
            "actions" = {
              "update-props" = {
                "node.pause-on-idle" = false;
                "node.suspend-on-idle" = false;
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
    };
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ikovalev"; # Check user in common/users.nix

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Exclude some GNOME packages
  environment.gnome.excludePackages = (
    with pkgs;
    [
      atomix # puzzle game
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      gnome-photos
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ]
  );
}
