# Core Hyprland window manager settings
{
  pkgs,
  scripts,
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      device = {
        name = "nvtk0603:00-0603:f001";
        transform = 3;
      };

      "$mod" = "SUPER";

      # Default monitor config (fallback)
      monitor = [
        ",preferred,auto,1"
      ];

      # Source nwg-displays config if it exists (overrides defaults)
      source = [
        "~/.config/hypr/monitors.conf"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
        resize_on_border = true;
        extend_border_grab_area = 20;
        hover_icon_on_border = true;
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      env = [
        "XCURSOR_THEME,macOS"
        "XCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "us,ru";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = -0.7;
      };

      windowrulev2 = [
        "float, class:(pavucontrol)"
        "size 60% 60%, class:(pavucontrol)"
        "center, class:(pavucontrol)"
        "float, class:(blueberry.py)"
        "size 50% 60%, class:(blueberry.py)"
        "center, class:(blueberry.py)"
        "float, class:(.*iwgtk.*)"
        "size 50% 60%, class:(.*iwgtk.*)"
        "center, class:(.*iwgtk.*)"
        "float, title:(iwgtk)"
        "size 50% 60%, title:(iwgtk)"
        "center, title:(iwgtk)"
        "float, title:(Calendar)"
        "center, title:(Calendar)"
      ];

      layerrule = [
        "blur, wofi"
        "ignorezero, wofi"
        "blur, eww"
        "ignorezero, eww"
      ];

      bind = [
        # Cmd+Q -> Ctrl+Q (via keyd) -> Kill Active
        "CTRL, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, nautilus"
        # Alt+V -> Toggle Floating (Avoids Cmd+V paste conflict)
        "ALT, V, togglefloating,"
        "$mod, SPACE, exec, wofi --show=drun"
        "$mod, P, pseudo," # dwindle
        "$mod, J, togglesplit," # dwindle
        "$mod, F, fullscreen"
        # Switch keyboard layout (us/ru)
        "CTRL, SPACE, exec, hyprctl switchxkblayout all next"
        # Clipboard history (Cmd+Shift+V via keyd -> Meta+Shift+V)
        "SUPER SHIFT, V, exec, cliphist list | wofi --dmenu --prompt 'Clipboard' | cliphist decode | wl-copy && wtype -M ctrl -M shift v -m ctrl -m shift"
        # Screenshots & Recording (PrintScreen toggles menu, or stops recording if active)
        ", Print, exec, ${scripts.screenshot}"
      ];

      # Volume keys (bindel = repeat when held)
      bindel = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      # Media keys (bindl = works even when locked)
      bindl = [
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
      ];

      bindm = [
        # Move/resize windows with ALT + LMB/RMB
        "ALT, mouse:272, movewindow"
        "ALT, mouse:273, resizewindow"
      ];

      exec-once = [
        "waybar"
        "hyprpaper"
        "dunst"
        "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
        "eww daemon"
        "wl-paste --watch cliphist store"
      ];
    };
  };
}
