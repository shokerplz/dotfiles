{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../secrets/homemanager.nix
    ./gnome.nix
  ];

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [];

  home.username = "ikovalev";
  home.homeDirectory = "/home/ikovalev";

  home.stateVersion = "24.11"; # Do not change that!

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
      XCURSOR_THEME = "Adwaita alacritty";
      EDITOR = "nvim";
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.openrouter_key.path})";
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
}
