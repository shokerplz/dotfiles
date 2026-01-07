# EWW Notification Center Widget
# macOS-style notification history with grouping by app
{pathExport}: {
  yuck = ''
    ; ====================
    ; Notification Center
    ; ====================

    ; Polling variables
    (defpoll notification-count :interval "1s" :initial "0" "~/.config/eww/scripts/get-notification-count.sh")
    (defpoll notifications :interval "1s" :initial "[]" "~/.config/eww/scripts/get-notifications.sh")

    ; UI state for expanded groups
    (defvar notif-expanded "{}")

    ; Window definitions (one per monitor)
    (defwindow notification-center
      :monitor 0
      :geometry (geometry :x "0px" :y "5px" :width "380px" :anchor "top center")
      :stacking "fg"
      :exclusive false
      :focusable false
      (notification-center-widget))

    (defwindow notification-center-1
      :monitor 1
      :geometry (geometry :x "0px" :y "5px" :width "380px" :anchor "top center")
      :stacking "fg"
      :exclusive false
      :focusable false
      (notification-center-widget))

    ; Main notification center widget
    (defwidget notification-center-widget []
      (eventbox :onhoverlost "~/.config/eww/scripts/close-notifications.sh"
        (box :class "notif-center" :orientation "v" :space-evenly false :spacing 0
          ; Header
          (box :class "notif-header" :orientation "h" :space-evenly false
            (label :class "notif-title" :text "Notifications" :hexpand true :halign "start")
            (button :class "notif-clear-all" :onclick "~/.config/eww/scripts/clear-all-notifications.sh"
              (label :text "Clear All")))

          ; Notification list with limited height for ~3 items
          (scroll :class "notif-scroll" :vscroll true :hscroll false :height 280
            (box :class "notif-list" :orientation "v" :space-evenly false :spacing 8
              (for group in notifications
                (notif-group :group group)))))))

    ; Notification group (stacked by app)
    (defwidget notif-group [group]
      (box :class "notif-group" :orientation "v" :space-evenly false :spacing 0
        ; Group header (clickable to expand/collapse)
        (eventbox :class "notif-group-header"
          :onclick "~/.config/eww/scripts/toggle-notif-group.sh ''\'''${group.app}'"
          (box :orientation "h" :space-evenly false :spacing 10
            (label :class "notif-app-icon" :text {group.icon})
            (label :class "notif-app-name" :text {group.app} :hexpand true :halign "start")
            (label :class "notif-group-count" :text {group.count} :visible {group.count > 1})
            (button :class "notif-group-clear" :onclick "~/.config/eww/scripts/clear-app-notifications.sh ''\'''${group.app}'"
              (label :text "󰅖"))))

        ; Expanded notifications
        (revealer :transition "slidedown" :reveal {group.count == 1 || notif-expanded == group.app} :duration "150ms"
          (box :class "notif-items" :orientation "v" :space-evenly false :spacing 6
            (for notif in {group.items}
              (notif-item :notif notif))))))

    ; Individual notification item
    (defwidget notif-item [notif]
      (box :class "notif-item ''${notif.urgency}" :orientation "h" :space-evenly false :spacing 10
        (eventbox :class "notif-content" :onclick "~/.config/eww/scripts/activate-notification.sh ''\'''${notif.id}' ''\'''${notif.app}'"
          :hexpand true
          (box :orientation "v" :space-evenly false :spacing 2 :hexpand true
            (box :orientation "h" :space-evenly false
              (label :class "notif-summary" :text {notif.summary} :halign "start" :hexpand true :limit-width 35)
              (label :class "notif-time" :text {notif.time}))
            (label :class "notif-body" :text {notif.body} :halign "start" :limit-width 45 :visible {notif.body != ""})))
        (button :class "notif-dismiss" :onclick "~/.config/eww/scripts/dismiss-notification.sh ''\'''${notif.id}'"
          (label :text "󰅖"))))
  '';

  scss = ''
    .notif-center {
      background: rgba(135, 135, 135, 0.98);
      border-radius: 14px;
      padding: 0;
      color: #000000;
    }

    .notif-header {
      padding: 12px 16px;
      border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    }

    .notif-title {
      font-size: 1rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.8);
    }

    .notif-clear-all {
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.5);
      padding: 4px 8px;
      border-radius: 4px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
        color: rgba(0, 0, 0, 0.8);
      }
    }

    .notif-scroll {
    }

    .notif-list {
      padding: 12px;
    }

    .notif-group {
      background-color: rgba(0, 0, 0, 0.06);
      border-radius: 10px;
    }

    .notif-group-header {
      padding: 10px 12px;
      border-radius: 10px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.08);
      }
    }

    .notif-app-icon {
      font-size: 1.1rem;
      min-width: 24px;
    }

    .notif-app-name {
      font-size: 0.85rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.8);
    }

    .notif-group-count {
      font-size: 0.75rem;
      background-color: rgba(0, 0, 0, 0.15);
      color: rgba(0, 0, 0, 0.7);
      padding: 2px 8px;
      border-radius: 10px;
      margin-right: 8px;
    }

    .notif-group-clear {
      font-size: 0.9rem;
      color: rgba(0, 0, 0, 0.4);
      padding: 4px;
      border-radius: 4px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
        color: rgba(0, 0, 0, 0.8);
      }
    }

    .notif-items {
      padding: 0 8px 8px 8px;
    }

    .notif-item {
      background-color: rgba(255, 255, 255, 0.15);
      border-radius: 8px;
      padding: 10px 12px;

      &.CRITICAL {
        background-color: rgba(198, 40, 40, 0.2);
        border-left: 3px solid #c62828;
      }
    }

    .notif-content {
      &:hover {
        background-color: rgba(0, 0, 0, 0.05);
        border-radius: 6px;
      }
    }

    .notif-summary {
      font-size: 0.85rem;
      font-weight: bold;
      color: #000000;
    }

    .notif-time {
      font-size: 0.7rem;
      color: rgba(0, 0, 0, 0.5);
    }

    .notif-body {
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.7);
      margin-top: 2px;
    }

    .notif-dismiss {
      font-size: 0.85rem;
      color: rgba(0, 0, 0, 0.3);
      padding: 4px;
      border-radius: 4px;
      min-width: 24px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
        color: rgba(0, 0, 0, 0.8);
      }
    }

    // Empty state
    .notif-empty {
      padding: 40px 20px;
      color: rgba(0, 0, 0, 0.4);
      font-size: 0.9rem;
    }
  '';

  scripts = {
    "get-notification-count.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Count only app notifications, exclude system/self-generated ones
        count=$(dunstctl history 2>/dev/null | jq '
          [.data[][] | select(
            .appname.data != "notify-send" and
            .appname.data != "grimblast" and
            .appname.data != "Screenshot" and
            .appname.data != "dunst" and
            .appname.data != "udiskie" and
            .appname.data != ".grimblast-wrapped" and
            .appname.data != "" and
            .appname.data != null
          )] | length
        ' 2>/dev/null || echo "0")

        echo "$count"
      '';
    };

    "get-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get notification history from dunst
        history=$(dunstctl history 2>/dev/null)

        if [ -z "$history" ] || [ "$history" = "null" ]; then
          echo "[]"
          exit 0
        fi

        # Parse and group notifications by app
        # Filter out system notifications (WiFi, Bluetooth status messages)
        echo "$history" | jq -c '
          # App icon mapping
          def get_icon:
            if . == "notify-send" then "󰍡"
            elif . == "Spotify" or . == "spotify" then "󰓇"
            elif . == "Discord" or . == "discord" then "󰙯"
            elif . == "Slack" or . == "slack" then "󰒱"
            elif . == "Telegram" or . == "telegram" or . == "org.telegram.desktop" then "󰔁"
            elif . == "Firefox" or . == "firefox" then "󰈹"
            elif . == "Chromium" or . == "chromium" or . == "Google Chrome" then "󰊯"
            elif . == "Thunderbird" or . == "thunderbird" then "󰇮"
            elif . == "Steam" or . == "steam" then "󰓓"
            elif . == "VLC" or . == "vlc" then "󰕼"
            elif . == "Nautilus" or . == "nautilus" or . == "Files" then "󰉋"
            elif . == "Screenshot" or . == "flameshot" then "󰹑"
            else "󰍡"
            end;

          # Check if notification should be filtered out (system/self-generated)
          def is_system_notification:
            (.appname.data == "notify-send") or
            (.appname.data == "grimblast") or
            (.appname.data == "Screenshot") or
            (.appname.data == "dunst") or
            (.appname.data == "") or
            (.appname.data == null) or
            (.summary.data == "WiFi") or
            (.summary.data == "Bluetooth") or
            (.summary.data == "Volume") or
            (.summary.data == "Brightness") or
            (.summary.data == "Recording Started") or
            (.summary.data == "Recording Stopped") or
            (.summary.data == "Recording") or
            (.summary.data == "udiskie") or
            (.summart.data == ".grimblast-wrappe") or
            (.summary.data == "Select Region");

          now as $now |
          [.data[][] |
            # Filter out system notifications
            select(is_system_notification | not) |
            {
              id: .id.data,
              app: .appname.data,
              summary: .summary.data,
              body: (.body.data // ""),
              urgency: .urgency.data,
              timestamp: .timestamp.data,
              time: ((.timestamp.data / 1000000) | floor | $now - . |
                if . < 60 then "now"
                elif . < 3600 then "\(. / 60 | floor)m"
                elif . < 86400 then "\(. / 3600 | floor)h"
                else "\(. / 86400 | floor)d"
                end)
            }
          ] |
          group_by(.app) |
          map({
            app: .[0].app,
            icon: (.[0].app | get_icon),
            count: length,
            items: .
          }) |
          sort_by(-.items[0].timestamp)
        ' 2>/dev/null || echo "[]"
      '';
    };

    "toggle-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')

        if [ "$monitor" = "1" ]; then
          window="notification-center-1"
        else
          window="notification-center"
        fi

        if eww active-windows | grep -q "notification-center"; then
          eww close notification-center notification-center-1
          eww update notif-expanded="{}"
        else
          # Close other popups first
          eww close audio-popup audio-popup-1 power-popup power-popup-1 2>/dev/null
          eww open "$window"
        fi
      '';
    };

    "close-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        eww close notification-center notification-center-1
        eww update notif-expanded="{}"
      '';
    };

    "clear-all-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        dunstctl history-clear
      '';
    };

    "clear-app-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        app="$1"
        # Get all notification IDs for this app and close them
        dunstctl history | jq -r --arg app "$app" \
          '.data[][] | select(.appname.data == $app) | .id.data' | \
          while read -r id; do
            dunstctl history-rm "$id" 2>/dev/null
          done
      '';
    };

    "dismiss-notification.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        id="$1"
        dunstctl history-rm "$id" 2>/dev/null
      '';
    };

    "activate-notification.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        id="$1"
        app="$2"

        # Try to invoke the default action for this notification
        dunstctl action "$id" 2>/dev/null

        # Map app names to window class patterns and desktop files
        # This handles cases where notification app name differs from window class
        get_window_class() {
          case "$1" in
            "Spotify"|"spotify") echo "spotify" ;;
            "Discord"|"discord") echo "discord" ;;
            "Slack"|"slack") echo "Slack" ;;
            "Telegram"|"telegram"|"org.telegram.desktop") echo "org.telegram.desktop" ;;
            "Firefox"|"firefox") echo "firefox" ;;
            "Chromium"|"chromium") echo "chromium" ;;
            "Google Chrome"|"google-chrome") echo "google-chrome" ;;
            "Thunderbird"|"thunderbird") echo "thunderbird" ;;
            "Steam"|"steam") echo "steam" ;;
            "VLC"|"vlc") echo "vlc" ;;
            "Nautilus"|"nautilus"|"Files") echo "org.gnome.Nautilus" ;;
            *) echo "$1" ;;
          esac
        }

        get_desktop_file() {
          case "$1" in
            "Spotify"|"spotify") echo "spotify" ;;
            "Discord"|"discord") echo "discord" ;;
            "Slack"|"slack") echo "slack" ;;
            "Telegram"|"telegram"|"org.telegram.desktop") echo "org.telegram.desktop" ;;
            "Firefox"|"firefox") echo "firefox" ;;
            "Chromium"|"chromium") echo "chromium" ;;
            "Google Chrome"|"google-chrome") echo "google-chrome" ;;
            "Thunderbird"|"thunderbird") echo "thunderbird" ;;
            "Steam"|"steam") echo "steam" ;;
            "VLC"|"vlc") echo "vlc" ;;
            "Nautilus"|"nautilus"|"Files") echo "org.gnome.Nautilus" ;;
            *) echo "$1" ;;
          esac
        }

        window_class=$(get_window_class "$app")
        desktop_file=$(get_desktop_file "$app")

        # Try to find and focus the window using hyprctl
        # Search by class (case insensitive)
        window_address=$(hyprctl clients -j | jq -r --arg class "$window_class" \
          '.[] | select(.class | ascii_downcase == ($class | ascii_downcase)) | .address' | head -1)

        if [ -n "$window_address" ] && [ "$window_address" != "null" ]; then
          # Window found, focus it
          hyprctl dispatch focuswindow "address:$window_address"
        else
          # Window not found, try to launch the app
          # First try gtk-launch with desktop file
          if gtk-launch "$desktop_file" 2>/dev/null; then
            : # launched successfully
          elif gtk-launch "''${desktop_file,,}" 2>/dev/null; then
            : # try lowercase
          else
            # Fallback: try running the app directly
            case "$app" in
              "Spotify"|"spotify") spotify & ;;
              "Discord"|"discord") discord & ;;
              "Slack"|"slack") slack & ;;
              "Telegram"|"telegram"|"org.telegram.desktop") telegram-desktop & ;;
              "Firefox"|"firefox") firefox & ;;
              "Nautilus"|"nautilus"|"Files") nautilus & ;;
              *) notify-send "Notification Center" "Could not open $app" ;;
            esac
          fi
        fi

        # Remove from history after activation
        dunstctl history-rm "$id" 2>/dev/null

        # Close notification center
        ~/.config/eww/scripts/close-notifications.sh
      '';
    };

    "toggle-notif-group.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        app="$1"
        current=$(eww get notif-expanded 2>/dev/null || echo "{}")

        if [ "$current" = "$app" ]; then
          eww update notif-expanded="{}"
        else
          eww update "notif-expanded=$app"
        fi
      '';
    };

    # Waybar module script
    "waybar-notifications.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        count=$(dunstctl count history 2>/dev/null || echo "0")

        if [ "$count" -eq 0 ]; then
          echo '{"text": "", "alt": "none", "tooltip": "No notifications", "class": "empty"}'
        else
          echo "{\"text\": \"$count\", \"alt\": \"some\", \"tooltip\": \"$count notification(s)\", \"class\": \"has-notifications\"}"
        fi
      '';
    };
  };
}
