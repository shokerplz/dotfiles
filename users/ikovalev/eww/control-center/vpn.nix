# VPN Section for Control Center
# Supports WireGuard and OpenVPN connections via NetworkManager
{pathExport}: {
  yuck = ''
    ; VPN polling variables with initial values
    (defpoll vpn-connections :interval "2s"
      :initial "[]"
      "~/.config/eww/scripts/vpn-get-connections.sh")

    ; VPN connecting state (name of VPN being connected, empty = not connecting)
    (defvar vpn-connecting "")

    ; VPN section widget
    (defwidget vpn-section []
      (box :class "cc-section" :orientation "v" :space-evenly false :spacing 4
        :visible {arraylength(vpn-connections) > 0}
        ; Header
        (box :class "cc-section-header" :orientation "h" :space-evenly false
          (label :class "cc-section-title" :text "VPN" :hexpand true :halign "start")
          (label :class "cc-section-status''${vpn-connecting != "" ? " connecting" : ""}"
            :text {vpn-connecting != "" ? "Connecting..." :
                   (jq(vpn-connections, '[.[] | select(.active == "true")] | length') > 0 ? "Connected" : "")}))

        ; Connection list
        (box :class "cc-vpn-list" :orientation "v" :space-evenly false
          (for vpn in vpn-connections
            (button :class "cc-item ''${vpn.active == "true" ? "active" : ""} ''${vpn-connecting == vpn.name ? "connecting" : ""}"
              :onclick "setsid -f ~/.config/eww/scripts/vpn-toggle.sh ''\'''${vpn.name}' ''\'''${vpn.active}'"
              (box :orientation "h" :space-evenly false
                (label :class "cc-item-icon" :text {vpn.icon})
                (label :class "cc-item-name" :text {vpn.name} :hexpand true :halign "start" :limit-width 22)
                (label :class "cc-item-status" :text {vpn.active == "true" ? "●" : "○"})))))))
  '';

  scss = ''
    /* VPN-specific styles */
    .cc-vpn-list {
      margin-top: 4px;
    }
  '';

  scripts = {
    "vpn-get-connections.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Get all VPN connections (wireguard + openvpn)
        connections=$(nmcli -t -f NAME,TYPE,ACTIVE connection show 2>/dev/null | grep -E "wireguard|vpn" | sort)

        if [ -z "$connections" ]; then
          echo "[]"
          exit 0
        fi

        echo "$connections" | while IFS=: read -r name type active; do
          # Map type to icon
          case "$type" in
            wireguard) icon="󰖂" ;;
            vpn) icon="󰯄" ;;      # OpenVPN and others
            *) icon="󰖂" ;;
          esac

          # Convert active to string
          if [ "$active" = "yes" ]; then
            is_active="true"
          else
            is_active="false"
          fi

          # Escape name for JSON
          name=$(echo "$name" | sed 's/"/\\"/g')

          echo "{\"name\":\"$name\",\"type\":\"$type\",\"icon\":\"$icon\",\"active\":\"$is_active\"}"
        done | jq -s '.' 2>/dev/null || echo "[]"
      '';
    };

    "vpn-toggle.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        NAME="$1"
        ACTIVE="$2"

        if [ -z "$NAME" ]; then
          exit 1
        fi

        # Helper to clear connecting state
        clear_connecting() {
          eww update vpn-connecting="" 2>/dev/null
        }

        # Ensure connecting state is cleared on exit
        trap clear_connecting EXIT

        # Set connecting state
        eww update vpn-connecting="$NAME" 2>/dev/null

        if [ "$ACTIVE" = "true" ]; then
          # Disconnect
          nmcli connection down "$NAME" &>/dev/null
          notify-send "VPN" "Disconnected from $NAME" 2>/dev/null
        else
          # Disconnect any active VPN first (only one allowed)
          active_vpn=$(nmcli -t -f NAME,TYPE,ACTIVE connection show 2>/dev/null | \
            grep -E "wireguard|vpn" | grep ":yes$" | cut -d: -f1)

          if [ -n "$active_vpn" ]; then
            nmcli connection down "$active_vpn" &>/dev/null
          fi

          # Connect to new VPN
          notify-send "VPN" "Connecting to $NAME..." 2>/dev/null
          result=$(nmcli connection up "$NAME" 2>&1)

          if [ $? -eq 0 ]; then
            notify-send "VPN" "Connected to $NAME" 2>/dev/null
          else
            notify-send "VPN" "Failed to connect: $result" 2>/dev/null
          fi
        fi
      '';
    };
  };
}
