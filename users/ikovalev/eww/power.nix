# EWW Power Widget
# Power menu with lock, logout, suspend, reboot, shutdown options
{pathExport}: {
  yuck = ''
    ; ====================
    ; Power Menu Widget
    ; ====================

    ; Window definitions (one per monitor)
    (defwindow power-popup
      :monitor 0
      :geometry (geometry :x "30px" :y "0px" :width "180px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (power-widget))

    (defwindow power-popup-1
      :monitor 1
      :geometry (geometry :x "30px" :y "0px" :width "180px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (power-widget))

    ; Main power widget
    (defwidget power-widget []
      (eventbox :onhoverlost "~/.config/eww/scripts/close-power.sh"
        (box :class "power-box" :orientation "v" :space-evenly false :spacing 4
          (label :class "section-label" :text "Power" :halign "start")
          (button :class "power-item"
            :onclick "~/.config/eww/scripts/power-lock.sh"
            (box :orientation "h" :space-evenly false :spacing 8
              (label :class "power-icon" :text "󰌾")
              (label :text "Lock" :halign "start")))
          (button :class "power-item"
            :onclick "~/.config/eww/scripts/power-logout.sh"
            (box :orientation "h" :space-evenly false :spacing 8
              (label :class "power-icon" :text "󰍃")
              (label :text "Logout" :halign "start")))
          (button :class "power-item"
            :onclick "~/.config/eww/scripts/power-suspend.sh"
            (box :orientation "h" :space-evenly false :spacing 8
              (label :class "power-icon" :text "󰤄")
              (label :text "Suspend" :halign "start")))
          (button :class "power-item"
            :onclick "~/.config/eww/scripts/power-reboot.sh"
            (box :orientation "h" :space-evenly false :spacing 8
              (label :class "power-icon" :text "󰜉")
              (label :text "Reboot" :halign "start")))
          (button :class "power-item power-item-danger"
            :onclick "~/.config/eww/scripts/power-shutdown.sh"
            (box :orientation "h" :space-evenly false :spacing 8
              (label :class "power-icon" :text "󰐥")
              (label :text "Shutdown" :halign "start"))))))
  '';

  scss = ''
    .power-box {
      background: rgba(135, 135, 135, 1);
      border-radius: 0.9rem;
      padding: 8px;
      color: #000000;
    }

    .power-item {
      padding: 8px 12px;
      border-radius: 4px;
      font-size: 0.9rem;
      color: rgba(0, 0, 0, 0.8);

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }
    }

    .power-item-danger {
      &:hover {
        background-color: rgba(220, 53, 69, 0.3);
        color: #000000;
      }
    }

    .power-icon {
      font-size: 1rem;
      min-width: 20px;
    }
  '';

  scripts = {
    "toggle-power.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')

        if [ "$monitor" = "1" ]; then
          window="power-popup-1"
        else
          window="power-popup"
        fi

        if eww active-windows | grep -q "power-popup"; then
          eww close power-popup power-popup-1
        else
          eww open "$window"
        fi
      '';
    };

    "close-power.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
      '';
    };

    "power-lock.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
        hyprlock
      '';
    };

    "power-logout.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
        hyprctl dispatch exit
      '';
    };

    "power-suspend.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
        systemctl suspend
      '';
    };

    "power-reboot.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
        systemctl reboot
      '';
    };

    "power-shutdown.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close power-popup power-popup-1
        systemctl poweroff
      '';
    };
  };
}
