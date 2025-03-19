{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    wl-clipboard
    appimage-run
    google-chrome
    steam
    vscode
    spotify
    bambu-studio
    code-cursor
    gnomeExtensions.wireguard-vpn-extension
    gnomeExtensions.touch-x
    telegram-desktop
    vlc
    obs-studio
    jellyfin-media-player
    libreoffice-qt6-fresh
    mangohud
    gamescope
  ];
}
