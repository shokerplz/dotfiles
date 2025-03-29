{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    wl-clipboard
    appimage-run
    firefox
    vscode
    spotify
    bambu-studio
    code-cursor
    gnomeExtensions.touch-x
    telegram-desktop
    vlc
    obs-studio
    jellyfin-media-player
    libreoffice-qt6-fresh
  ];
}
