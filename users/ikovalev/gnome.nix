{ lib, ... }: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "status-icons@gnome-shell-extensions.gcampax.github.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "gsconnect@andyholmes.github.io"
        "eepresetselector@ulville.github.io"
        "notification-timeout@chlumskyvaclav.gmail.com"
        "windowIsReady_Remover@nunofarruca@gmail.com"
        "all-in-one-clipboard@NiffirgkcaJ.github.io"
      ];
      favorite-apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = false;
      apply-custom-theme = true;
      autohide-in-fullscreen = false;
      background-opacity = 0.8;
      custom-theme-shrink = false;
      dash-max-icon-size = 48;
      disable-overview-on-startup = true;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = 0.9;
      hide-tooltip = false;
      icon-size-fixed = false;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      isolate-monitors = false;
      isolate-workspaces = false;
      multi-monitor = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-3";
      preview-size-scale = 0.0;
      show-mounts-network = true;
      show-show-apps-button = true;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      toolkit-accessibility = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Control>space" ];
      switch-input-source-backward = [ "<Shift><Control>space" ];
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "Print" ];
      toggle-message-tray = [ ];
      toggle-overview = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      search = [ "<Super>space" ];
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
    };
  };
}
