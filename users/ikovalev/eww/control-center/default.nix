# Control Center Widget
# Unified widget combining WiFi, Bluetooth, Audio, Brightness, and Media controls
{pathExport}: let
  # Import all sections
  wifiSection = import ./wifi.nix {inherit pathExport;};
  bluetoothSection = import ./bluetooth.nix {inherit pathExport;};
  audioSection = import ./audio.nix {inherit pathExport;};
  brightnessSection = import ./brightness.nix {inherit pathExport;};
  mediaSection = import ./media.nix {inherit pathExport;};

  # Combine all sections
  sections = [wifiSection bluetoothSection audioSection brightnessSection mediaSection];
in {
  yuck = ''
    ; ====================
    ; Control Center Widget
    ; ====================

    ; Import section variables and widgets
    ${wifiSection.yuck}
    ${bluetoothSection.yuck}
    ${audioSection.yuck}
    ${brightnessSection.yuck}
    ${mediaSection.yuck}

    ; Window definitions (one per monitor)
    (defwindow control-center
      :monitor 0
      :geometry (geometry :x "10px" :y "0px" :width "320px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (control-center-widget))

    (defwindow control-center-1
      :monitor 1
      :geometry (geometry :x "10px" :y "0px" :width "320px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (control-center-widget))

    ; Main Control Center widget
    (defwidget control-center-widget []
      (eventbox :onhoverlost "~/.config/eww/scripts/close-control-center.sh"
        (box :class "control-center-box" :orientation "v" :space-evenly false :spacing 8
          (wifi-section)
          (bluetooth-section)
          (audio-section)
          (brightness-section)
          (media-section))))
  '';

  scss = ''
    .control-center-box {
      background: rgba(135, 135, 135, 1);
      border-radius: 0.9rem;
      padding: 10px;
      color: #000000;
    }

    .cc-section {
      background-color: rgba(0, 0, 0, 0.04);
      border-radius: 0.6rem;
      padding: 8px 10px;
    }

    .cc-section-header {
      margin-bottom: 6px;
    }

    .cc-section-title {
      font-size: 0.9rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.5);
    }

    .cc-section-icon {
      font-size: 1rem;
      color: rgba(0, 0, 0, 0.6);
      min-width: 24px;
    }

    .cc-section-status {
      font-size: 0.75rem;
      color: rgba(0, 0, 0, 0.4);
    }

    .cc-toggle-btn {
      font-size: 1.1rem;
      padding: 4px 8px;
      border-radius: 4px;
      min-width: 32px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }

      &.active {
        color: #2563eb;
      }

      &.disabled {
        color: rgba(0, 0, 0, 0.3);
      }
    }

    .cc-item {
      padding: 6px 8px;
      border-radius: 4px;
      margin: 2px 0;

      &:hover {
        background-color: rgba(0, 0, 0, 0.08);
      }

      &.active {
        background-color: rgba(0, 0, 0, 0.12);
      }

      &.connecting {
        opacity: 0.7;
      }
    }

    .cc-item-icon {
      font-size: 1rem;
      min-width: 24px;
      color: rgba(0, 0, 0, 0.7);
    }

    .cc-item-name {
      font-size: 0.85rem;
      color: rgba(0, 0, 0, 0.9);
    }

    .cc-item-status {
      font-size: 0.75rem;
      color: rgba(0, 0, 0, 0.5);
    }

    .cc-item-signal {
      font-size: 0.75rem;
      color: rgba(0, 0, 0, 0.4);
      min-width: 36px;
    }

    .cc-item-check {
      color: #16a34a;
      font-size: 0.9rem;
    }

    .cc-item-battery {
      font-size: 0.75rem;
      color: rgba(0, 0, 0, 0.5);
    }

    .cc-list {
      min-height: 50px;
    }

    .cc-slider {
      min-height: 20px;
      min-width: 100px;

      trough {
        background-color: rgba(0, 0, 0, 0.12);
        border-radius: 4px;
        min-height: 4px;

        highlight {
          background-color: rgba(0, 0, 0, 0.5);
          border-radius: 4px;
          min-height: 4px;
        }
      }

      slider {
        background-color: #000000;
        border-radius: 50%;
        min-height: 12px;
        min-width: 12px;
        margin: -4px 0;
      }
    }

    .cc-slider-label {
      min-width: 36px;
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.6);
    }

    .cc-slider-icon {
      font-size: 1rem;
      min-width: 24px;
      border-radius: 3px;
      padding: 2px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }

      &.muted {
        color: rgba(0, 0, 0, 0.4);
      }
    }

    .cc-dropdown-btn {
      background-color: rgba(0, 0, 0, 0.06);
      border-radius: 4px;
      padding: 4px 8px;
      margin-top: 4px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }
    }

    .cc-dropdown-text {
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.8);
    }

    .cc-dropdown-list {
      background-color: rgba(0, 0, 0, 0.04);
      border-radius: 4px;
      padding: 2px;
      margin-top: 2px;
    }

    .cc-dropdown-item {
      padding: 4px 8px;
      border-radius: 3px;
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.7);

      &:hover {
        background-color: rgba(0, 0, 0, 0.08);
      }

      &.active {
        background-color: rgba(0, 0, 0, 0.12);
        color: #000000;
      }
    }

    ${wifiSection.scss}
    ${bluetoothSection.scss}
    ${audioSection.scss}
    ${brightnessSection.scss}
    ${mediaSection.scss}
  '';

  scripts = {
    "toggle-control-center.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')

        if [ "$monitor" = "1" ]; then
          window="control-center-1"
        else
          window="control-center"
        fi

        if eww active-windows | grep -q "control-center"; then
          ~/.config/eww/scripts/close-control-center.sh
        else
          # Start bluetooth scanning when opening
          ~/.config/eww/scripts/bt-scan-start.sh &
          eww open "$window"
        fi
      '';
    };

    "close-control-center.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Stop bluetooth scanning when closing
        ~/.config/eww/scripts/bt-scan-stop.sh &

        # Reset UI state
        eww update wifi-expanded=false
        eww update sink-expanded=false
        eww update source-expanded=false

        eww close control-center control-center-1
      '';
    };
  }
  // wifiSection.scripts
  // bluetoothSection.scripts
  // audioSection.scripts
  // brightnessSection.scripts
  // mediaSection.scripts;
}
