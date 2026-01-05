# Media Player Section for Control Center
# Only visible when a media player is active
{pathExport}: {
  yuck = ''
    ; Media polling variables with initial values
    (defpoll media-status :interval "1s"
      :initial '{"has_player":"false","playing":"false","title":"","artist":"","album":""}'
      "~/.config/eww/scripts/media-get-status.sh")

    ; Media section widget (only shown when player is active)
    (defwidget media-section []
      (revealer :transition "slidedown" :reveal {media-status.has_player == "true"} :duration "150ms"
        (box :class "cc-section cc-media-section" :orientation "v" :space-evenly false :spacing 4
          ; Header
          (label :class "cc-section-title" :text "Now Playing" :halign "start")

          ; Track info
          (box :orientation "v" :space-evenly false :spacing 2
            (label :class "media-title" :text {media-status.title}
              :halign "start" :limit-width 30 :tooltip {media-status.title})
            (label :class "media-artist" :text {media-status.artist}
              :halign "start" :limit-width 30 :visible {media-status.artist != ""}))

          ; Controls
          (box :class "media-controls" :orientation "h" :halign "center" :space-evenly false :spacing 16
            (button :class "media-btn" :onclick "~/.config/eww/scripts/media-prev.sh"
              (label :text "󰒮"))
            (button :class "media-btn media-btn-main" :onclick "~/.config/eww/scripts/media-play-pause.sh"
              (label :text {media-status.playing == "true" ? "󰏤" : "󰐊"}))
            (button :class "media-btn" :onclick "~/.config/eww/scripts/media-next.sh"
              (label :text "󰒭"))))))
  '';

  scss = ''
    /* Media-specific styles */
    .cc-media-section {
      /* Optional: different background for media section */
    }

    .media-title {
      font-size: 0.9rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.9);
    }

    .media-artist {
      font-size: 0.8rem;
      color: rgba(0, 0, 0, 0.6);
    }

    .media-controls {
      margin-top: 6px;
    }

    .media-btn {
      font-size: 1.2rem;
      padding: 6px 10px;
      border-radius: 50%;
      color: rgba(0, 0, 0, 0.8);

      &:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }
    }

    .media-btn-main {
      font-size: 1.4rem;
      padding: 8px 12px;
      background-color: rgba(0, 0, 0, 0.08);

      &:hover {
        background-color: rgba(0, 0, 0, 0.15);
      }
    }
  '';

  scripts = {
    "media-get-status.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}

        # Check if any player is available
        if ! playerctl status &>/dev/null; then
          echo '{"has_player":"false","playing":"false","title":"","artist":"","album":""}'
          exit 0
        fi

        # Get player status
        status=$(playerctl status 2>/dev/null)
        playing="false"
        if [ "$status" = "Playing" ]; then
          playing="true"
        fi

        # Get metadata with proper escaping
        title=$(playerctl metadata title 2>/dev/null | sed 's/"/\\"/g' | head -c 100)
        artist=$(playerctl metadata artist 2>/dev/null | sed 's/"/\\"/g' | head -c 100)
        album=$(playerctl metadata album 2>/dev/null | sed 's/"/\\"/g' | head -c 100)

        # Default values if empty
        title=''${title:-"Unknown"}
        artist=''${artist:-""}
        album=''${album:-""}

        echo "{\"has_player\":\"true\",\"playing\":\"$playing\",\"title\":\"$title\",\"artist\":\"$artist\",\"album\":\"$album\"}"
      '';
    };

    "media-play-pause.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        playerctl play-pause &>/dev/null
      '';
    };

    "media-next.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        playerctl next &>/dev/null
      '';
    };

    "media-prev.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pathExport}
        playerctl previous &>/dev/null
      '';
    };
  };
}
