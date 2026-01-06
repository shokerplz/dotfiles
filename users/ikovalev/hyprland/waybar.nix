# Waybar status bar configuration
{...}: {
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
          "bluetooth"
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
            "^(?!.*\\S).*" = "";
          };
        };

        "clock" = {
          format = "{:%a %b %d  %H:%M}";
          tooltip = false;
          on-click = "~/.config/eww/scripts/toggle-notifications.sh";
          on-click-right = "gnome-calendar";
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

        "temperature" = {
          format = "󰔏 {temperatureC}°C";
          format-critical = "󰸁 {temperatureC}°C";
          critical-threshold = 80;
          tooltip-format = "CPU Temperature: {temperatureC}°C";
        };

        "cpu" = {
          format = "󰍛 {usage}%";
          tooltip-format = "CPU Usage: {usage}%";
        };

        "memory" = {
          format = "󰘚 {}%";
          tooltip-format = "Memory: {used:0.1f}GB / {total:0.1f}GB";
        };

        "bluetooth" = {
          format = "󰂯";
          format-connected = "󰂱";
          format-connected-battery = "󰂱";
          format-disabled = "󰂲";
          format-off = "󰂲";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery = "{device_alias} ({device_battery_percentage}%)";
          on-click = "~/.config/eww/scripts/toggle-control-center.sh";
          on-click-right = "blueberry";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          tooltip-format = "{timeTo}";
          format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };

        "network" = {
          format-wifi = "󰖩";
          format-ethernet = "󰈀";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ifname} via {gwaddr}";
          tooltip-format-ethernet = "{ipaddr}/{cidr}\n{ifname} via {gwaddr}";
          format-linked = "󰈀";
          format-disconnected = "󱞐";
          tooltip-format-disconnected = "Disconnected";
          on-click = "~/.config/eww/scripts/toggle-control-center.sh";
          on-click-right = "nm-connection-editor";
        };

        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "󰂱 {volume}% {format_source}";
          format-bluetooth-muted = "󰂱 󰝟 {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          tooltip-format = "Output: {volume}%\nMic: {source_volume}%";
          format-icons = {
            headphone = "󰋋";
            phone = "󰏲";
            portable = "󰏲";
            car = "󰄋";
            default = ["󰕿" "󰖀" "󰕾"];
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
}
