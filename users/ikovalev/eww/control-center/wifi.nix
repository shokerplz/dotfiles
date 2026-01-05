# WiFi Section for Control Center
{pathExport}: {
  yuck = ''
    ; WiFi polling variables with initial values
    (defpoll wifi-status :interval "2s"
      :initial '{"enabled":"true","connected":"false","ssid":"","signal":0}'
      "~/.config/eww/scripts/wifi-get-status.sh")
    (defpoll wifi-networks :interval "5s"
      :initial "[]"
      "~/.config/eww/scripts/wifi-get-networks.sh")

    ; WiFi UI state
    (defvar wifi-expanded false)
    (defvar wifi-connecting "")  ; SSID currently being connected to (empty = not connecting)

    ; WiFi section widget
    (defwidget wifi-section []
      (box :class "cc-section" :orientation "v" :space-evenly false :spacing 4
        ; Header
        (box :class "cc-section-header" :orientation "h" :space-evenly false
          (label :class "cc-section-title" :text "WiFi" :hexpand true :halign "start")
          (label :class "cc-section-status''${wifi-connecting != "" ? " connecting" : ""}"
            :text {wifi-connecting != "" ? "Connecting..." : (wifi-status.connected == "true" ? wifi-status.ssid : "Not connected")}
            :halign "end")
          (button :class "cc-toggle-btn ''${wifi-status.enabled == "true" ? "active" : "disabled"}"
            :onclick "~/.config/eww/scripts/wifi-toggle.sh"
            (label :text {wifi-status.enabled == "true" ? "󰖩" : "󰖪"})))

        ; Network list (expandable)
        (revealer :transition "slidedown" :reveal {wifi-status.enabled == "true"} :duration "150ms"
          (box :orientation "v" :space-evenly false :spacing 2
            ; Current connection (if any)
            (box :visible {wifi-status.connected == "true"}
              :class "cc-item active" :orientation "h" :space-evenly false
              (label :class "cc-item-icon" :text "󰤨")
              (label :class "cc-item-name" :text {wifi-status.ssid} :hexpand true :halign "start")
              (label :class "cc-item-check" :text "✓")
              (label :class "cc-item-signal" :text "''${wifi-status.signal}%")
              (button :class "cc-toggle-btn" :onclick "~/.config/eww/scripts/wifi-disconnect.sh"
                :tooltip "Disconnect"
                (label :text "󰖪")))

            ; Available networks toggle
            (button :class "cc-dropdown-btn" :onclick "eww update wifi-expanded=''${!wifi-expanded}"
              (box :orientation "h" :space-evenly false
                (label :class "cc-dropdown-text" :text "Available Networks" :hexpand true :halign "start")
                (label :text {wifi-expanded ? "󰅃" : "󰅀"})))

            ; Available networks list
            (revealer :transition "slidedown" :reveal wifi-expanded :duration "150ms"
              (scroll :class "cc-list" :vscroll true :hscroll false :height 200
                (box :orientation "v" :space-evenly false
                  (for network in wifi-networks
                    (button :class "cc-item ''${network.active == "true" ? "active" : ""}"
                      :onclick "setsid -f ~/.config/eww/scripts/wifi-connect.sh ''\'''${network.ssid}' ''\'''${network.security}'"
                      :visible {network.ssid != wifi-status.ssid}
                      (box :orientation "h" :space-evenly false
                        (label :class "cc-item-icon" :text {network.signal >= 70 ? "󰤨" : (network.signal >= 40 ? "󰤟" : "󰤯")})
                        (label :class "cc-item-name" :text {network.ssid} :hexpand true :halign "start" :limit-width 20)
                        (label :class "cc-item-status" :text {network.security != "" ? "󰌾" : ""})
                        (label :class "cc-item-signal" :text "''${network.signal}%")))))))))
      ))
  '';

  scss = ''
    /* WiFi-specific styles */
    .cc-section-status.connecting {
      font-style: italic;
      opacity: 0.8;
    }
  '';

  scripts = {
    "wifi-get-status.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Check if WiFi is enabled
        wifi_enabled=$(nmcli radio wifi 2>/dev/null)

        if [ "$wifi_enabled" != "enabled" ]; then
          echo '{"enabled":"false","connected":"false","ssid":"","signal":0}'
          exit 0
        fi

        # Get current connection info (TYPE is 802-11-wireless, not wifi)
        current=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null | grep wireless | head -1)

        if [ -z "$current" ]; then
          echo '{"enabled":"true","connected":"false","ssid":"","signal":0}'
          exit 0
        fi

        ssid=$(echo "$current" | cut -d: -f1)

        # Get signal strength
        signal=$(nmcli -t -f IN-USE,SIGNAL device wifi list 2>/dev/null | grep '^\*' | cut -d: -f2)
        signal=''${signal:-0}

        echo "{\"enabled\":\"true\",\"connected\":\"true\",\"ssid\":\"$ssid\",\"signal\":$signal}"
      '';
    };

    "wifi-get-networks.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get list of available WiFi networks with auto rescan
        # Note: active must be a quoted string "true"/"false" for EWW comparison
        result=$(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list --rescan auto 2>/dev/null | \
          awk -F: '
            $1 != "" {
              gsub(/"/, "\\\"", $1)
              active = ($4 == "*") ? "true" : "false"
              printf "{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\",\"active\":\"%s\"}\n", $1, $2, $3, active
            }
          ' | jq -s 'unique_by(.ssid) | sort_by(-.signal)' 2>/dev/null)

        if [ -z "$result" ]; then
          echo "[]"
        else
          echo "$result"
        fi
      '';
    };

    "wifi-connect.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        SSID="$1"
        SECURITY="$2"
        DEBUG_LOG="/tmp/wifi-debug.log"

        # Helper to clear connecting state
        clear_connecting() {
          eww update wifi-connecting="" 2>/dev/null
        }

        # Ensure connecting state is cleared on exit (success, failure, or interrupt)
        trap clear_connecting EXIT

        # Debug logging
        echo "$(date): wifi-connect called with SSID='$SSID' SECURITY='$SECURITY'" >> "$DEBUG_LOG"

        if [ -z "$SSID" ]; then
          echo "$(date): Empty SSID, exiting" >> "$DEBUG_LOG"
          exit 1
        fi

        # Set connecting state in EWW
        eww update wifi-connecting="$SSID" 2>/dev/null

        # Detect WiFi interface dynamically
        WIFI_IFACE=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep ':wifi$' | cut -d: -f1 | head -1)
        echo "$(date): Detected WiFi interface: '$WIFI_IFACE'" >> "$DEBUG_LOG"

        if [ -z "$WIFI_IFACE" ]; then
          echo "$(date): No WiFi interface found" >> "$DEBUG_LOG"
          notify-send "WiFi" "No WiFi adapter found" 2>/dev/null
          exit 1
        fi

        # Check if we already have a saved connection for this network
        if nmcli connection show "$SSID" &>/dev/null; then
          echo "$(date): Found saved connection for '$SSID', activating on $WIFI_IFACE..." >> "$DEBUG_LOG"
          notify-send "WiFi" "Connecting to $SSID..." 2>/dev/null
          result=$(nmcli connection up "$SSID" ifname "$WIFI_IFACE" 2>&1)
          exit_code=$?
          echo "$(date): nmcli exit code: $exit_code, result: $result" >> "$DEBUG_LOG"
          if [ $exit_code -eq 0 ]; then
            notify-send "WiFi" "Connected to $SSID" 2>/dev/null
          else
            notify-send "WiFi" "Failed to connect: $result" 2>/dev/null
          fi
          exit $exit_code
        fi

        # If network has security, prompt for password
        # Script runs in its own session via setsid, so wofi can get focus
        if [ -n "$SECURITY" ] && [ "$SECURITY" != "--" ] && [ "$SECURITY" != "" ]; then
          echo "$(date): Network '$SSID' requires password (security: $SECURITY), launching wofi..." >> "$DEBUG_LOG"
          
          # Launch wofi directly - script is already detached via setsid -f in onclick
          password=$(wofi --dmenu --password --prompt "Password for $SSID:" 2>/dev/null)

          if [ -z "$password" ]; then
            echo "$(date): Password prompt cancelled or empty" >> "$DEBUG_LOG"
            notify-send "WiFi" "Connection cancelled" 2>/dev/null
            exit 1
          fi

          echo "$(date): Got password, connecting to '$SSID' on $WIFI_IFACE..." >> "$DEBUG_LOG"
          notify-send "WiFi" "Connecting to $SSID..." 2>/dev/null
          result=$(nmcli device wifi connect "$SSID" password "$password" ifname "$WIFI_IFACE" 2>&1)
          exit_code=$?
          echo "$(date): nmcli exit code: $exit_code, result: $result" >> "$DEBUG_LOG"
          if [ $exit_code -eq 0 ]; then
            notify-send "WiFi" "Connected to $SSID" 2>/dev/null
          else
            notify-send "WiFi" "Failed to connect: $result" 2>/dev/null
          fi
        else
          echo "$(date): Open network '$SSID', connecting directly on $WIFI_IFACE..." >> "$DEBUG_LOG"
          notify-send "WiFi" "Connecting to $SSID..." 2>/dev/null
          result=$(nmcli device wifi connect "$SSID" ifname "$WIFI_IFACE" 2>&1)
          exit_code=$?
          echo "$(date): nmcli exit code: $exit_code, result: $result" >> "$DEBUG_LOG"
          if [ $exit_code -eq 0 ]; then
            notify-send "WiFi" "Connected to $SSID" 2>/dev/null
          else
            notify-send "WiFi" "Failed to connect: $result" 2>/dev/null
          fi
        fi
      '';
    };

    "wifi-disconnect.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get the active WiFi connection (TYPE is 802-11-wireless, not wifi)
        connection=$(nmcli -t -f NAME,TYPE connection show --active | grep wireless | cut -d: -f1)

        if [ -n "$connection" ]; then
          nmcli connection down "$connection" &>/dev/null
          notify-send "WiFi" "Disconnected from $connection" 2>/dev/null
        fi
      '';
    };

    "wifi-toggle.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        current=$(nmcli radio wifi)

        if [ "$current" = "enabled" ]; then
          nmcli radio wifi off
          notify-send "WiFi" "WiFi disabled" 2>/dev/null
        else
          nmcli radio wifi on
          notify-send "WiFi" "WiFi enabled" 2>/dev/null
          # Trigger a rescan after enabling to populate the network list
          sleep 1
          nmcli device wifi list --rescan yes >/dev/null 2>&1 &
        fi
      '';
    };
  };
}
