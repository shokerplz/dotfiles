{
  config,
  pkgs,
  lib,
  ...
}: let
  selection =
    config.environment.packageSelector
    or (import ../../lib {inherit lib;}).customPackages.mkSelector {inherit pkgs;};
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
    {
      name = "xorg.libXtst";
    }
    {
      name = "xorg.libXi";
    }
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
