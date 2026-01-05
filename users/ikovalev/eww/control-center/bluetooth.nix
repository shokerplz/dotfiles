# Bluetooth Section for Control Center
{pathExport}: {
  yuck = ''
    ; Bluetooth polling variables with initial values
    (defpoll bt-status :interval "2s"
      :initial '{"powered":"true","scanning":"false"}'
      "~/.config/eww/scripts/bt-get-status.sh")
    (defpoll bt-devices :interval "2s"
      :initial "[]"
      "~/.config/eww/scripts/bt-get-devices.sh")

    ; Bluetooth section widget
    (defwidget bluetooth-section []
      (box :class "cc-section" :orientation "v" :space-evenly false :spacing 4
        ; Header
        (box :class "cc-section-header" :orientation "h" :space-evenly false
          (label :class "cc-section-title" :text "Bluetooth" :hexpand true :halign "start")
          (label :class "cc-section-status bt-scanning"
            :text {bt-status.scanning == "true" ? "scanning..." : ""}
            :visible {bt-status.scanning == "true"})
          (button :class "cc-toggle-btn ''${bt-status.powered == "true" ? "active" : "disabled"}"
            :onclick "~/.config/eww/scripts/bt-toggle.sh"
            (label :text {bt-status.powered == "true" ? "󰂯" : "󰂲"})))

        ; Device list
        (revealer :transition "slidedown" :reveal {bt-status.powered == "true"} :duration "150ms"
          (scroll :class "cc-list" :vscroll true :hscroll false :height 180
            (box :orientation "v" :space-evenly false
              (for device in bt-devices
                (button :class "cc-item ''${device.connected == "true" ? "active" : ""}"
                  :onclick "setsid -f ~/.config/eww/scripts/bt-toggle-device.sh ''\'''${device.mac}' ''\'''${device.connected}'"
                  (box :orientation "h" :space-evenly false
                    (label :class "cc-item-icon" :text {device.icon})
                    (label :class "cc-item-name" :text {device.name} :hexpand true :halign "start" :limit-width 18)
                    (label :class "cc-item-battery"
                      :text {device.battery > 0 ? "''${device.battery}%" : ""}
                      :visible {device.battery > 0})
                    (label :class "cc-item-status"
                      :text {device.connected == "true" ? "●" : "○"})))))))))
  '';

  scss = ''
    /* Bluetooth-specific styles */
    /* Note: @keyframes animations not supported by EWW GTK CSS */
    .bt-scanning {
      font-style: italic;
      opacity: 0.8;
    }

    .cc-item-status {
      font-size: 0.7rem;
    }

    .cc-item-status.connected {
      color: #16a34a;
    }
  '';

  scripts = {
    "bt-get-status.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get Bluetooth power state
        powered=$(bluetoothctl -- show 2>/dev/null | grep "Powered:" | awk '{print $2}')
        powered=''${powered:-no}

        # Check if scanning (look for active scan process)
        if pgrep -f "bluetoothctl.*scan" >/dev/null 2>&1; then
          scanning="true"
        else
          scanning="false"
        fi

        if [ "$powered" = "yes" ]; then
          echo "{\"powered\":\"true\",\"scanning\":\"$scanning\"}"
        else
          echo "{\"powered\":\"false\",\"scanning\":\"false\"}"
        fi
      '';
    };

    "bt-get-devices.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get all known devices (paired + recently discovered)
        devices=$(bluetoothctl -- devices 2>/dev/null)

        if [ -z "$devices" ]; then
          echo "[]"
          exit 0
        fi

        # Process each device
        echo "$devices" | while read -r line; do
          mac=$(echo "$line" | awk '{print $2}')
          name=$(echo "$line" | cut -d' ' -f3-)

          # Get device info
          info=$(bluetoothctl -- info "$mac" 2>/dev/null)

          # Check if connected - use grep with ^ to match only the main Connected field
          # (not BREDR.Connected or LE.Connected) and head -1 to get only the first match
          connected=$(echo "$info" | grep -E "^\s+Connected:" | head -1 | awk '{print $2}')
          connected=''${connected:-no}

          # Check if paired - same pattern for consistency
          paired=$(echo "$info" | grep -E "^\s+Paired:" | head -1 | awk '{print $2}')
          paired=''${paired:-no}

          # Get icon type
          icon_type=$(echo "$info" | grep -E "^\s+Icon:" | head -1 | awk '{print $2}')

          # Map icon to nerd font
          case "$icon_type" in
            audio-headphones) icon="󰋋" ;;
            audio-headset) icon="󰋎" ;;
            audio-card) icon="󰋋" ;;
            input-gaming) icon="󰊴" ;;
            input-keyboard) icon="󰌌" ;;
            input-mouse) icon="󰍽" ;;
            input-tablet) icon="󰓶" ;;
            phone) icon="󰏲" ;;
            computer) icon="󰍹" ;;
            *) icon="󰂯" ;;
          esac

          # Get battery level (if available)
          battery=$(echo "$info" | grep "Battery Percentage:" | grep -oP '0x[0-9a-f]+' | xargs printf "%d" 2>/dev/null)
          battery=''${battery:-0}

          # Escape name for JSON
          name=$(echo "$name" | sed 's/"/\\"/g')

          if [ "$connected" = "yes" ]; then
            conn="true"
          else
            conn="false"
          fi

          if [ "$paired" = "yes" ]; then
            pair="true"
          else
            pair="false"
          fi

          echo "{\"mac\":\"$mac\",\"name\":\"$name\",\"icon\":\"$icon\",\"connected\":\"$conn\",\"paired\":\"$pair\",\"battery\":$battery}"
        done | jq -s 'sort_by(.connected) | reverse' 2>/dev/null || echo "[]"
      '';
    };

    "bt-toggle-device.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        MAC="$1"
        CONNECTED="$2"

        if [ -z "$MAC" ]; then
          exit 1
        fi

        if [ "$CONNECTED" = "true" ]; then
          bluetoothctl -- disconnect "$MAC" &>/dev/null &
          notify-send "Bluetooth" "Disconnecting..." 2>/dev/null
        else
          bluetoothctl -- connect "$MAC" &>/dev/null &
          notify-send "Bluetooth" "Connecting..." 2>/dev/null
        fi
      '';
    };

    "bt-toggle.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        powered=$(bluetoothctl -- show 2>/dev/null | grep "Powered:" | awk '{print $2}')

        if [ "$powered" = "yes" ]; then
          bluetoothctl -- power off &>/dev/null
          notify-send "Bluetooth" "Bluetooth disabled" 2>/dev/null
        else
          bluetoothctl -- power on &>/dev/null
          notify-send "Bluetooth" "Bluetooth enabled" 2>/dev/null
        fi
      '';
    };

    "bt-scan-start.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Stop any existing scan first
        ~/.config/eww/scripts/bt-scan-stop.sh 2>/dev/null

        # Start scanning in background (will run for 60 seconds)
        nohup bluetoothctl --timeout 60 scan on >/dev/null 2>&1 &
      '';
    };

    "bt-scan-stop.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Kill any running scan process
        pkill -f "bluetoothctl.*scan" 2>/dev/null

        # Tell bluetoothctl to stop scanning
        bluetoothctl scan off &>/dev/null
      '';
    };
  };
}
