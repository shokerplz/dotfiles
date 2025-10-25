{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../secrets/homemanager.nix
  ];

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  home.username = "ikovalev";
  home.homeDirectory = "/home/ikovalev";

  home.stateVersion = "24.11"; # Do not change that!

  programs.home-manager.enable = true; # Home manager manages itself

  programs.alacritty = {
    enable = true;
    settings = {
      keyboard.bindings = [
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control";
          chars = "\\u0003";
        }
      ];
    };
  };

  programs.ssh.enable = true;
  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;
    extraConfig = ''
      set -ga terminal-overrides ',*256color*:smcup@:rmcup@'
    '';
  };

  programs.keychain = {
    enable = true;
    agents = ["ssh"];
    keys = ["~/.ssh/do_key"];
    extraFlags = ["--quiet"];
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      TERMINAL = "alacritty";
      XCURSOR_THEME = "Adwaita alacritty";
      EDITOR = "nvim";
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.openrouter_key.path})";
    };
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };

  # Enable and configure GNOME extensions
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "clipboard-history@alexsaveau.dev"
        "system-monitor@parasuraman.gitlab.gnome-shell-extensions.gcampax.github.com"
        "easyeffects-preset-selector@ulville.github.io"
        "notification-timeout@chlumskyvaclav.gmail.com"
        "window-is-ready-remover@nunofarruca@gmail.com"
        "gsconnect@andyholmes.github.io"
      ];
    };
    # Optional: Configure dash-to-dock position
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
    };
  };

  home.packages = with pkgs; [
    # Additional packages here
    gcc
  ];
}
