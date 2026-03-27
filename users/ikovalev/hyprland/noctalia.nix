{pkgs, ...}: {
  programs.noctalia-shell = {
    enable = true;
    settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
  };
  home.packages = with pkgs; [
    grim
    imagemagick
    wf-recorder
    tesseract
    xdg-utils
    jq
    satty
  ];
}
