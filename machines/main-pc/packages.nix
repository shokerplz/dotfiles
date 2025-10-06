{
  config,
  pkgs,
  lib,
  ...
}: let
  selection = let
    fallback =
      (import ../../lib {inherit lib;}).customPackages.mkSelector {inherit pkgs;};
    configured = config.environment.packageSelector;
  in
    if configured != null
    then configured
    else fallback;
  pkgsList = selection.resolveList [
    "neovim"
    "git"
    "wl-clipboard"
    "appimage-run"
    "gnome-randr"
    {
      name = "sunshine";
      channel = "unstable";
    }
    "xorg.libXtst"
    "xorg.libXi"
    "firefox"
    "vscode"
    {
      name = "spotify";
      channel = "unstable";
    }
    {
      name = "code-cursor";
      channel = "unstable";
    }
    "gnomeExtensions.touch-x"
    "telegram-desktop"
    "vlc"
    {
      name = "obs-studio";
      channel = "unstable";
    }
    "libreoffice-qt6-fresh"
    "alacritty"
    "discord"
    "solaar"
    "libnotify"
    "adwaita-icon-theme"
    "cinny-desktop"
    {
      name = "codex";
      channel = "unstable";
    }
  ];
in {
  environment.systemPackages = pkgsList;
}
