# EWW (ElKowars Wacky Widgets) configuration
# Audio popup widget for volume/mic control with device selection
{pkgs, ...}: let
  # Common PATH export for all scripts
  pathExport = ''export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"'';

  # Script to get list of audio sinks with duplicate handling
  getSinksScript = ''
    #!/usr/bin/env bash
    ${pathExport}
    default_sink=$(pactl get-default-sink 2>/dev/null)

    pactl -f json list sinks 2>/dev/null | jq -c --arg def "$default_sink" '
      [.[] | {
        name: .name,
        short_desc: (.description | split(" ") | .[0:3] | join(" "))
      }] |
      (group_by(.short_desc) | map({key: .[0].short_desc, count: length}) | from_entries) as $counts |
      reduce .[] as $item (
        {result: [], seen: {}};
        ($item.short_desc) as $desc |
        ((.seen[$desc] // 0) + 1) as $num |
        {
          result: (.result + [{
            name: $item.name,
            desc: (if $counts[$desc] > 1 then "\($desc) (\($num))" else $desc end),
            active: (if $item.name == $def then "yes" else "no" end)
          }]),
          seen: (.seen + {($desc): $num})
        }
      ) | .result
    ' 2>/dev/null || echo "[]"
  '';

  # Script to get list of audio sources with duplicate handling
  getSourcesScript = ''
    #!/usr/bin/env bash
    ${pathExport}
    default_source=$(pactl get-default-source 2>/dev/null)

    pactl -f json list sources 2>/dev/null | jq -c --arg def "$default_source" '
      [.[] | select(.name | contains(".monitor") | not) | {
        name: .name,
        short_desc: (.description | split(" ") | .[0:3] | join(" "))
      }] |
      (group_by(.short_desc) | map({key: .[0].short_desc, count: length}) | from_entries) as $counts |
      reduce .[] as $item (
        {result: [], seen: {}};
        ($item.short_desc) as $desc |
        ((.seen[$desc] // 0) + 1) as $num |
        {
          result: (.result + [{
            name: $item.name,
            desc: (if $counts[$desc] > 1 then "\($desc) (\($num))" else $desc end),
            active: (if $item.name == $def then "yes" else "no" end)
          }]),
          seen: (.seen + {($desc): $num})
        }
      ) | .result
    ' 2>/dev/null || echo "[]"
  '';
in {
  # EWW widget definition (yuck)
  home.file.".config/eww/eww.yuck".text = ''
    ; ====================
    ; Audio Control Widget
    ; ====================

    ; Polling variables for audio state
    (defpoll volume :interval "0.5s" "~/.config/eww/scripts/get-volume.sh")
    (defpoll volume-muted :interval "0.5s" "~/.config/eww/scripts/get-mute.sh")
    (defpoll mic-volume :interval "0.5s" "~/.config/eww/scripts/get-mic-volume.sh")
    (defpoll mic-muted :interval "0.5s" "~/.config/eww/scripts/get-mic-mute.sh")

    ; Device lists
    (defpoll sinks :interval "2s" "~/.config/eww/scripts/get-sinks.sh")
    (defpoll sources :interval "2s" "~/.config/eww/scripts/get-sources.sh")
    (defpoll current-sink :interval "1s" "~/.config/eww/scripts/get-current-sink.sh")
    (defpoll current-source :interval "1s" "~/.config/eww/scripts/get-current-source.sh")

    ; UI state
    (defvar sink-expanded false)
    (defvar source-expanded false)

    ; Window definitions (one per monitor)
    (defwindow audio-popup
      :monitor 0
      :geometry (geometry :x "30px" :y "0px" :width "260px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (audio-widget))

    (defwindow audio-popup-1
      :monitor 1
      :geometry (geometry :x "30px" :y "0px" :width "260px" :anchor "top right")
      :stacking "fg"
      :exclusive false
      :focusable false
      (audio-widget))

    ; Main widget
    (defwidget audio-widget []
      (eventbox :onhoverlost "~/.config/eww/scripts/close-audio.sh"
        (box :class "audio-box" :orientation "v" :space-evenly false :spacing 6

          ; Output section
          (box :class "audio-section" :orientation "v" :space-evenly false :spacing 4
            (label :class "section-label" :text "Output" :halign "start")
            (box :orientation "h" :space-evenly false :spacing 6
              (button :class "audio-icon" :onclick "pamixer -t"
                (label :text {volume-muted == "true" ? "󰖁" : "󰕾"}))
              (scale :class "volume-slider" :min 0 :max 100 :value volume
                :onchange "pamixer --set-volume {}"
                :orientation "h" :hexpand true)
              (label :class "volume-label" :text "''${volume}%"))
            (button :class "dropdown-btn" :onclick "eww update sink-expanded=''${!sink-expanded}"
              (box :orientation "h" :space-evenly false
                (label :class "dropdown-text" :text current-sink :hexpand true :halign "start")
                (label :text {sink-expanded ? "󰅃" : "󰅀"})))
            (revealer :transition "slidedown" :reveal sink-expanded :duration "150ms"
              (box :class "dropdown-list" :orientation "v" :space-evenly false
                (for sink in sinks
                  (button :class "dropdown-item ''${sink.active == "yes" ? "active" : ""}"
                    :onclick "pactl set-default-sink ''${sink.name} && eww update sink-expanded=false"
                    (label :text "''${sink.desc}" :halign "start"))))))

          ; Input section
          (box :class "audio-section" :orientation "v" :space-evenly false :spacing 4
            (label :class "section-label" :text "Input" :halign "start")
            (box :orientation "h" :space-evenly false :spacing 6
              (button :class "audio-icon" :onclick "pamixer --default-source -t"
                (label :text {mic-muted == "true" ? "󰍭" : "󰍬"}))
              (scale :class "volume-slider" :min 0 :max 100 :value mic-volume
                :onchange "pamixer --default-source --set-volume {}"
                :orientation "h" :hexpand true)
              (label :class "volume-label" :text "''${mic-volume}%"))
            (button :class "dropdown-btn" :onclick "eww update source-expanded=''${!source-expanded}"
              (box :orientation "h" :space-evenly false
                (label :class "dropdown-text" :text current-source :hexpand true :halign "start")
                (label :text {source-expanded ? "󰅃" : "󰅀"})))
            (revealer :transition "slidedown" :reveal source-expanded :duration "150ms"
              (box :class "dropdown-list" :orientation "v" :space-evenly false
                (for source in sources
                  (button :class "dropdown-item ''${source.active == "yes" ? "active" : ""}"
                    :onclick "pactl set-default-source ''${source.name} && eww update source-expanded=false"
                    (label :text "''${source.desc}" :halign "start")))))))))
  '';

  # Styles (scss)
  home.file.".config/eww/eww.scss".text = ''
    * {
      all: unset;
      font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", monospace;
      font-size: 13px;
    }

    .audio-box {
      background: rgba(135, 135, 135, 1);
      border-radius: 0.9rem;
      padding: 8px;
      color: #000000;
    }

    .audio-section {
      background-color: rgba(0, 0, 0, 0.04);
      border-radius: 0.4rem;
      padding: 6px 8px;
    }

    .section-label {
      font-size: 0.9rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.5);
      margin-bottom: 2px;
    }

    .audio-icon {
      font-size: 1rem;
      min-width: 20px;
      border-radius: 3px;
      padding: 2px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }
    }

    .volume-slider {
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

    .volume-label {
      min-width: 32px;
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.6);
    }

    .dropdown-btn {
      background-color: rgba(0, 0, 0, 0.06);
      border-radius: 4px;
      padding: 4px 8px;
      margin-top: 4px;

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }
    }

    .dropdown-text {
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.8);
    }

    .dropdown-list {
      background-color: rgba(0, 0, 0, 0.04);
      border-radius: 4px;
      padding: 2px;
      margin-top: 2px;
    }

    .dropdown-item {
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
  '';

  # Scripts
  home.file.".config/eww/scripts/toggle-audio.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}

      monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .id')

      if [ "$monitor" = "1" ]; then
        window="audio-popup-1"
      else
        window="audio-popup"
      fi

      if eww active-windows | grep -q "audio-popup"; then
        eww close audio-popup audio-popup-1
        eww update sink-expanded=false source-expanded=false
      else
        eww open "$window"
      fi
    '';
  };

  home.file.".config/eww/scripts/close-audio.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      eww close audio-popup audio-popup-1
      eww update sink-expanded=false source-expanded=false
    '';
  };

  home.file.".config/eww/scripts/get-volume.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      pamixer --get-volume 2>/dev/null || echo "0"
    '';
  };

  home.file.".config/eww/scripts/get-mute.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      pamixer --get-mute 2>/dev/null || echo "false"
    '';
  };

  home.file.".config/eww/scripts/get-mic-volume.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      pamixer --default-source --get-volume 2>/dev/null || echo "0"
    '';
  };

  home.file.".config/eww/scripts/get-mic-mute.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      pamixer --default-source --get-mute 2>/dev/null || echo "false"
    '';
  };

  home.file.".config/eww/scripts/get-current-sink.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      sink=$(pactl get-default-sink 2>/dev/null)
      pactl -f json list sinks 2>/dev/null \
        | jq -r --arg sink "$sink" '.[] | select(.name == $sink) | .description | split(" ") | .[0:3] | join(" ")' 2>/dev/null \
        || echo "Default"
    '';
  };

  home.file.".config/eww/scripts/get-current-source.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pathExport}
      source=$(pactl get-default-source 2>/dev/null)
      pactl -f json list sources 2>/dev/null \
        | jq -r --arg source "$source" '.[] | select(.name == $source) | .description | split(" ") | .[0:3] | join(" ")' 2>/dev/null \
        || echo "Default"
    '';
  };

  home.file.".config/eww/scripts/get-sinks.sh" = {
    executable = true;
    text = getSinksScript;
  };

  home.file.".config/eww/scripts/get-sources.sh" = {
    executable = true;
    text = getSourcesScript;
  };
}
