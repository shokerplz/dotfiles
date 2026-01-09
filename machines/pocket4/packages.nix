{
  pkgs,
  nixpkgs-unstable,
  ...
}: let
  virtio-win-iso = pkgs.runCommand "virtio-win-iso" {} ''
    mkdir -p $out/share/virtio-win
    ln -s ${pkgs.virtio-win.src} $out/share/virtio-win/virtio-win.iso
  '';
in {
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
    virtio-win-iso
    orca-slicer
    nixpkgs-unstable.claude-code
    mcp-nixos
  ];
}
