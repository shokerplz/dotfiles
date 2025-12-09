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
    telegram-desktop
    vlc
    obs-studio
    libreoffice-qt6-fresh
    guvcview # Camera app for KVM
    virtio-win
  ];
}
