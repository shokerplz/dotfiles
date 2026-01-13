{
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    neovim
    git
    wl-clipboard
    appimage-run
    gnome-randr
    sunshine
    xorg.libXtst
    xorg.libXi
    firefox-bin
    vscode
    spotify
    telegram-desktop
    vlc
    obs-studio
    libreoffice-qt6-fresh
    alacritty
    discord
    solaar
    libnotify
    adwaita-icon-theme
    nixpkgs-unstable.codex
    nixpkgs-unstable.claude-code-router
    nixpkgs-unstable.claude-code
    nixpkgs-unstable.gemini-cli
    nixpkgs-unstable.godot
    nixpkgs-unstable.opencode
    nixpkgs-unstable.ddgr
    direnv
    vagrant
    gh
    devenv
    (pkgs.python312.withPackages (python-pkgs:
      with python-pkgs; [
        requests
        uv
      ]))
    nodejs
    orca-slicer
    glow
    mcp-nixos
    bun
    nodejs
    uv
    sqlite
  ];

  # That will allow apps to have LD_LIBRARY_PATH
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];
}
