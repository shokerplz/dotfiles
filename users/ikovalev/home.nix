{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../secrets/homemanager.nix
    ./hyprland.nix
    ./eww.nix
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

  # Power menu script (wofi-based, matches waybar style)
  home.file.".config/wofi/power-menu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      options="  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown"
      selected=$(echo -e "$options" | wofi --dmenu --prompt "Power" --width 200 --height 210 --cache-file /dev/null)

      case "$selected" in
        *Lock*) hyprlock ;;
        *Logout*) hyprctl dispatch exit ;;
        *Suspend*) systemctl suspend ;;
        *Reboot*) systemctl reboot ;;
        *Shutdown*) systemctl poweroff ;;
      esac
    '';
  };

  # Create empty monitors.conf if it doesn't exist, so Hyprland can source it
  # nwg-displays will overwrite this when you configure displays
  home.activation.createMonitorsConf = ''
    if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
      mkdir -p "$HOME/.config/hypr"
      echo "# Managed by nwg-displays" > "$HOME/.config/hypr/monitors.conf"
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
