{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    wl-clipboard
    appimage-run
    gnome-randr
    sunshine
    xorg.libXtst
    xorg.libXi
  ];
}
