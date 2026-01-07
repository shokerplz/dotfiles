{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../secrets/homemanager.nix
    ./hyprland
    ./eww
  ];

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [];

  home.username = "ikovalev";
  home.homeDirectory = "/home/ikovalev";

  home.pointerCursor = {
    name = "macOS";
    size = 24;
    package = pkgs.apple-cursor;
    gtk.enable = true;
    x11.enable = true;
  };

  home.stateVersion = "24.11"; # Do not change that!

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true; # Home manager manages itself

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
    ];
    extraConfig = ''
      set -ga terminal-overrides ',*256color*:smcup@:rmcup@'
      set -g @yank_selection_mouse 'clipboard'
      set -s set-clipboard on
    '';
  };

  programs.keychain = {
    enable = true;
    keys = ["~/.ssh/do_key"];
    extraFlags = ["--quiet"];
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.openrouter_key.path})";
      QT_QPA_PLATFORMTHEME = "adwaita";
    };
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };

  home.packages = with pkgs; [
    # Additional packages here
    gcc
    xclip
    wl-clipboard
  ];

  # Create empty monitors.conf if it doesn't exist, so Hyprland can source it
  # nwg-displays will overwrite this when you configure displays
  home.activation.createMonitorsConf = ''
    if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
      mkdir -p "$HOME/.config/hypr"
      echo "# Managed by nwg-displays" > "$HOME/.config/hypr/monitors.conf"
    fi
  '';

  # Create empty gaming.conf for machine-specific game window rules
  home.activation.createGamingConf = ''
    if [ ! -f "$HOME/.config/hypr/gaming.conf" ]; then
      mkdir -p "$HOME/.config/hypr"
      cat > "$HOME/.config/hypr/gaming.conf" << 'EOF'
# Machine-specific gaming window rules
# Example: Launch games on specific monitor
# windowrulev2 = monitor DP-3, class:^(steam_app_.*)$
# windowrulev2 = fullscreen, class:^(steam_app_.*)$
EOF
    fi
  '';

  # Dark mode for GTK apps
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Dark mode for Qt apps
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Set color-scheme preference for apps that check it
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
