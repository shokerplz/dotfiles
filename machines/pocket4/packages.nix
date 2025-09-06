{ pkgs, ... }:
{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];
    packages = [
    ];
  };

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
    guvcview # Camera app for KVM
  ];
}
