# Audio Section for Control Center
# Migrated from eww/audio.nix
{pathExport}: let
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
  yuck = ''
    ; Audio polling variables with initial values
    (defpoll volume :interval "0.5s" :initial "50" "~/.config/eww/scripts/get-volume.sh")
    (defpoll volume-muted :interval "0.5s" :initial "false" "~/.config/eww/scripts/get-mute.sh")
    (defpoll mic-volume :interval "0.5s" :initial "50" "~/.config/eww/scripts/get-mic-volume.sh")
    (defpoll mic-muted :interval "0.5s" :initial "false" "~/.config/eww/scripts/get-mic-mute.sh")

    ; Device lists with initial values
    (defpoll sinks :interval "2s" :initial "[]" "~/.config/eww/scripts/get-sinks.sh")
    (defpoll sources :interval "2s" :initial "[]" "~/.config/eww/scripts/get-sources.sh")
    (defpoll current-sink :interval "1s" :initial "Default" "~/.config/eww/scripts/get-current-sink.sh")
    (defpoll current-source :interval "1s" :initial "Default" "~/.config/eww/scripts/get-current-source.sh")

    ; UI state
    (defvar sink-expanded false)
    (defvar source-expanded false)

    ; Audio section widget
    (defwidget audio-section []
      (box :class "cc-section" :orientation "v" :space-evenly false :spacing 6
        ; Header
        (label :class "cc-section-title" :text "Sound" :halign "start")

        ; Output volume
        (box :orientation "h" :space-evenly false :spacing 6
          (button :class "cc-slider-icon ''${volume-muted == "true" ? "muted" : ""}"
            :onclick "pamixer -t"
            (label :text {volume-muted == "true" ? "󰖁" : "󰕾"}))
          (scale :class "cc-slider" :min 0 :max 100 :value volume
            :onchange "pamixer --set-volume {}"
            :orientation "h" :hexpand true)
          (label :class "cc-slider-label" :text "''${volume}%"))

        ; Output device selector
        (button :class "cc-dropdown-btn" :onclick "eww update sink-expanded=''${!sink-expanded}"
          (box :orientation "h" :space-evenly false
            (label :class "cc-dropdown-text" :text "Output: ''${current-sink}" :hexpand true :halign "start")
            (label :text {sink-expanded ? "󰅃" : "󰅀"})))
        (revealer :transition "slidedown" :reveal sink-expanded :duration "150ms"
          (box :class "cc-dropdown-list" :orientation "v" :space-evenly false
            (for sink in sinks
              (button :class "cc-dropdown-item ''${sink.active == "yes" ? "active" : ""}"
                :onclick "pactl set-default-sink ''${sink.name} && eww update sink-expanded=false"
                (label :text "''${sink.desc}" :halign "start")))))

        ; Separator
        (box :class "cc-separator" :orientation "h")

        ; Input volume
        (box :orientation "h" :space-evenly false :spacing 6
          (button :class "cc-slider-icon ''${mic-muted == "true" ? "muted" : ""}"
            :onclick "pamixer --default-source -t"
            (label :text {mic-muted == "true" ? "󰍭" : "󰍬"}))
          (scale :class "cc-slider" :min 0 :max 100 :value mic-volume
            :onchange "pamixer --default-source --set-volume {}"
            :orientation "h" :hexpand true)
          (label :class "cc-slider-label" :text "''${mic-volume}%"))

        ; Input device selector
        (button :class "cc-dropdown-btn" :onclick "eww update source-expanded=''${!source-expanded}"
          (box :orientation "h" :space-evenly false
            (label :class "cc-dropdown-text" :text "Input: ''${current-source}" :hexpand true :halign "start")
            (label :text {source-expanded ? "󰅃" : "󰅀"})))
        (revealer :transition "slidedown" :reveal source-expanded :duration "150ms"
          (box :class "cc-dropdown-list" :orientation "v" :space-evenly false
            (for source in sources
              (button :class "cc-dropdown-item ''${source.active == "yes" ? "active" : ""}"
                :onclick "pactl set-default-source ''${source.name} && eww update source-expanded=false"
                (label :text "''${source.desc}" :halign "start")))))))
  '';

  scss = ''
    /* Audio-specific styles */
    .cc-separator {
      background-color: rgba(0, 0, 0, 0.08);
      min-height: 1px;
      margin: 4px 0;
    }
  '';

  scripts = {
    "get-volume.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        pamixer --get-volume 2>/dev/null || echo "0"
      '';
    };

    "get-mute.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        pamixer --get-mute 2>/dev/null || echo "false"
      '';
    };

    "get-mic-volume.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        pamixer --default-source --get-volume 2>/dev/null || echo "0"
      '';
    };

    "get-mic-mute.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        pamixer --default-source --get-mute 2>/dev/null || echo "false"
      '';
    };

    "get-current-sink.sh" = {
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

    "get-current-source.sh" = {
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

    "get-sinks.sh" = {
      executable = true;
      text = getSinksScript;
    };

    "get-sources.sh" = {
      executable = true;
      text = getSourcesScript;
    };
  };
}
