{
  pkgs,
  pkgs-unstable,
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
    guvcview
    virtio-win-iso
  ];
}
