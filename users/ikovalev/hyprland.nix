{pkgs, ...}: {
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

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 5;

        modules-left = ["hyprland/window"];
        modules-center = ["custom/notifications" "clock"];
        modules-right = [
          "tray"
          "hyprland/language"
          "temperature"
          "cpu"
          "memory"
          "network"
          "pulseaudio"
          "battery"
          "custom/power"
        ];

        tray = {
          spacing = 10;
        };

        "hyprland/language" = {
          format = "{}";
          format-en = "EN";
          format-ru = "RU";
        };

        "hyprland/window" = {
          format = "{class}";
          max-length = 20;
          rewrite = {
            "^(?!.*\\S).*" = "Finder";
          };
        };

        "clock" = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
          on-click = "~/.config/eww/scripts/toggle-notifications.sh";
        };

        "custom/notifications" = {
          format = "{icon}{text}";
          format-icons = {
            none = "";
            some = "󰍡 ";
          };
          return-type = "json";
          exec = "~/.config/eww/scripts/waybar-notifications.sh";
          on-click = "~/.config/eww/scripts/toggle-notifications.sh";
          interval = 1;
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        "network" = {
          format-wifi = "{essid} ({signalStrength}%) 󰖩";
          format-ethernet = "{ipaddr}/{cidr} 󰈀";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "󱞐";
          on-click = "~/.config/eww/scripts/toggle-control-center.sh";
          on-click-right = "iwgtk"; # Fallback for advanced settings
        };

        "pulseaudio" = {
          format = "{volume}% {icon}   {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = "  {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "~/.config/eww/scripts/toggle-control-center.sh";
          on-click-right = "pavucontrol";
        };

        "custom/power" = {
          format = "";
          tooltip = false;
          on-click = "~/.config/eww/scripts/toggle-power.sh";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", monospace;
        font-size: 1rem;
        min-height: 0;
        padding: 0;
        margin: 0;
        border-radius: 0 0 0.8rem 0.8rem;
      }

      window#waybar {
        background: rgba(255, 255, 255, 0.5);
        color: rgb(0, 0, 0);
      }

      .modules-left {
        margin-left: 0.5rem;
      }

      .modules-right {
        margin-right: 0.5rem;
      }

      tooltip {
        background: #000000;
      }
      tooltip label {
        color: white;
      }

      #clock {
        font-weight: 800;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #bluetooth,
      #network,
      #pulseaudio,
      #language,
      #custom-power,
      #custom-notifications,
      #tray {
        margin: 0 4px;
        padding: 0 5px;
        color: #000000;
      }

      #custom-notifications {
        padding: 0 8px;
      }

      #custom-notifications.has-notifications {
        color: #000000;
        font-weight: bold;
      }

      #custom-notifications.empty {
        color: rgba(0, 0, 0, 0.4);
      }

      #battery icon {
        color: red;
      }

      #battery.charging,
      #battery.plugged {
        color: #ffffff;
        background-color: #26a65b;
      }

      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }

      #battery.warning:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #000000;
      }

      #bluetooth.disabled,
      #bluetooth.off {
        color: rgba(0, 0, 0, 0.3);
      }

      #temperature.critical {
        background-color: #eb4d4b;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }
    '';
  };
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "solarized";
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      columns = 1;
    };
    style = ''
      * {
        font-family: "SF Pro Display", "Helvetica Neue", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: rgba(30, 30, 30, 0.95);
        border-radius: 12px;
        border: 1px solid rgba(255, 255, 255, 0.1);
      }

      #input {
        background-color: rgba(255, 255, 255, 0.1);
        border: none;
        border-radius: 8px;
        margin: 12px;
        padding: 12px 16px;
        color: #ffffff;
        font-size: 18px;
      }

      #input:focus {
        outline: none;
        box-shadow: none;
      }

      #inner-box {
        margin: 0 12px 12px 12px;
      }

      #outer-box {
        margin: 0;
        padding: 0;
      }

      #scroll {
        margin: 0;
        padding: 0;
      }

      #entry {
        padding: 10px 12px;
        margin: 2px 0;
        border-radius: 8px;
        color: #ffffff;
      }

      #entry:selected {
        background-color: rgba(0, 122, 255, 0.8);
      }

      #entry:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #text {
        margin-left: 8px;
        color: #ffffff;
      }

      #img {
        margin-right: 4px;
      }
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        # Geometry
        width = "(280, 400)";
        height = "(0, 300)";
        offset = "20x40";
        origin = "top-right";
        notification_limit = 5;
        gap_size = 8;

        # Appearance - macOS-inspired with your color scheme
        font = "JetBrainsMono Nerd Font 10";
        frame_width = 1;
        frame_color = "#a0a0a0";
        corner_radius = 14;
        transparency = 10;
        padding = 16;
        horizontal_padding = 16;
        text_icon_padding = 16;
        separator_height = 1;
        separator_color = "#a0a0a0";

        # Text formatting
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        word_wrap = true;
        ellipsize = "end";
        line_height = 4;

        # Progress bar (for volume/brightness)
        progress_bar = true;
        progress_bar_height = 6;
        progress_bar_frame_width = 0;
        progress_bar_corner_radius = 3;
        progress_bar_min_width = 200;
        progress_bar_max_width = 360;

        # Icons
        icon_position = "left";
        min_icon_size = 48;
        max_icon_size = 64;
        icon_corner_radius = 8;

        # Behavior
        sort = "yes";
        indicate_hidden = "yes";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "no";
        sticky_history = "yes";

        # Mouse actions (like macOS - click to dismiss)
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#8a8a8a";
        foreground = "#1a1a1a";
        highlight = "#4a4a4a";
        frame_color = "#9a9a9a";
        timeout = 5;
      };

      urgency_normal = {
        background = "#8a8a8a";
        foreground = "#1a1a1a";
        highlight = "#4a4a4a";
        frame_color = "#9a9a9a";
        timeout = 8;
      };

      urgency_critical = {
        background = "#c62828";
        foreground = "#ffffff";
        highlight = "#ff5252";
        frame_color = "#b71c1c";
        timeout = 0;
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        # "/path/to/default/wallpaper.png"
      ];
      wallpaper = [
        # "monitor,/path/to/default/wallpaper.png"
      ];
    };
  };
}
