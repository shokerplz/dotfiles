{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    git
    wl-clipboard
    appimage-run
    gnome-randr
    sunshine
    xorg.libXtst
    xorg.libXi
    firefox
    vscode
    spotify
    code-cursor
    gnomeExtensions.touch-x
    telegram-desktop
    vlc
    obs-studio
    jellyfin-media-player
    libreoffice-qt6-fresh
    alacritty
    discord
  ];
}
