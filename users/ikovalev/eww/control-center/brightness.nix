# Brightness Section for Control Center
# Only visible on devices with backlight (laptops)
{pathExport}: {
  yuck = ''
    ; Brightness polling variables with initial values
    (defpoll brightness :interval "0.5s" :initial "50" "~/.config/eww/scripts/brightness-get.sh")
    (defpoll has-backlight :interval "10s" :initial "false" "~/.config/eww/scripts/brightness-available.sh")

    ; Brightness section widget (only shown on laptops)
    (defwidget brightness-section []
      (revealer :transition "slidedown" :reveal {has-backlight == "true"} :duration "150ms"
        (box :class "cc-section" :orientation "v" :space-evenly false :spacing 4
          ; Header
          (label :class "cc-section-title" :text "Brightness" :halign "start")

          ; Brightness slider
          (box :orientation "h" :space-evenly false :spacing 6
            (label :class "cc-slider-icon" :text "󰃟")
            (scale :class "cc-slider" :min 5 :max 100 :value brightness
              :onchange "~/.config/eww/scripts/brightness-set.sh {}"
              :orientation "h" :hexpand true)
            (label :class "cc-slider-label" :text "''${brightness}%")))))
  '';

  scss = ''
    /* Brightness-specific styles - uses common cc-slider styles */
  '';

  scripts = {
    "brightness-get.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Check if brightnessctl is available and backlight exists
        if ! command -v brightnessctl &>/dev/null; then
          echo "50"
          exit 0
        fi

        # Get current brightness percentage
        brightness=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%')

        if [ -z "$brightness" ]; then
          echo "50"
        else
          echo "$brightness"
        fi
      '';
    };

    "brightness-set.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        value="$1"

        if [ -z "$value" ]; then
          exit 1
        fi

        # Ensure minimum brightness of 5% to avoid black screen
        if [ "$value" -lt 5 ]; then
          value=5
        fi

        brightnessctl set "''${value}%" &>/dev/null
      '';
    };

    "brightness-available.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Check if any backlight device exists
        if ls /sys/class/backlight/ 2>/dev/null | head -1 | grep -q .; then
          echo "true"
        else
          echo "false"
        fi
      '';
    };
  };
}
